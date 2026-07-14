package ai.zeroon.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.data.redis.connection.RedisPassword;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.StringRedisTemplate;

@EnabledIfEnvironmentVariable(named = "ZEROON_REDIS_INTEGRATION_TEST", matches = "true")
class RedisVerificationCodeStoreIntegrationTest {

    @Test
    void codeAndRateStateAreSharedAcrossStoreInstances() {
        RedisStandaloneConfiguration configuration =
                new RedisStandaloneConfiguration("127.0.0.1", 6379);
        configuration.setPassword(RedisPassword.of("change-me"));
        LettuceConnectionFactory connectionFactory = new LettuceConnectionFactory(configuration);
        connectionFactory.afterPropertiesSet();
        connectionFactory.start();

        try {
            StringRedisTemplate firstTemplate = template(connectionFactory);
            StringRedisTemplate secondTemplate = template(connectionFactory);
            RedisVerificationCodeStore first = new RedisVerificationCodeStore(firstTemplate);
            RedisVerificationCodeStore second = new RedisVerificationCodeStore(secondTemplate);
            String subject = "+86139" + UUID.randomUUID().toString().replace("-", "").substring(0, 8);

            first.store(subject, "729184", Duration.ofMinutes(1));

            assertThat(second.verify(subject, "729184", 5))
                    .isEqualTo(VerificationCodeStore.VerificationResult.VALID);
            assertThat(first.verify(subject, "729184", 5))
                    .isEqualTo(VerificationCodeStore.VerificationResult.INVALID);
            assertThat(first.acquire("integration", subject, 1, Duration.ofMinutes(1)).allowed())
                    .isTrue();
            assertThat(second.acquire("integration", subject, 1, Duration.ofMinutes(1)).allowed())
                    .isFalse();
        } finally {
            connectionFactory.destroy();
        }
    }

    private StringRedisTemplate template(LettuceConnectionFactory connectionFactory) {
        StringRedisTemplate template = new StringRedisTemplate(connectionFactory);
        template.afterPropertiesSet();
        return template;
    }
}
