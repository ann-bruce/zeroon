package ai.zeroon.auth;

import ai.zeroon.auth.AdminAuthDtos.AdminAuthResponse;
import ai.zeroon.auth.AdminAuthDtos.AdminPayload;
import ai.zeroon.security.TokenService;
import ai.zeroon.user.UserEntity;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;

@Service
public class AdminAuthService {

    private final AdminEmailVerificationCodeService verificationCodeService;
    private final AdminAccountProvisioningService provisioningService;
    private final AdminAuthAuditService auditService;
    private final TokenService tokenService;
    private final Set<String> allowedEmails;

    public AdminAuthService(
            AdminEmailVerificationCodeService verificationCodeService,
            AdminAccountProvisioningService provisioningService,
            AdminAuthAuditService auditService,
            TokenService tokenService,
            @Value("${zeroon.auth.admin-emails:}") String adminEmails) {
        this.verificationCodeService = verificationCodeService;
        this.provisioningService = provisioningService;
        this.auditService = auditService;
        this.tokenService = tokenService;
        this.allowedEmails = Arrays.stream(adminEmails.split(","))
                .map(this::normalizeEmail)
                .filter(value -> !value.isBlank())
                .collect(Collectors.toUnmodifiableSet());
    }

    public void requestCode(String email, String clientIp) {
        String normalizedEmail = normalizeEmail(email);
        boolean allowed = allowedEmails.contains(normalizedEmail);
        try {
            verificationCodeService.requestCode(normalizedEmail, clientIp, allowed);
            auditService.record(
                    null,
                    "ADMIN_AUTH_CODE_REQUESTED",
                    normalizedEmail,
                    Map.of("outcome", allowed ? "DELIVERED" : "IGNORED"));
        } catch (RuntimeException ex) {
            auditService.record(
                    null,
                    "ADMIN_AUTH_CODE_REQUEST_FAILED",
                    normalizedEmail,
                    Map.of("outcome", "FAILED"));
            throw ex;
        }
    }

    public AdminAuthResponse login(
            String email,
            String code,
            String deviceId,
            String clientIp) {
        String normalizedEmail = normalizeEmail(email);
        boolean codeValid;
        try {
            codeValid = verificationCodeService.verify(
                    normalizedEmail, code, deviceId, clientIp);
        } catch (RuntimeException ex) {
            auditService.record(
                    null,
                    "ADMIN_AUTH_LOGIN_FAILED",
                    normalizedEmail,
                    Map.of("outcome", "RATE_LIMITED_OR_UNAVAILABLE"));
            throw ex;
        }
        if (!allowedEmails.contains(normalizedEmail) || !codeValid) {
            auditService.record(
                    null,
                    "ADMIN_AUTH_LOGIN_FAILED",
                    normalizedEmail,
                    Map.of("outcome", "DENIED"));
            throw new BadCredentialsException("Invalid administrator credentials");
        }

        UserEntity admin = provisioningService.provision(normalizedEmail);
        TokenService.AccessToken accessToken = tokenService.createAdminAccessToken(admin);
        auditService.record(
                admin,
                "ADMIN_AUTH_LOGIN_SUCCEEDED",
                normalizedEmail,
                Map.of("outcome", "SUCCEEDED"));
        return new AdminAuthResponse(
                accessToken.token(),
                Duration.between(Instant.now(), accessToken.expiresAt()).toSeconds(),
                new AdminPayload(admin.getUid(), admin.getEmail()));
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
