package ai.zeroon.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public final class AuthDtos {

    private AuthDtos() {
    }

    public record CodeRequest(
            @NotBlank @Pattern(regexp = "^\\+?[0-9]{8,20}$") String mobile) {
    }

    public record LoginRequest(
            @NotBlank @Pattern(regexp = "^\\+?[0-9]{8,20}$") String mobile,
            @NotBlank String code,
            @NotBlank String deviceId) {
    }

    public record EmailCodeRequest(@NotBlank @Email @Size(max = 100) String email) {
    }

    public record EmailLoginRequest(
            @NotBlank @Email @Size(max = 100) String email,
            @NotBlank @Pattern(regexp = "^[0-9]{6}$") String code,
            @NotBlank @Size(min = 8, max = 128) String deviceId) {
    }

    public record RefreshRequest(
            @NotBlank String refreshToken) {
    }

    public record AuthResponse(
            String accessToken,
            String refreshToken,
            long expiresIn,
            boolean newAccount,
            UserPayload user) {
    }

    public record UserPayload(
            Long id,
            String uid,
            String mobile,
            String email,
            String currentState,
            String languagePreference) {
    }
}
