package ai.zeroon.user;

import java.time.Instant;
import java.util.List;

public final class UserDataDtos {

    private UserDataDtos() {
    }

    public record CurrentUserResponse(
            String uid,
            String mobile,
            String currentState,
            String status,
            List<String> roles,
            Instant createdAt) {
    }

    public record UserDataExportResponse(
            String schemaVersion,
            Instant exportedAt,
            CurrentUserResponse account,
            ProfileExport profile,
            ZeroonCompanionExport zeroonCompanion,
            List<SessionExport> sessions,
            List<StateChangeExport> stateHistory,
            List<StateSessionExport> stateSessions,
            List<ZeroRecordExport> records,
            List<ConversationExport> conversations,
            List<MemoryEntryExport> memoryEntries,
            List<AiUsageExport> aiUsage) {
    }

    public record ProfileExport(
            String nickname,
            String avatarPreset,
            String ageRange,
            String occupation,
            String selfDescription,
            boolean aiProfileContextEnabled,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record ZeroonCompanionExport(
            String companionKey,
            String displayName,
            String nameplateSerial,
            Instant metAt) {
    }

    public record SessionExport(
            String deviceId,
            Instant expiresAt,
            Instant revokedAt,
            Instant createdAt) {
    }

    public record StateChangeExport(
            String previousState,
            String currentState,
            String source,
            Instant createdAt) {
    }

    public record StateSessionExport(
            Long id,
            String state,
            String source,
            Instant startedAt,
            Instant endedAt,
            Long endedByRecordId) {
    }

    public record ZeroRecordExport(
            Long id,
            String state,
            String goal,
            String content,
            String aiSummary,
            Long stateSessionId,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record ConversationExport(
            Long id,
            String title,
            Instant createdAt,
            Instant updatedAt,
            List<MessageExport> messages) {
    }

    public record MessageExport(
            Long id,
            String role,
            String content,
            String safetyLabel,
            Instant createdAt) {
    }

    public record MemoryEntryExport(
            Long id,
            String type,
            String title,
            String summary,
            short importance,
            String sourceType,
            Long sourceId,
            Instant expiresAt,
            Instant createdAt) {
    }

    public record AiUsageExport(
            String provider,
            String model,
            String operation,
            String outcome,
            boolean fallbackUsed,
            int durationMs,
            String promptTemplateCode,
            Integer promptTemplateVersion,
            int inputChars,
            int outputChars,
            String errorCode,
            Instant createdAt) {
    }
}
