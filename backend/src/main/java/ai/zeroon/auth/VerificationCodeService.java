package ai.zeroon.auth;

import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class VerificationCodeService {

    private final VerificationCodeSender sender;
    private final VerificationCodeGenerator generator;
    private final VerificationCodeStore store;
    private final Duration ttl;
    private final Duration requestCooldown;
    private final int mobileHourlyLimit;
    private final int ipHourlyLimit;
    private final int deviceLoginLimit;
    private final int ipLoginLimit;
    private final Duration loginWindow;
    private final int maxFailedAttempts;

    public VerificationCodeService(
            VerificationCodeSender sender,
            VerificationCodeGenerator generator,
            VerificationCodeStore store,
            @Value("${zeroon.auth.verification-code-ttl-minutes:10}") long ttlMinutes,
            @Value("${zeroon.auth.verification-code-request-cooldown-seconds:60}") long requestCooldownSeconds,
            @Value("${zeroon.auth.verification-code-mobile-hourly-limit:5}") int mobileHourlyLimit,
            @Value("${zeroon.auth.verification-code-ip-hourly-limit:20}") int ipHourlyLimit,
            @Value("${zeroon.auth.verification-code-device-login-limit:10}") int deviceLoginLimit,
            @Value("${zeroon.auth.verification-code-ip-login-limit:30}") int ipLoginLimit,
            @Value("${zeroon.auth.verification-code-login-window-minutes:15}") long loginWindowMinutes,
            @Value("${zeroon.auth.verification-code-max-failed-attempts:5}") int maxFailedAttempts) {
        this.sender = sender;
        this.generator = generator;
        this.store = store;
        this.ttl = Duration.ofMinutes(ttlMinutes);
        this.requestCooldown = Duration.ofSeconds(requestCooldownSeconds);
        this.mobileHourlyLimit = mobileHourlyLimit;
        this.ipHourlyLimit = ipHourlyLimit;
        this.deviceLoginLimit = deviceLoginLimit;
        this.ipLoginLimit = ipLoginLimit;
        this.loginWindow = Duration.ofMinutes(loginWindowMinutes);
        this.maxFailedAttempts = maxFailedAttempts;
    }

    public void requestCode(String mobile, String clientIp) {
        enforceRateLimit("code-request-ip-hour", clientIp, ipHourlyLimit, Duration.ofHours(1));
        enforceRateLimit("code-request-mobile-hour", mobile, mobileHourlyLimit, Duration.ofHours(1));
        enforceRateLimit("code-request-mobile-cooldown", mobile, 1, requestCooldown);

        String code = generator.generate();
        store.store(mobile, code, ttl);
        sender.send(mobile, code);
    }

    public boolean verify(String mobile, String code, String deviceId, String clientIp) {
        enforceRateLimit("code-login-device", deviceId, deviceLoginLimit, loginWindow);
        enforceRateLimit("code-login-ip", clientIp, ipLoginLimit, loginWindow);

        VerificationCodeStore.VerificationResult result = store.verify(mobile, code, maxFailedAttempts);
        if (result == VerificationCodeStore.VerificationResult.ATTEMPTS_EXHAUSTED) {
            throw new RateLimitExceededException(
                    "verification_attempts_exhausted",
                    "Too many invalid verification-code attempts; request a new code",
                    ttl.toSeconds());
        }
        return result == VerificationCodeStore.VerificationResult.VALID;
    }

    private void enforceRateLimit(String scope, String subject, int limit, Duration window) {
        VerificationCodeStore.RateLimitDecision decision = store.acquire(scope, subject, limit, window);
        if (!decision.allowed()) {
            throw new RateLimitExceededException(
                    "rate_limited",
                    "Too many verification-code requests; try again later",
                    decision.retryAfterSeconds());
        }
    }
}
