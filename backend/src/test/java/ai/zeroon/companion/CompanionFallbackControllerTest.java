package ai.zeroon.companion;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.blankOrNullString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.AiUsageLogRepository;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.ai.LlmProviderUnavailableException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.LockSupport;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@SpringBootTest
@AutoConfigureMockMvc
class CompanionFallbackControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AiUsageLogRepository aiUsageLogRepository;

    @Autowired
    private UnavailableLlmProvider unavailableLlmProvider;

    @Test
    void companionMessageFallsBackWhenProviderIsUnavailable() throws Exception {
        String accessToken = login("13800138102");

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"Reflect on this record\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.conversationId").isNumber())
                .andExpect(jsonPath("$.messageId").isNumber())
                .andExpect(jsonPath("$.reply", containsString("慢慢放进可以回看的地方")))
                .andExpect(jsonPath("$.safetyNotice", not(blankOrNullString())));

        org.assertj.core.api.Assertions.assertThat(unavailableLlmProvider.wasTransactionActive()).isFalse();
        var logs = aiUsageLogRepository.findByUserIdOrderByCreatedAtDesc(1L);
        org.assertj.core.api.Assertions.assertThat(logs).hasSize(1);
        var usage = logs.get(0);
        org.assertj.core.api.Assertions.assertThat(usage.getOutcome()).isEqualTo(AiUsageOutcome.FALLBACK);
        org.assertj.core.api.Assertions.assertThat(usage.isFallbackUsed()).isTrue();
        org.assertj.core.api.Assertions.assertThat(usage.getProvider()).isEqualTo("openai-compatible");
        org.assertj.core.api.Assertions.assertThat(usage.getModel()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getDurationMs()).isPositive();
        org.assertj.core.api.Assertions.assertThat(usage.getPromptTemplateCode())
                .isEqualTo("COMPANION_REFLECTION");
        org.assertj.core.api.Assertions.assertThat(usage.getInputChars()).isPositive();
        org.assertj.core.api.Assertions.assertThat(usage.getOutputChars()).isPositive();
        org.assertj.core.api.Assertions.assertThat(usage.getInputTokens()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getOutputTokens()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getErrorCode())
                .isEqualTo("LlmProviderUnavailableException");
    }

    @Test
    void companionFallbackAndSafetyNoticeFollowEnglishRequestLanguage() throws Exception {
        String accessToken = login("13800138107");

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Accept-Language", "en-US,en;q=0.9")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"Reflect on this moment\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply", containsString("not be fully formed yet")))
                .andExpect(jsonPath("$.reply", not(containsString("慢慢放进"))))
                .andExpect(jsonPath("$.safetyNotice", containsString("non-diagnostic companion reflection")))
                .andExpect(jsonPath("$.safetyNotice", not(containsString("非诊断性"))));
    }

    private String login(String mobile) throws Exception {
        mockMvc.perform(post("/api/v1/auth/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mobile\":\"" + mobile + "\"}"))
                .andExpect(status().isAccepted());

        String body = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "mobile": "%s",
                                  "code": "000000",
                                  "deviceId": "companion-fallback-test"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("accessToken").asText();
    }

    @TestConfiguration
    static class CompanionFallbackTestConfig {

        @Bean
        @Primary
        UnavailableLlmProvider unavailableLlmProvider() {
            return new UnavailableLlmProvider();
        }
    }

    static class UnavailableLlmProvider implements LlmProvider {

        private final AtomicBoolean transactionActive = new AtomicBoolean();

        @Override
        public ai.zeroon.ai.LlmResponse generate(ai.zeroon.ai.LlmRequest request) {
            transactionActive.set(TransactionSynchronizationManager.isActualTransactionActive());
            LockSupport.parkNanos(Duration.ofMillis(10).toNanos());
            throw new LlmProviderUnavailableException("test provider unavailable");
        }

        boolean wasTransactionActive() {
            return transactionActive.get();
        }
    }
}
