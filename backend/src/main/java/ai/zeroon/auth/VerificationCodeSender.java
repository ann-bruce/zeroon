package ai.zeroon.auth;

public interface VerificationCodeSender {

    void send(String mobile, String code);
}
