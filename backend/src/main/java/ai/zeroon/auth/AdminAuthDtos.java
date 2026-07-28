package ai.zeroon.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public final class AdminAuthDtos {

    private AdminAuthDtos() {
    }

    public record AdminEmailCodeRequest(
            @NotBlank @Email @Size(max = 100) String email) {
    }

    public record AdminEmailLoginRequest(
            @NotBlank @Email @Size(max = 100) String email,
            @NotBlank @Pattern(regexp = "^[0-9]{6}$") String code,
            @NotBlank @Size(min = 8, max = 128) String deviceId) {
    }

    public record AdminAuthResponse(
            String accessToken,
            long expiresIn,
            AdminPayload admin) {
    }

    public record AdminPayload(
            String uid,
            String email) {
    }
}
