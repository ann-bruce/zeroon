package ai.zeroon.companion;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.ai.AiUsageLogRepository;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class CompanionSafetyBoundaryControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AiUsageLogRepository aiUsageLogRepository;

    @Test
    void safetyBoundaryReturnsRefusalWithoutCallingLlm() throws Exception {
        String accessToken = login("13800138103");

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Accept-Language", "en")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"Can you diagnose my depression?\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply", containsString("I can’t provide medical, legal, financial")))
                .andExpect(jsonPath("$.safetyNotice", containsString("non-diagnostic companion reflection")));

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Accept-Language", "zh-CN")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"我是不是抑郁症？\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply", containsString("不能替代医疗、法律、财务或心理诊断建议")))
                .andExpect(jsonPath("$.safetyNotice", containsString("非诊断性的陪伴式反思")));

        var logs = aiUsageLogRepository.findByUserIdOrderByCreatedAtDesc(1L);
        org.assertj.core.api.Assertions.assertThat(logs).hasSize(2);
        var usage = logs.get(0);
        org.assertj.core.api.Assertions.assertThat(usage.getOutcome()).isEqualTo(AiUsageOutcome.REFUSAL);
        org.assertj.core.api.Assertions.assertThat(usage.isFallbackUsed()).isTrue();
        org.assertj.core.api.Assertions.assertThat(usage.getProvider()).isEqualTo("safety-boundary");
        org.assertj.core.api.Assertions.assertThat(usage.getModel()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getDurationMs()).isNotNegative();
        org.assertj.core.api.Assertions.assertThat(usage.getPromptTemplateCode()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getPromptTemplateVersion()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getInputChars()).isPositive();
        org.assertj.core.api.Assertions.assertThat(usage.getOutputChars()).isPositive();
        org.assertj.core.api.Assertions.assertThat(usage.getInputTokens()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getOutputTokens()).isNull();
        org.assertj.core.api.Assertions.assertThat(usage.getErrorCode())
                .isEqualTo("PSYCHOLOGICAL_DIAGNOSIS");
        org.assertj.core.api.Assertions.assertThat(logs.get(1).getErrorCode())
                .isEqualTo("MEDICAL");
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
                                  "deviceId": "companion-safety-test"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("accessToken").asText();
    }

    @TestConfiguration
    static class SafetyBoundaryTestConfig {

        @Bean
        @Primary
        LlmProvider failingIfCalledLlmProvider() {
            return request -> {
                throw new AssertionError("LLM should not be called for safety boundary requests");
            };
        }
    }
}
