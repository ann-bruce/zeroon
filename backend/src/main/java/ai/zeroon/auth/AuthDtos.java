package ai.zeroon.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

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

    public record RefreshRequest(
            @NotBlank String refreshToken) {
    }

    public record AuthResponse(
            String accessToken,
            String refreshToken,
            long expiresIn,
            UserPayload user) {
    }

    public record UserPayload(
            Long id,
            String uid,
            String mobile,
            String currentState,
            String languagePreference) {
    }
}
