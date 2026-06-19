package ai.zeroon.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class LocalFakeVerificationCodeSender implements VerificationCodeSender {

    private static final Logger log = LoggerFactory.getLogger(LocalFakeVerificationCodeSender.class);

    @Override
    public void send(String mobile, String code) {
        log.info("ZEROON local verification code for {} is {}", mobile, code);
    }
}
