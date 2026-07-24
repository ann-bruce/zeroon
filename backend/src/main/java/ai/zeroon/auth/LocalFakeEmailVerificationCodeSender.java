package ai.zeroon.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!prod & !smtp-smoke")
public class LocalFakeEmailVerificationCodeSender implements EmailVerificationCodeSender {

    private static final Logger log = LoggerFactory.getLogger(LocalFakeEmailVerificationCodeSender.class);

    @Override
    public void send(String email, String code) {
        log.info("ZEROON local email verification code for {} is {}", email, code);
    }
}
