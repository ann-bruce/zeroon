package ai.zeroon.auth;

import java.time.Duration;

public interface VerificationCodeStore {

    void store(String mobile, String code, Duration ttl);

    VerificationResult verify(String mobile, String code, int maxFailedAttempts);

    RateLimitDecision acquire(String scope, String subject, int limit, Duration window);

    enum VerificationResult {
        VALID,
        INVALID,
        ATTEMPTS_EXHAUSTED
    }

    record RateLimitDecision(boolean allowed, long retryAfterSeconds) {
    }
}
