package ai.zeroon.auth;

public class VerificationCodeInfrastructureException extends RuntimeException {

    public VerificationCodeInfrastructureException(Throwable cause) {
        super("Verification service is temporarily unavailable", cause);
    }
}
