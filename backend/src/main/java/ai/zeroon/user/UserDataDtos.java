package ai.zeroon.user;

import ai.zeroon.evidence.EvidenceDtos.EvidenceEventExport;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceExport;
import java.time.Instant;
import java.util.List;

public final class UserDataDtos {

    private UserDataDtos() {
    }

    public record CurrentUserResponse(
            String uid,
            String mobile,
            String email,
            String currentState,
            String status,
            List<String> roles,
            String languagePreference,
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
            List<SupportRequestExport> supportRequests,
            EvidencePreferenceExport betaEvidencePreference,
            List<EvidenceEventExport> betaEvidenceEvents,
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
            boolean enabled,
            boolean aiContextEnabled,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record SupportRequestExport(
            String reference,
            String category,
            String status,
            String subject,
            String description,
            String replyContact,
            SupportDiagnosticExport diagnostics,
            List<SupportMessageExport> messages,
            List<SupportStatusExport> statusHistory,
            Instant createdAt,
            Instant updatedAt,
            Instant closedAt) {
    }

    public record SupportDiagnosticExport(
            String appVersion,
            String build,
            String platform,
            String osFamily,
            String locale,
            String errorCode,
            Instant timestamp) {
    }

    public record SupportMessageExport(
            String actorType,
            String body,
            Instant createdAt) {
    }

    public record SupportStatusExport(
            String fromStatus,
            String toStatus,
            String actorType,
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
            Integer inputTokens,
            Integer outputTokens,
            String errorCode,
            Instant createdAt) {
    }
}
