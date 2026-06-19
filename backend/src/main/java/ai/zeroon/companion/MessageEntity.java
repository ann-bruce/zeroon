package ai.zeroon.companion;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "messages")
public class MessageEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "conversation_id", nullable = false)
    private ConversationEntity conversation;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private MessageRole role;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "token_count", nullable = false)
    private int tokenCount;

    @Column(name = "safety_label", length = 50)
    private String safetyLabel;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    protected MessageEntity() {
    }

    public MessageEntity(
            ConversationEntity conversation,
            MessageRole role,
            String content,
            String safetyLabel) {
        this.conversation = conversation;
        this.role = role;
        this.content = content;
        this.safetyLabel = safetyLabel;
    }

    public Long getId() {
        return id;
    }
}
