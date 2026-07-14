package ai.zeroon.auth;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

final class VerificationCodeKeyFactory {

    private VerificationCodeKeyFactory() {
    }

    static String code(String mobile) {
        return "zeroon:auth:code:" + digest(mobile);
    }

    static String rate(String scope, String subject) {
        return "zeroon:auth:rate:" + scope + ":" + digest(subject);
    }

    private static String digest(String value) {
        try {
            return HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is unavailable", ex);
        }
    }
}
