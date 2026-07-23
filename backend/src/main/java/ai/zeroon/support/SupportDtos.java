package ai.zeroon.support;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public final class SupportDtos {

    private SupportDtos() {
    }

    public record CreateSupportRequest(
            @NotNull UUID clientSubmissionId,
            @NotNull SupportCategory category,
            @NotBlank @Size(max = 120) String subject,
            @NotBlank @Size(max = 4000) String description,
            @Size(max = 200) String replyContact,
            boolean diagnosticConsent,
            @Valid DiagnosticEnvelopeRequest diagnostics) {

        @AssertTrue(message = "Diagnostics require explicit consent")
        @JsonIgnore
        public boolean isDiagnosticConsentConsistent() {
            return diagnostics == null || diagnosticConsent;
        }

        @AssertTrue(message = "Support text contains an unsupported null character")
        @JsonIgnore
        public boolean hasSupportedText() {
            return excludesNull(subject) && excludesNull(description) && excludesNull(replyContact);
        }

        @JsonAnySetter
        void rejectUnknown(String name, Object value) {
            throw new IllegalArgumentException("Unknown support request property: " + name);
        }
    }

    public record AddSupportMessageRequest(
            @NotBlank @Size(max = 2000) String body) {

        @AssertTrue(message = "Support text contains an unsupported null character")
        @JsonIgnore
        public boolean hasSupportedText() {
            return excludesNull(body);
        }

        @JsonAnySetter
        void rejectUnknown(String name, Object value) {
            throw new IllegalArgumentException("Unknown support message property: " + name);
        }
    }

    public static final class DiagnosticEnvelopeRequest {

        @Size(max = 40)
        private String appVersion;

        @Size(max = 40)
        private String build;

        @Size(max = 30)
        private String platform;

        @Size(max = 40)
        private String osFamily;

        @Pattern(regexp = "^(zh-CN|en)$")
        private String locale;

        @Size(max = 80)
        @Pattern(regexp = "^[A-Za-z0-9._:-]*$")
        private String errorCode;

        private Instant timestamp;

        @JsonIgnore
        private final Map<String, Object> unknownProperties = new LinkedHashMap<>();

        @JsonAnySetter
        void captureUnknown(String name, Object value) {
            unknownProperties.put(name, value);
        }

        @AssertTrue(message = "Unknown diagnostic properties are not allowed")
        @JsonIgnore
        public boolean isAllowlisted() {
            return unknownProperties.isEmpty();
        }

        public String getAppVersion() {
            return appVersion;
        }

        public void setAppVersion(String appVersion) {
            this.appVersion = appVersion;
        }

        public String getBuild() {
            return build;
        }

        public void setBuild(String build) {
            this.build = build;
        }

        public String getPlatform() {
            return platform;
        }

        public void setPlatform(String platform) {
            this.platform = platform;
        }

        public String getOsFamily() {
            return osFamily;
        }

        public void setOsFamily(String osFamily) {
            this.osFamily = osFamily;
        }

        public String getLocale() {
            return locale;
        }

        public void setLocale(String locale) {
            this.locale = locale;
        }

        public String getErrorCode() {
            return errorCode;
        }

        public void setErrorCode(String errorCode) {
            this.errorCode = errorCode;
        }

        public Instant getTimestamp() {
            return timestamp;
        }

        public void setTimestamp(Instant timestamp) {
            this.timestamp = timestamp;
        }

        DiagnosticEnvelope toEnvelope() {
            return new DiagnosticEnvelope(
                    appVersion, build, platform, osFamily, locale, errorCode, timestamp);
        }
    }

    public record DiagnosticEnvelope(
            String appVersion,
            String build,
            String platform,
            String osFamily,
            String locale,
            String errorCode,
            Instant timestamp) {
    }

    public record SupportRequestSummary(
            String reference,
            SupportCategory category,
            SupportRequestStatus status,
            String subject,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record SupportRequestPage(
            List<SupportRequestSummary> items,
            int page,
            int size,
            long totalElements) {
    }

    public record SupportMessageResponse(
            Long id,
            SupportActorType actorType,
            String body,
            Instant createdAt) {
    }

    public record SupportStatusHistoryResponse(
            SupportRequestStatus fromStatus,
            SupportRequestStatus toStatus,
            SupportActorType actorType,
            Instant createdAt) {
    }

    public record SupportRequestDetail(
            String reference,
            SupportCategory category,
            SupportRequestStatus status,
            String subject,
            String description,
            String replyContact,
            DiagnosticEnvelope diagnostics,
            List<SupportMessageResponse> messages,
            List<SupportStatusHistoryResponse> statusHistory,
            Instant createdAt,
            Instant updatedAt,
            Instant closedAt) {
    }

    record CreateResult(SupportRequestDetail detail, boolean created) {
    }

    private static boolean excludesNull(String value) {
        return value == null || value.indexOf('\0') < 0;
    }
}
