package ai.zeroon.config;

import java.util.Arrays;
import java.util.Set;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;

public class ProductionSafetyEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    static final String DEVELOPMENT_ACCESS_TOKEN_SECRET =
            "dev-only-change-this-secret-with-at-least-32-chars";
    static final String EXAMPLE_ACCESS_TOKEN_SECRET =
            "replace-with-at-least-32-random-bytes";
    static final String DEVELOPMENT_DATABASE_PASSWORD = "change-me";
    static final String DEVELOPMENT_VERIFICATION_CODE = "000000";

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        if (Arrays.stream(environment.getActiveProfiles()).noneMatch("prod"::equals)) {
            return;
        }

        validateSecret(
                "ZEROON_ACCESS_TOKEN_SECRET",
                environment.getProperty("zeroon.auth.access-token-secret"),
                32,
                Set.of(DEVELOPMENT_ACCESS_TOKEN_SECRET, EXAMPLE_ACCESS_TOKEN_SECRET));
        validateSecret(
                "POSTGRES_PASSWORD",
                environment.getProperty("spring.datasource.password"),
                12,
                Set.of(DEVELOPMENT_DATABASE_PASSWORD));
        validateSecret(
                "ZEROON_LOCAL_VERIFICATION_CODE",
                environment.getProperty("zeroon.auth.local-verification-code"),
                6,
                Set.of(DEVELOPMENT_VERIFICATION_CODE));
    }

    private void validateSecret(String environmentName, String value, int minimumLength, Set<String> disallowed) {
        if (value == null || value.isBlank()) {
            throw unsafe(environmentName, "is required");
        }
        if (value.length() < minimumLength) {
            throw unsafe(environmentName, "is too short");
        }
        if (disallowed.contains(value)) {
            throw unsafe(environmentName, "still uses a development or example value");
        }
    }

    private IllegalStateException unsafe(String environmentName, String reason) {
        return new IllegalStateException(
                "Unsafe ZEROON production configuration: " + environmentName + " " + reason);
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
