package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Duration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class EmailVerificationCodeServiceTest {

    private final EmailVerificationCodeSender sender = mock(EmailVerificationCodeSender.class);
    private final VerificationCodeStore store = mock(VerificationCodeStore.class);
    private final VerificationCodeGenerator generator = () -> "729184";
    private EmailVerificationCodeService service;

    @BeforeEach
    void setUp() {
        when(store.acquire(anyString(), anyString(), anyInt(), any(Duration.class)))
                .thenReturn(new VerificationCodeStore.RateLimitDecision(true, 0));
        service = new EmailVerificationCodeService(
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
    void requestAppliesIpEmailAndCooldownLimitsBeforeSending() {
        service.requestCode("person@example.com", "203.0.113.10");

        verify(store).acquire(
                "email-code-request-ip-hour", "203.0.113.10", 20, Duration.ofHours(1));
        verify(store).acquire(
                "email-code-request-hour", "person@example.com", 5, Duration.ofHours(1));
        verify(store).acquire(
                "email-code-request-cooldown", "person@example.com", 1, Duration.ofSeconds(60));
        verify(store).store("person@example.com", "729184", Duration.ofMinutes(10));
        verify(sender).send("person@example.com", "729184");
    }

    @Test
    void loginAppliesDeviceAndIpLimitsAndConsumesAValidCode() {
        when(store.verify("person@example.com", "729184", 5))
                .thenReturn(VerificationCodeStore.VerificationResult.VALID);

        boolean valid = service.verify(
                "person@example.com", "729184", "install-device-1", "203.0.113.11");

        assertThat(valid).isTrue();
        verify(store).acquire(
                "email-code-login-device", "install-device-1", 10, Duration.ofMinutes(15));
        verify(store).acquire(
                "email-code-login-ip", "203.0.113.11", 30, Duration.ofMinutes(15));
    }

    @Test
    void exhaustedAttemptsReturnARateLimitInsteadOfAuthenticating() {
        when(store.verify("person@example.com", "123456", 5))
                .thenReturn(VerificationCodeStore.VerificationResult.ATTEMPTS_EXHAUSTED);

        assertThatThrownBy(() -> service.verify(
                        "person@example.com", "123456", "install-device-1", "203.0.113.11"))
                .isInstanceOf(RateLimitExceededException.class)
                .hasMessageContaining("Too many invalid");
    }
}
