package ai.zeroon.auth;

import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!prod & !smtp-smoke")
public class InMemoryVerificationCodeStore implements VerificationCodeStore {

    private final Map<String, CodeEntry> codes = new HashMap<>();
    private final Map<String, RateEntry> rates = new HashMap<>();

    @Override
    public synchronized void store(String mobile, String code, Duration ttl) {
        codes.put(VerificationCodeKeyFactory.code(mobile), new CodeEntry(code, 0, Instant.now().plus(ttl)));
    }

    @Override
    public synchronized VerificationResult verify(String mobile, String code, int maxFailedAttempts) {
        String key = VerificationCodeKeyFactory.code(mobile);
        CodeEntry entry = codes.get(key);
        Instant now = Instant.now();
        if (entry == null || !entry.expiresAt().isAfter(now)) {
            codes.remove(key);
            return VerificationResult.INVALID;
        }
        if (entry.code().equals(code)) {
            codes.remove(key);
            return VerificationResult.VALID;
        }
        int failedAttempts = entry.failedAttempts() + 1;
        if (failedAttempts >= maxFailedAttempts) {
            codes.remove(key);
            return VerificationResult.ATTEMPTS_EXHAUSTED;
        }
        codes.put(key, new CodeEntry(entry.code(), failedAttempts, entry.expiresAt()));
        return VerificationResult.INVALID;
    }

    @Override
    public synchronized RateLimitDecision acquire(
            String scope, String subject, int limit, Duration window) {
        String key = VerificationCodeKeyFactory.rate(scope, subject);
        Instant now = Instant.now();
        RateEntry entry = rates.get(key);
        if (entry == null || !entry.expiresAt().isAfter(now)) {
            rates.put(key, new RateEntry(1, now.plus(window)));
            return new RateLimitDecision(true, 0);
        }
        if (entry.count() >= limit) {
            return new RateLimitDecision(false, retryAfterSeconds(now, entry.expiresAt()));
        }
        rates.put(key, new RateEntry(entry.count() + 1, entry.expiresAt()));
        return new RateLimitDecision(true, 0);
    }

    private long retryAfterSeconds(Instant now, Instant expiresAt) {
        return Math.max(1, Duration.between(now, expiresAt).toSeconds());
    }

    private record CodeEntry(String code, int failedAttempts, Instant expiresAt) {
    }

    private record RateEntry(int count, Instant expiresAt) {
    }
}
