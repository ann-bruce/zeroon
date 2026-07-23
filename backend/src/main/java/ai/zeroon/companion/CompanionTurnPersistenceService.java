package ai.zeroon.companion;

import ai.zeroon.ai.AiUsageDetails;
import ai.zeroon.ai.AiUsageLogService;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.memory.MemoryAiContextAssembler;
import ai.zeroon.profile.ProfileAiContextAssembler;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CompanionTurnPersistenceService {

    private static final String CONVERSATION_TITLE = "ZEROON Reflection";
    private static final String ASSISTANT_SAFETY_LABEL = "COMPANION_REFLECTION";

    private final UserRepository userRepository;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final ProfileAiContextAssembler profileAiContextAssembler;
    private final MemoryAiContextAssembler memoryAiContextAssembler;
    private final AiUsageLogService aiUsageLogService;

    public CompanionTurnPersistenceService(
            UserRepository userRepository,
            ConversationRepository conversationRepository,
            MessageRepository messageRepository,
            ProfileAiContextAssembler profileAiContextAssembler,
            MemoryAiContextAssembler memoryAiContextAssembler,
            AiUsageLogService aiUsageLogService) {
        this.userRepository = userRepository;
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.profileAiContextAssembler = profileAiContextAssembler;
        this.memoryAiContextAssembler = memoryAiContextAssembler;
        this.aiUsageLogService = aiUsageLogService;
    }

    @Transactional
    public StartedTurn begin(Long userId, Long conversationId, String message) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        ConversationEntity conversation = resolveConversation(user, conversationId);
        messageRepository.save(new MessageEntity(conversation, MessageRole.USER, message, null));
        return new StartedTurn(user.getId(), conversation.getId());
    }

    @Transactional(readOnly = true)
    public AssembledUserPrompt assembleUserPrompt(Long userId, String message) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        StringBuilder prompt = new StringBuilder();
        var profileContext = profileAiContextAssembler.assemble(userId);
        var memoryContext = memoryAiContextAssembler.assemble(userId);
        profileContext.ifPresent(value -> prompt.append(value).append("\n\n"));
        memoryContext.ifPresent(value -> prompt.append(value).append("\n\n"));
        prompt.append("Current state: ").append(user.getCurrentState().name()).append('\n');
        prompt.append("User message: ").append(message).append('\n');
        return new AssembledUserPrompt(
                prompt.toString(),
                profileContext.isPresent(),
                memoryContext.isPresent());
    }

    @Transactional
    public ChatResponse complete(
            StartedTurn turn,
            String reply,
            String safetyNotice,
            AiUsageDetails usage,
            AssembledUserPrompt assembledPrompt) {
        ConversationEntity conversation = conversationRepository
                .findByIdAndUserId(turn.conversationId(), turn.userId())
                .orElseThrow(() -> new EntityNotFoundException("Conversation not found"));
        MessageEntity assistantMessage = messageRepository.save(new MessageEntity(
                conversation,
                MessageRole.ASSISTANT,
                reply,
                ASSISTANT_SAFETY_LABEL));
        conversation.touch();
        aiUsageLogService.record(conversation.getUser(), conversation, usage);
        return new ChatResponse(
                conversation.getId(),
                assistantMessage.getId(),
                reply,
                safetyNotice,
                evidenceOutcome(usage),
                latencyBucket(usage.durationMs()),
                promptVersion(usage),
                modelAlias(usage),
                assembledPrompt.contextClasses());
    }

    private ConversationEntity resolveConversation(UserEntity user, Long conversationId) {
        if (conversationId == null) {
            return conversationRepository.save(new ConversationEntity(user, CONVERSATION_TITLE));
        }
        return conversationRepository.findByIdAndUserId(conversationId, user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Conversation not found"));
    }

    public record StartedTurn(Long userId, Long conversationId) {
    }

    public record AssembledUserPrompt(
            String prompt,
            boolean profileContextEnabled,
            boolean memoryContextEnabled) {

        public List<String> contextClasses() {
            java.util.ArrayList<String> classes = new java.util.ArrayList<>(2);
            if (profileContextEnabled) {
                classes.add("PROFILE");
            }
            if (memoryContextEnabled) {
                classes.add("MEMORY");
            }
            return List.copyOf(classes);
        }

        public static AssembledUserPrompt none() {
            return new AssembledUserPrompt("", false, false);
        }
    }

    private String evidenceOutcome(AiUsageDetails usage) {
        return switch (usage.outcome()) {
            case SUCCESS -> "SUCCESS";
            case FALLBACK -> "FALLBACK";
            case REFUSAL -> "REFUSAL";
            case ERROR -> "FAILED";
        };
    }

    private String latencyBucket(long durationMs) {
        if (durationMs < 500) {
            return "UNDER_500_MS";
        }
        if (durationMs < 1_500) {
            return "FROM_500_TO_1499_MS";
        }
        if (durationMs < 5_000) {
            return "FROM_1500_TO_4999_MS";
        }
        if (durationMs < 15_000) {
            return "FROM_5_TO_14_SECONDS";
        }
        return "OVER_15_SECONDS";
    }

    private String promptVersion(AiUsageDetails usage) {
        if (usage.outcome() == AiUsageOutcome.REFUSAL) {
            return "SAFETY_V1";
        }
        if (usage.promptTemplateVersion() == null) {
            return "COMPANION_REFLECTION_FALLBACK_V1";
        }
        return "COMPANION_REFLECTION_V" + usage.promptTemplateVersion();
    }

    private String modelAlias(AiUsageDetails usage) {
        return switch (usage.outcome()) {
            case SUCCESS -> "PRIMARY";
            case FALLBACK -> "FALLBACK";
            case REFUSAL -> "SAFETY_BOUNDARY";
            case ERROR -> "UNAVAILABLE";
        };
    }
}
