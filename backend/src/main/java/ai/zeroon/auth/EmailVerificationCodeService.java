package ai.zeroon.auth;

import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class EmailVerificationCodeService {

    private final EmailVerificationCodeSender sender;
    private final VerificationCodeGenerator generator;
    private final VerificationCodeStore store;
    private final Duration ttl;
    private final Duration cooldown;
    private final int hourlyLimit;
    private final int ipHourlyLimit;
    private final int deviceLoginLimit;
    private final int ipLoginLimit;
    private final Duration loginWindow;
    private final int maxFailedAttempts;

    public EmailVerificationCodeService(
            EmailVerificationCodeSender sender,
            VerificationCodeGenerator generator,
            VerificationCodeStore store,
            @Value("${zeroon.auth.email-verification-code-ttl-minutes:10}") long ttlMinutes,
            @Value("${zeroon.auth.email-verification-code-request-cooldown-seconds:60}") long cooldownSeconds,
            @Value("${zeroon.auth.email-verification-code-hourly-limit:5}") int hourlyLimit,
            @Value("${zeroon.auth.email-verification-code-ip-hourly-limit:20}") int ipHourlyLimit,
            @Value("${zeroon.auth.email-verification-code-device-login-limit:10}") int deviceLoginLimit,
            @Value("${zeroon.auth.email-verification-code-ip-login-limit:30}") int ipLoginLimit,
            @Value("${zeroon.auth.email-verification-code-login-window-minutes:15}") long loginWindowMinutes,
            @Value("${zeroon.auth.email-verification-code-max-failed-attempts:5}") int maxFailedAttempts) {
        this.sender = sender;
        this.generator = generator;
        this.store = store;
        this.ttl = Duration.ofMinutes(ttlMinutes);
        this.cooldown = Duration.ofSeconds(cooldownSeconds);
        this.hourlyLimit = hourlyLimit;
        this.ipHourlyLimit = ipHourlyLimit;
        this.deviceLoginLimit = deviceLoginLimit;
        this.ipLoginLimit = ipLoginLimit;
        this.loginWindow = Duration.ofMinutes(loginWindowMinutes);
        this.maxFailedAttempts = maxFailedAttempts;
    }

    public void requestCode(String email, String clientIp) {
        limit("email-code-request-ip-hour", clientIp, ipHourlyLimit, Duration.ofHours(1));
        limit("email-code-request-hour", email, hourlyLimit, Duration.ofHours(1));
        limit("email-code-request-cooldown", email, 1, cooldown);
        String code = generator.generate();
        store.store(email, code, ttl);
        sender.send(email, code);
    }

    public boolean verify(String email, String code, String deviceId, String clientIp) {
        limit("email-code-login-device", deviceId, deviceLoginLimit, loginWindow);
        limit("email-code-login-ip", clientIp, ipLoginLimit, loginWindow);
        VerificationCodeStore.VerificationResult result = store.verify(email, code, maxFailedAttempts);
        if (result == VerificationCodeStore.VerificationResult.ATTEMPTS_EXHAUSTED) {
            throw new RateLimitExceededException(
                    "verification_attempts_exhausted",
                    "Too many invalid verification-code attempts; request a new code",
                    ttl.toSeconds());
        }
        return result == VerificationCodeStore.VerificationResult.VALID;
    }

    private void limit(String scope, String subject, int maximum, Duration window) {
        VerificationCodeStore.RateLimitDecision decision = store.acquire(scope, subject, maximum, window);
        if (!decision.allowed()) {
            throw new RateLimitExceededException(
                    "rate_limited",
                    "Too many verification-code requests; try again later",
                    decision.retryAfterSeconds());
        }
    }
}
