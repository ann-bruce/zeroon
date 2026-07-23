package ai.zeroon.companion;

import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.blankOrNullString;
import static org.hamcrest.Matchers.containsString;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmRequest;
import ai.zeroon.ai.LlmResponse;
import ai.zeroon.ai.AiUsageLogRepository;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.prompt.PromptTemplateEntity;
import ai.zeroon.prompt.PromptTemplateRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.LockSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Primary;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@SpringBootTest
@AutoConfigureMockMvc
class CompanionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AiUsageLogRepository aiUsageLogRepository;

    @Autowired
    private CapturingLlmProvider capturingLlmProvider;

    @Autowired
    private PromptTemplateRepository promptTemplateRepository;

    @BeforeEach
    void clearCapturedRequest() {
        capturingLlmProvider.clear();
    }

    @Test
    void companionMessageReturnsReflection() throws Exception {
        String accessToken = login("13800138101");
        createRecord(accessToken);
        promptTemplateRepository.save(new PromptTemplateEntity(
                "COMPANION_REFLECTION",
                "Transaction-safe companion prompt",
                "You are ZEROON, a long-term companion. Reply calmly.",
                true,
                7));

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Accept-Language", "en")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"What should I notice today?\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.conversationId").isNumber())
                .andExpect(jsonPath("$.messageId").isNumber())
                .andExpect(jsonPath("$.reply").value("You made a small clear step."))
                .andExpect(jsonPath("$.safetyNotice").value(
                        "ZEROON offers non-diagnostic companion reflection. "
                                + "It cannot replace medical, legal, financial, or mental health professionals."));

        LlmRequest request = capturingLlmProvider.requireRequest();
        assertThat(request.systemPrompt())
                .contains("long-term companion")
                .contains("Respond in English")
                .contains("Do not infer language from Profile, Memory, Records, conversation history");
        assertThat(request.userPrompt())
                .contains("Current state: CALM")
                .contains("What should I notice today?")
                .doesNotContain("Recent records")
                .doesNotContain("I completed one task.")
                .doesNotContain("finish one thing")
                .doesNotContain("User-allowed memory context");
        assertThat(capturingLlmProvider.wasTransactionActive()).isFalse();
        assertThat(capturingLlmProvider.wasUserMessageCommitted()).isTrue();

        var logs = aiUsageLogRepository.findByUserIdOrderByCreatedAtDesc(1L);
        assertThat(logs).hasSize(1);
        var usage = logs.get(0);
        assertThat(usage.getOutcome()).isEqualTo(AiUsageOutcome.SUCCESS);
        assertThat(usage.isFallbackUsed()).isFalse();
        assertThat(usage.getProvider()).isEqualTo("test");
        assertThat(usage.getModel()).isEqualTo("test-model");
        assertThat(usage.getDurationMs()).isPositive();
        assertThat(usage.getPromptTemplateCode()).isEqualTo("COMPANION_REFLECTION");
        assertThat(usage.getPromptTemplateVersion()).isEqualTo(7);
        assertThat(usage.getInputChars()).isGreaterThan(0);
        assertThat(usage.getOutputChars()).isEqualTo("You made a small clear step.".length());
        assertThat(usage.getInputTokens()).isEqualTo(37);
        assertThat(usage.getOutputTokens()).isEqualTo(9);
        assertThat(usage.getErrorCode()).isNull();

        String exportBody = mockMvc.perform(get("/api/v1/me/export")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String exportedUsage = objectMapper.readTree(exportBody).path("aiUsage").path(0).toString();
        assertThat(exportedUsage)
                .contains("\"inputTokens\":37")
                .contains("\"outputTokens\":9")
                .doesNotContain("What should I notice today?")
                .doesNotContain("You made a small clear step.");
    }

    @Test
    void companionEndpointRequiresAuthentication() throws Exception {
        mockMvc.perform(post("/api/v1/companion/messages")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"hello\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void companionLanguageUsesHeaderThenAccountThenChineseFallbackWithoutTranslatingContent()
            throws Exception {
        String englishAccountToken = login("13800138105");
        updateLanguage(englishAccountToken, "EN");

        String originalChinese = "原文保持不变。";
        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + englishAccountToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(java.util.Map.of("message", originalChinese))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply").value("You made a small clear step."))
                .andExpect(jsonPath("$.safetyNotice", containsString("non-diagnostic companion reflection")));
        assertThat(capturingLlmProvider.requireRequest().systemPrompt()).contains("Respond in English");
        assertThat(capturingLlmProvider.requireRequest().userPrompt()).contains("User message: " + originalChinese);

        String originalEnglish = "Keep this exact sentence.";
        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + englishAccountToken)
                        .header("Accept-Language", "fr;q=1, zh-CN;q=0.8, en;q=0.5")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(java.util.Map.of("message", originalEnglish))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply").value("你迈出了清晰的一小步。"))
                .andExpect(jsonPath("$.safetyNotice", containsString("非诊断性的陪伴式反思")));
        assertThat(capturingLlmProvider.requireRequest().systemPrompt())
                .contains("Respond in Simplified Chinese");
        assertThat(capturingLlmProvider.requireRequest().userPrompt())
                .contains("User message: " + originalEnglish);

        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + englishAccountToken)
                        .header("Accept-Language", "fr-FR, zh-Hant")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"Unsupported headers use the account preference.\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply").value("You made a small clear step."));
        assertThat(capturingLlmProvider.requireRequest().systemPrompt()).contains("Respond in English");

        String export = mockMvc.perform(get("/api/v1/me/export")
                        .header("Authorization", "Bearer " + englishAccountToken))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(export).contains(originalChinese).contains(originalEnglish);

        String followSystemToken = login("13800138106");
        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + followSystemToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"English text must not be used to infer language.\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reply").value("你迈出了清晰的一小步。"));
        assertThat(capturingLlmProvider.requireRequest().systemPrompt())
                .contains("Respond in Simplified Chinese");
    }

    @Test
    void profileContextFollowsCurrentConsentAndUsesOnlyAllowedFields() throws Exception {
        String accessToken = login("13800138104");

        saveProfile(accessToken, false);
        sendMessage(accessToken, "Consent is currently off");
        assertProfileContextAbsent(capturingLlmProvider.requireRequest());

        saveProfile(accessToken, true);
        sendMessage(accessToken, "Consent is now on");
        LlmRequest enabledRequest = capturingLlmProvider.requireRequest();
        assertThat(enabledRequest.userPrompt())
                .contains("User-provided profile context")
                .contains("- Nickname: River")
                .contains("- Age range: 25_34")
                .contains("- Occupation or identity: Product designer")
                .contains("- Self-description: I notice quiet changes over time.")
                .contains("Do not diagnose, label, or infer fixed traits.")
                .doesNotContain("MOON");

        saveProfile(accessToken, false);
        sendMessage(accessToken, "Consent is off again");
        assertProfileContextAbsent(capturingLlmProvider.requireRequest());
    }

    private void saveProfile(String accessToken, boolean enabled) throws Exception {
        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "nickname": "River",
                                  "avatarPreset": "MOON",
                                  "ageRange": "25_34",
                                  "occupation": "Product designer",
                                  "selfDescription": "I notice quiet changes over time.",
                                  "aiProfileContextEnabled": %s
                                }
                                """.formatted(enabled)))
                .andExpect(status().isOk());
    }

    private void sendMessage(String accessToken, String message) throws Exception {
        mockMvc.perform(post("/api/v1/companion/messages")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"message\":\"" + message + "\"}"))
                .andExpect(status().isOk());
    }

    private void updateLanguage(String accessToken, String preference) throws Exception {
        mockMvc.perform(put("/api/v1/me/preferences/language")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"languagePreference\":\"" + preference + "\"}"))
                .andExpect(status().isOk());
    }

    private void assertProfileContextAbsent(LlmRequest request) {
        assertThat(request.userPrompt())
                .doesNotContain("User-provided profile context")
                .doesNotContain("River")
                .doesNotContain("25_34")
                .doesNotContain("MOON")
                .doesNotContain("Product designer")
                .doesNotContain("I notice quiet changes over time.");
    }

    private void createRecord(String accessToken) throws Exception {
        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "FOCUS",
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
        CapturingLlmProvider testLlmProvider(JdbcTemplate jdbcTemplate) {
            return new CapturingLlmProvider(jdbcTemplate);
        }
    }

    static class CapturingLlmProvider implements LlmProvider {

        private final AtomicReference<LlmRequest> lastRequest = new AtomicReference<>();
        private final AtomicBoolean transactionActive = new AtomicBoolean();
        private final AtomicBoolean userMessageCommitted = new AtomicBoolean();
        private final JdbcTemplate jdbcTemplate;

        CapturingLlmProvider(JdbcTemplate jdbcTemplate) {
            this.jdbcTemplate = jdbcTemplate;
        }

        @Override
        public LlmResponse generate(LlmRequest request) {
            transactionActive.set(TransactionSynchronizationManager.isActualTransactionActive());
            Long storedMessages = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM messages WHERE content = ?",
                    Long.class,
                    "What should I notice today?");
            userMessageCommitted.set(storedMessages != null && storedMessages > 0);
            LockSupport.parkNanos(Duration.ofMillis(10).toNanos());
            lastRequest.set(request);
            String reply = request.systemPrompt().contains("Respond in Simplified Chinese")
                    ? "你迈出了清晰的一小步。"
                    : "You made a small clear step.";
            return new LlmResponse(
                    reply,
                    "test",
                    "test-model",
                    "stop",
                    37,
                    9);
        }

        LlmRequest requireRequest() {
            LlmRequest request = lastRequest.get();
            if (request == null) {
                throw new AssertionError("Expected the fake provider to capture a request");
            }
            return request;
        }

        void clear() {
            lastRequest.set(null);
            transactionActive.set(false);
            userMessageCommitted.set(false);
        }

        boolean wasTransactionActive() {
            return transactionActive.get();
        }

        boolean wasUserMessageCommitted() {
            return userMessageCommitted.get();
        }
    }
}
