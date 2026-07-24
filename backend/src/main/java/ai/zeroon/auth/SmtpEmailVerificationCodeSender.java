package ai.zeroon.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

@Component
@Profile({"prod", "smtp-smoke"})
public class SmtpEmailVerificationCodeSender implements EmailVerificationCodeSender {

    private final JavaMailSender mailSender;
    private final String from;
    private final long ttlMinutes;

    public SmtpEmailVerificationCodeSender(
            JavaMailSender mailSender,
            @Value("${zeroon.auth.email-from}") String from,
            @Value("${zeroon.auth.email-verification-code-ttl-minutes:10}") long ttlMinutes) {
        this.mailSender = mailSender;
        this.from = from;
        this.ttlMinutes = ttlMinutes;
    }

    @Override
    public void send(String email, String code) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(email);
            message.setSubject("ZEROON verification code / 登录验证码");
            message.setText("""
                    Your ZEROON verification code is %s. It expires in %d minutes.
                    If this was not you, you can ignore this email.

                    你的 ZEROON 登录验证码是 %s，%d 分钟内有效。
                    如果不是你本人操作，可以忽略这封邮件。
                    """.formatted(code, ttlMinutes, code, ttlMinutes));
            mailSender.send(message);
        } catch (MailException ex) {
            throw new VerificationCodeDeliveryException(ex);
        }
    }
}
