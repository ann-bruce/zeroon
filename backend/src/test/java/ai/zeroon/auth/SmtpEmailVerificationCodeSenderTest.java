package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

class SmtpEmailVerificationCodeSenderTest {

    private final JavaMailSender mailSender = mock(JavaMailSender.class);
    private final SmtpEmailVerificationCodeSender sender =
            new SmtpEmailVerificationCodeSender(mailSender, "hello@zeroon.example", 7);

    @Test
    void sendsABilingualMessageWithTheConfiguredExpiry() {
        sender.send("person@example.com", "729184");

        ArgumentCaptor<SimpleMailMessage> message = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(message.capture());
        assertThat(message.getValue().getFrom()).isEqualTo("hello@zeroon.example");
        assertThat(message.getValue().getTo()).containsExactly("person@example.com");
        assertThat(message.getValue().getSubject()).contains("ZEROON").contains("登录验证码");
        assertThat(message.getValue().getText())
                .contains("729184")
                .contains("7 minutes")
                .contains("7 分钟");
    }

    @Test
    void mapsMailFailureToTheFailClosedDeliveryError() {
        doThrow(new MailSendException("unavailable"))
                .when(mailSender)
                .send(any(SimpleMailMessage.class));

        assertThatThrownBy(() -> sender.send("person@example.com", "729184"))
                .isInstanceOf(VerificationCodeDeliveryException.class)
                .hasMessage("Verification code delivery is temporarily unavailable");
    }
}
