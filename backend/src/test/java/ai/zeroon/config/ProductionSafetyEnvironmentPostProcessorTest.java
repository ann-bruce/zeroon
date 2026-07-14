package ai.zeroon.config;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.springframework.mock.env.MockEnvironment;

class ProductionSafetyEnvironmentPostProcessorTest {

    private final ProductionSafetyEnvironmentPostProcessor processor =
            new ProductionSafetyEnvironmentPostProcessor();
    private final SpringApplication application = new SpringApplication();

    @Test
    void nonProductionProfilesKeepDevelopmentDefaultsAvailable() {
        MockEnvironment environment = unsafeEnvironment();
        environment.setActiveProfiles("local");

        assertThatCode(() -> processor.postProcessEnvironment(environment, application))
                .doesNotThrowAnyException();
    }

    @Test
    void productionRejectsDevelopmentAccessTokenSecret() {
        MockEnvironment environment = safeProductionEnvironment()
                .withProperty(
                        "zeroon.auth.access-token-secret",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_ACCESS_TOKEN_SECRET);

        assertUnsafe(environment, "ZEROON_ACCESS_TOKEN_SECRET");
    }

    @Test
    void productionRejectsExampleAccessTokenSecret() {
        MockEnvironment environment = safeProductionEnvironment()
                .withProperty(
                        "zeroon.auth.access-token-secret",
                        ProductionSafetyEnvironmentPostProcessor.EXAMPLE_ACCESS_TOKEN_SECRET);

        assertUnsafe(environment, "ZEROON_ACCESS_TOKEN_SECRET");
    }

    @Test
    void productionRejectsDefaultDatabasePassword() {
        MockEnvironment environment = safeProductionEnvironment()
                .withProperty(
                        "spring.datasource.password",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_DATABASE_PASSWORD);

        assertUnsafe(environment, "POSTGRES_PASSWORD");
    }

    @Test
    void productionRejectsFixedVerificationCode() {
        MockEnvironment environment = safeProductionEnvironment()
                .withProperty(
                        "zeroon.auth.local-verification-code",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_VERIFICATION_CODE);

        assertUnsafe(environment, "ZEROON_LOCAL_VERIFICATION_CODE");
    }

    @Test
    void productionAcceptsExplicitNonDefaultSecrets() {
        MockEnvironment environment = safeProductionEnvironment();

        assertThatCode(() -> processor.postProcessEnvironment(environment, application))
                .doesNotThrowAnyException();
    }

    private MockEnvironment unsafeEnvironment() {
        return new MockEnvironment()
                .withProperty(
                        "zeroon.auth.access-token-secret",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_ACCESS_TOKEN_SECRET)
                .withProperty(
                        "spring.datasource.password",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_DATABASE_PASSWORD)
                .withProperty(
                        "zeroon.auth.local-verification-code",
                        ProductionSafetyEnvironmentPostProcessor.DEVELOPMENT_VERIFICATION_CODE);
    }

    private MockEnvironment safeProductionEnvironment() {
        MockEnvironment environment = new MockEnvironment()
                .withProperty(
                        "zeroon.auth.access-token-secret",
                        "this-is-a-test-only-production-secret-123456789")
                .withProperty(
                        "spring.datasource.password",
                        "test-only-database-password")
                .withProperty("zeroon.auth.local-verification-code", "729184");
        environment.setActiveProfiles("prod");
        return environment;
    }

    private void assertUnsafe(MockEnvironment environment, String environmentName) {
        assertThatThrownBy(() -> processor.postProcessEnvironment(environment, application))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Unsafe ZEROON production configuration")
                .hasMessageContaining(environmentName)
                .hasMessageNotContaining("test-only");
    }
}
