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
class CompanionFallbackControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AiUsageLogRepository aiUsageLogRepository;

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
                .andExpect(jsonPath("$.reply", containsString("AI 反思暂时不可用")))
                .andExpect(jsonPath("$.safetyNotice", not(blankOrNullString())));

        var logs = aiUsageLogRepository.findByUserIdOrderByCreatedAtDesc(1L);
        org.assertj.core.api.Assertions.assertThat(logs).hasSize(1);
        org.assertj.core.api.Assertions.assertThat(logs.get(0).getOutcome()).isEqualTo(AiUsageOutcome.FALLBACK);
        org.assertj.core.api.Assertions.assertThat(logs.get(0).isFallbackUsed()).isTrue();
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
        LlmProvider unavailableLlmProvider() {
            return request -> {
                throw new LlmProviderUnavailableException("test provider unavailable");
            };
        }
    }
}
