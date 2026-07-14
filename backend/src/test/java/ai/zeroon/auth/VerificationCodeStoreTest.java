package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import org.junit.jupiter.api.Test;

class VerificationCodeStoreTest {

    private final InMemoryVerificationCodeStore store = new InMemoryVerificationCodeStore();

    @Test
    void successfulVerificationConsumesCodeOnce() {
        store.store("13800138001", "729184", Duration.ofMinutes(10));

        assertThat(store.verify("13800138001", "729184", 5))
                .isEqualTo(VerificationCodeStore.VerificationResult.VALID);
        assertThat(store.verify("13800138001", "729184", 5))
                .isEqualTo(VerificationCodeStore.VerificationResult.INVALID);
    }

    @Test
    void failedAttemptLimitDeletesCode() {
        store.store("13800138002", "729184", Duration.ofMinutes(10));

        assertThat(store.verify("13800138002", "111111", 2))
                .isEqualTo(VerificationCodeStore.VerificationResult.INVALID);
        assertThat(store.verify("13800138002", "111111", 2))
                .isEqualTo(VerificationCodeStore.VerificationResult.ATTEMPTS_EXHAUSTED);
        assertThat(store.verify("13800138002", "729184", 2))
                .isEqualTo(VerificationCodeStore.VerificationResult.INVALID);
    }

    @Test
    void limiterReturnsRetryAfterWhenWindowIsFull() {
        assertThat(store.acquire("test", "device-a", 1, Duration.ofMinutes(1)).allowed()).isTrue();

        VerificationCodeStore.RateLimitDecision blocked =
                store.acquire("test", "device-a", 1, Duration.ofMinutes(1));

        assertThat(blocked.allowed()).isFalse();
        assertThat(blocked.retryAfterSeconds()).isPositive();
    }

    @Test
    void secureGeneratorAlwaysReturnsSixDigits() {
        SecureRandomVerificationCodeGenerator generator = new SecureRandomVerificationCodeGenerator();

        for (int sample = 0; sample < 100; sample++) {
            assertThat(generator.generate()).matches("^[0-9]{6}$");
        }
    }
}
