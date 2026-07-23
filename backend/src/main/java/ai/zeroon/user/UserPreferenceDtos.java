package ai.zeroon.user;

import jakarta.validation.constraints.NotNull;

public final class UserPreferenceDtos {

    private UserPreferenceDtos() {
    }

    public record LanguagePreferenceRequest(
            @NotNull LanguagePreference languagePreference) {
    }

    public record LanguagePreferenceResponse(
            LanguagePreference languagePreference) {
    }
}
