package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Duration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class VerificationCodeServiceTest {

    private final VerificationCodeSender sender = mock(VerificationCodeSender.class);
    private final VerificationCodeStore store = mock(VerificationCodeStore.class);
    private final VerificationCodeGenerator generator = () -> "729184";
    private VerificationCodeService service;

    @BeforeEach
    void setUp() {
        when(store.acquire(anyString(), anyString(), anyInt(), any(Duration.class)))
                .thenReturn(new VerificationCodeStore.RateLimitDecision(true, 0));
        service = new VerificationCodeService(
                sender,
                generator,
                store,
                10,
                60,
                5,
                20,
                10,
                30,
                15,
                5);
    }

    @Test
    void requestAppliesIpAndMobileLimitsBeforeSending() {
        service.requestCode("+8613800138000", "203.0.113.10");

        verify(store).acquire("code-request-ip-hour", "203.0.113.10", 20, Duration.ofHours(1));
        verify(store).acquire("code-request-mobile-hour", "+8613800138000", 5, Duration.ofHours(1));
        verify(store).acquire(
                "code-request-mobile-cooldown", "+8613800138000", 1, Duration.ofSeconds(60));
        verify(store).store("+8613800138000", "729184", Duration.ofMinutes(10));
        verify(sender).send("+8613800138000", "729184");
    }

    @Test
    void loginAppliesDeviceAndIpLimits() {
        when(store.verify("+8613800138001", "729184", 5))
                .thenReturn(VerificationCodeStore.VerificationResult.VALID);

        boolean valid = service.verify(
                "+8613800138001", "729184", "ios-device-1", "203.0.113.11");

        assertThat(valid).isTrue();
        verify(store).acquire("code-login-device", "ios-device-1", 10, Duration.ofMinutes(15));
        verify(store).acquire("code-login-ip", "203.0.113.11", 30, Duration.ofMinutes(15));
    }
}
