package ai.zeroon.auth;

public interface EmailVerificationCodeSender {

    void send(String email, String code);
}
