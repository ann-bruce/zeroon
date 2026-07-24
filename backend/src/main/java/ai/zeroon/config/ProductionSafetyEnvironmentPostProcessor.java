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
    static final String DEVELOPMENT_REDIS_PASSWORD = "change-me";

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
                "REDIS_PASSWORD",
                environment.getProperty("spring.data.redis.password"),
                12,
                Set.of(DEVELOPMENT_REDIS_PASSWORD));
        validateSharedRedisHost(environment.getProperty("spring.data.redis.host"));
        if (Boolean.parseBoolean(environment.getProperty("zeroon.auth.sms-enabled", "false"))) {
            validateHttpsUrl(
                    "ZEROON_VERIFICATION_CODE_SENDER_URL",
                    environment.getProperty("zeroon.auth.verification-code-sender-url"));
            validateSecret(
                    "ZEROON_VERIFICATION_CODE_SENDER_TOKEN",
                    environment.getProperty("zeroon.auth.verification-code-sender-token"),
                    16,
                    Set.of());
        }
        validateNonBlank("ZEROON_SMTP_HOST", environment.getProperty("spring.mail.host"));
        validateSecret(
                "ZEROON_SMTP_USERNAME",
                environment.getProperty("spring.mail.username"),
                3,
                Set.of());
        validateSecret(
                "ZEROON_SMTP_PASSWORD",
                environment.getProperty("spring.mail.password"),
                16,
                Set.of());
        validateEmailFrom(environment.getProperty("zeroon.auth.email-from"));
    }

    private void validateSharedRedisHost(String value) {
        if (value == null || value.isBlank()) {
            throw unsafe("REDIS_HOST", "is required");
        }
        if (Set.of("localhost", "127.0.0.1", "::1").contains(value.trim().toLowerCase())) {
            throw unsafe("REDIS_HOST", "must identify shared production storage");
        }
    }

    private void validateHttpsUrl(String environmentName, String value) {
        if (value == null || value.isBlank()) {
            throw unsafe(environmentName, "is required");
        }
        if (!value.startsWith("https://")) {
            throw unsafe(environmentName, "must use HTTPS");
        }
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

    private void validateNonBlank(String environmentName, String value) {
        if (value == null || value.isBlank()) {
            throw unsafe(environmentName, "is required");
        }
    }

    private void validateEmailFrom(String value) {
        if (value == null
                || value.isBlank()
                || !value.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw unsafe("ZEROON_EMAIL_FROM", "is required and must be an email address");
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
