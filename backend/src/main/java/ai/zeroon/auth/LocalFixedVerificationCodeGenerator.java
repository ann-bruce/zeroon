package ai.zeroon.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!prod & !smtp-smoke")
public class LocalFixedVerificationCodeGenerator implements VerificationCodeGenerator {

    private final String code;

    public LocalFixedVerificationCodeGenerator(
            @Value("${zeroon.auth.local-verification-code:000000}") String code) {
        this.code = code;
    }

    @Override
    public String generate() {
        return code;
    }
}
