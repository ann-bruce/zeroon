package ai.zeroon.auth;

public class VerificationCodeDeliveryException extends RuntimeException {

    public VerificationCodeDeliveryException(Throwable cause) {
        super("Verification code delivery is temporarily unavailable", cause);
    }
}
