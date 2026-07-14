package ai.zeroon.companion;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmProviderUnavailableException;
import ai.zeroon.ai.LlmRequest;
import ai.zeroon.ai.LlmResponse;
import ai.zeroon.ai.AiUsageLogService;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.prompt.PromptTemplateSelection;
import ai.zeroon.prompt.PromptTemplateService;
import ai.zeroon.profile.ProfileAiContextAssembler;
import ai.zeroon.record.ZeroRecordEntity;
import ai.zeroon.record.ZeroRecordRepository;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.Duration;
import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CompanionService {

    private static final String SAFETY_NOTICE =
            "ZEROON 只能提供非诊断性的陪伴式反思，不能替代医疗、法律、财务或心理咨询。";
    private static final String FALLBACK_REPLY =
            "你正在把一些还没有完全成形的感受，慢慢放进可以回看的地方。"
                    + "这些记录里已经有了状态、感受和小进展的线索，"
                    + "ZEROON 会先安静保存它们，再陪你一点一点看清楚。";

    private final LlmProvider llmProvider;
    private final UserRepository userRepository;
    private final ZeroRecordRepository zeroRecordRepository;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final PromptTemplateService promptTemplateService;
    private final AiUsageLogService aiUsageLogService;
    private final SafetyBoundaryService safetyBoundaryService;
    private final ProfileAiContextAssembler profileAiContextAssembler;

    public CompanionService(
            LlmProvider llmProvider,
            UserRepository userRepository,
            ZeroRecordRepository zeroRecordRepository,
            ConversationRepository conversationRepository,
            MessageRepository messageRepository,
            PromptTemplateService promptTemplateService,
            AiUsageLogService aiUsageLogService,
            SafetyBoundaryService safetyBoundaryService,
            ProfileAiContextAssembler profileAiContextAssembler) {
        this.llmProvider = llmProvider;
        this.userRepository = userRepository;
        this.zeroRecordRepository = zeroRecordRepository;
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.promptTemplateService = promptTemplateService;
        this.aiUsageLogService = aiUsageLogService;
        this.safetyBoundaryService = safetyBoundaryService;
        this.profileAiContextAssembler = profileAiContextAssembler;
    }

    @Transactional
    public ChatResponse sendMessage(Long userId, Long conversationId, String message) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        ConversationEntity conversation = resolveConversation(user, conversationId);
        messageRepository.save(new MessageEntity(conversation, MessageRole.USER, message.trim(), null));

        String reply = generateReply(user, conversation, message.trim());
        MessageEntity assistantMessage = messageRepository.save(new MessageEntity(
                conversation,
                MessageRole.ASSISTANT,
                reply,
                "COMPANION_REFLECTION"));
        conversation.touch();

        return new ChatResponse(conversation.getId(), assistantMessage.getId(), reply, SAFETY_NOTICE);
    }

    private ConversationEntity resolveConversation(UserEntity user, Long conversationId) {
        if (conversationId == null) {
            return conversationRepository.save(new ConversationEntity(user, "ZEROON Reflection"));
        }
        return conversationRepository.findByIdAndUserId(conversationId, user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Conversation not found"));
    }

    private String generateReply(UserEntity user, ConversationEntity conversation, String message) {
        long startedAt = System.nanoTime();
        SafetyBoundaryResult boundary = safetyBoundaryService.evaluate(message);
        if (boundary.blocked()) {
            aiUsageLogService.logRefusal(
                    user,
                    conversation,
                    boundary.label(),
                    message.length(),
                    boundary.reply().length(),
                    elapsedMillis(startedAt));
            return boundary.reply();
        }

        PromptTemplateSelection prompt = promptTemplateService.companionReflectionPrompt();
        String userPrompt = userPrompt(user, message);
        try {
            LlmResponse response = llmProvider.generate(new LlmRequest(
                    prompt.content(),
                    userPrompt,
                    Duration.ofSeconds(8)));
            aiUsageLogService.logSuccess(
                    user,
                    conversation,
                    response,
                    prompt,
                    userPrompt.length(),
                    elapsedMillis(startedAt));
            return response.content();
        } catch (LlmProviderUnavailableException ex) {
            aiUsageLogService.logFallback(
                    user,
                    conversation,
                    prompt,
                    userPrompt.length(),
                    FALLBACK_REPLY.length(),
                    elapsedMillis(startedAt),
                    ex.getClass().getSimpleName());
            return FALLBACK_REPLY;
        }
    }

    private long elapsedMillis(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000;
    }

    private String userPrompt(UserEntity user, String message) {
        List<ZeroRecordEntity> recentRecords = zeroRecordRepository
                .findByUserIdOrderByCreatedAtDesc(user.getId(), PageRequest.of(0, 3))
                .getContent();
        StringBuilder prompt = new StringBuilder();
        profileAiContextAssembler.assemble(user.getId())
                .ifPresent(profileContext -> prompt.append(profileContext).append("\n\n"));
        prompt.append("Current state: ").append(user.getCurrentState().name()).append('\n');
        prompt.append("User message: ").append(message).append('\n');
        prompt.append("Recent records:\n");
        for (ZeroRecordEntity record : recentRecords) {
            prompt.append("- ")
                    .append(record.getState().name())
                    .append(" | goal: ")
                    .append(orEmpty(record.getGoal()))
                    .append(" | content: ")
                    .append(orEmpty(record.getContent()))
                    .append('\n');
        }
        return prompt.toString();
    }

    private String orEmpty(String value) {
        if (value == null || value.isBlank()) {
            return "(empty)";
        }
        return value.strip();
    }
}
