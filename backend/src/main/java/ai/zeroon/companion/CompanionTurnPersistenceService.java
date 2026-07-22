package ai.zeroon.companion;

import ai.zeroon.ai.AiUsageDetails;
import ai.zeroon.ai.AiUsageLogService;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.memory.MemoryAiContextAssembler;
import ai.zeroon.profile.ProfileAiContextAssembler;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
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
    public String assembleUserPrompt(Long userId, String message) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        StringBuilder prompt = new StringBuilder();
        profileAiContextAssembler.assemble(userId)
                .ifPresent(profileContext -> prompt.append(profileContext).append("\n\n"));
        memoryAiContextAssembler.assemble(userId)
                .ifPresent(memoryContext -> prompt.append(memoryContext).append("\n\n"));
        prompt.append("Current state: ").append(user.getCurrentState().name()).append('\n');
        prompt.append("User message: ").append(message).append('\n');
        return prompt.toString();
    }

    @Transactional
    public ChatResponse complete(
            StartedTurn turn,
            String reply,
            String safetyNotice,
            AiUsageDetails usage) {
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
        return new ChatResponse(conversation.getId(), assistantMessage.getId(), reply, safetyNotice);
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
}
