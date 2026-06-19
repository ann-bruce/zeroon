package ai.zeroon.companion;

import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.blankOrNullString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmRequest;
import ai.zeroon.ai.LlmResponse;
import ai.zeroon.ai.AiUsageLogRepository;
import ai.zeroon.ai.AiUsageOutcome;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Primary;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class CompanionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AiUsageLogRepository aiUsageLogRepository;

    @Test
    void companionMessageReturnsReflection() throws Exception {
        String accessToken = login("13800138101");
        createRecord(accessToken);

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"What should I notice today?\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.conversationId").isNumber())
                .andExpect(jsonPath("$.messageId").isNumber())
                .andExpect(jsonPath("$.reply").value("You made a small clear step."))
                .andExpect(jsonPath("$.safetyNotice", not(blankOrNullString())));

        var logs = aiUsageLogRepository.findByUserIdOrderByCreatedAtDesc(1L);
        org.assertj.core.api.Assertions.assertThat(logs).hasSize(1);
        org.assertj.core.api.Assertions.assertThat(logs.get(0).getOutcome()).isEqualTo(AiUsageOutcome.SUCCESS);
        org.assertj.core.api.Assertions.assertThat(logs.get(0).isFallbackUsed()).isFalse();
        org.assertj.core.api.Assertions.assertThat(logs.get(0).getInputChars()).isGreaterThan(0);
    }

    @Test
    void companionEndpointRequiresAuthentication() throws Exception {
        mockMvc.perform(post("/api/v1/companion/messages")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"hello\"}"))
                .andExpect(status().isUnauthorized());
    }

    private void createRecord(String accessToken) throws Exception {
        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "FOCUS",
                                  "mood": "clear",
                                  "goal": "finish one thing",
                                  "content": "I completed one task."
                                }
                                """))
                .andExpect(status().isCreated());
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
                                  "deviceId": "companion-test"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("accessToken").asText();
    }

    @TestConfiguration
    static class CompanionTestConfig {

        @Bean
        @Primary
        LlmProvider testLlmProvider() {
            return request -> {
                assertPromptContainsContext(request);
                return new LlmResponse("You made a small clear step.", "test", "test-model", "stop");
            };
        }

        private static void assertPromptContainsContext(LlmRequest request) {
            if (!request.systemPrompt().contains("long-term companion")
                    || !request.userPrompt().contains("Current state: CALM")
                    || !request.userPrompt().contains("I completed one task.")) {
                throw new AssertionError("Prompt does not contain expected state and record context");
            }
        }
    }
}
