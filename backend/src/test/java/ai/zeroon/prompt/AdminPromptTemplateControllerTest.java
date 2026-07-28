package ai.zeroon.prompt;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;
import ai.zeroon.security.TokenService;
import java.time.Instant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class AdminPromptTemplateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PromptTemplateRepository promptTemplateRepository;

    @Autowired
    private PromptActivationRepository promptActivationRepository;

    @Autowired
    private PromptAdminAuditRepository promptAdminAuditRepository;

    @Autowired
    private PromptEvaluationRepository promptEvaluationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenService tokenService;

    @BeforeEach
    void cleanPrompts() {
        promptAdminAuditRepository.deleteAll();
        promptEvaluationRepository.deleteAll();
        promptActivationRepository.deleteAll();
        promptTemplateRepository.deleteAll();
    }

    @Test
    void adminCanListAndReadPromptTemplates() throws Exception {
        PromptTemplateEntity template = promptTemplateRepository.save(new PromptTemplateEntity(
                "COMPANION_REFLECTION",
                "Companion Reflection",
                "Stay brief and non-diagnostic.",
                true,
                1));
        promptActivationRepository.save(new PromptActivationEntity(
                template,
                null,
                Instant.parse("2026-07-27T00:00:00Z")));
        String token = loginAdmin("admin-prompt-list", "13800138101");

        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(template.getId()))
                .andExpect(jsonPath("$.items[0].code").value("COMPANION_REFLECTION"))
                .andExpect(jsonPath("$.items[0].version").value(1))
                .andExpect(jsonPath("$.items[0].reviewStatus").value("APPROVED"))
                .andExpect(jsonPath("$.items[0].active").value(true));

        mockMvc.perform(get("/api/v1/admin/prompts/{promptId}", template.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(template.getId()))
                .andExpect(jsonPath("$.content").value("Stay brief and non-diagnostic."));
    }

    @Test
    void promptLifecycleRequiresIndependentReviewAndSupportsRollback() throws Exception {
        String creatorToken = loginAdmin("admin-prompt-creator", "13800138102");
        String reviewerToken = loginAdmin("admin-prompt-reviewer", "13800138103");

        long firstId = createPrompt(
                creatorToken,
                "Companion Persona V1",
                "First reviewed prompt.",
                1);

        activate(firstId, creatorToken, "PREMATURE_ACTIVATION")
                .andExpect(status().isConflict());
        review(firstId, creatorToken, "APPROVE", "SELF_REVIEW_ATTEMPT")
                .andExpect(status().isConflict());
        review(firstId, reviewerToken, "APPROVE", "INDEPENDENT_REVIEW")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reviewStatus").value("APPROVED"))
                .andExpect(jsonPath("$.reviewedByUid").value("admin-prompt-reviewer"));
        activate(firstId, creatorToken, "MISSING_EVALUATION")
                .andExpect(status().isConflict());
        recordPassingEvaluation(firstId, reviewerToken)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.latestEvaluation.passed").value(true))
                .andExpect(jsonPath("$.audit[*].action", hasItem("EVALUATION_PASSED")));
        activate(firstId, creatorToken, "INITIAL_ACTIVATION")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.active").value(true))
                .andExpect(jsonPath("$.audit[*].action", hasItem("ACTIVATE")));

        long secondId = createPrompt(
                creatorToken,
                "Companion Persona V2",
                "Second reviewed prompt.",
                2);
        review(secondId, reviewerToken, "APPROVE", "INDEPENDENT_REVIEW")
                .andExpect(status().isOk());
        recordPassingEvaluation(secondId, reviewerToken)
                .andExpect(status().isOk());
        activate(secondId, creatorToken, "PERSONA_V2_ACTIVATION")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.active").value(true));

        activate(firstId, creatorToken, "PERSONA_V2_ROLLBACK")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.version").value(1))
                .andExpect(jsonPath("$.active").value(true))
                .andExpect(jsonPath("$.audit[*].action", hasItem("ROLLBACK")));

        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + creatorToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(2)))
                .andExpect(jsonPath("$.items[0].version").value(2))
                .andExpect(jsonPath("$.items[0].active").value(false))
                .andExpect(jsonPath("$.items[1].version").value(1))
                .andExpect(jsonPath("$.items[1].active").value(true));
    }

    @Test
    void rejectedPromptCannotBeActivatedOrReviewedTwice() throws Exception {
        String creatorToken = loginAdmin("admin-prompt-rejected", "13800138104");
        String reviewerToken = loginAdmin("admin-prompt-reject-reviewer", "13800138105");
        long promptId = createPrompt(
                creatorToken,
                "Rejected Persona",
                "This version should not run.",
                1);

        review(promptId, reviewerToken, "REJECT", "FAILED_PRODUCT_REVIEW")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reviewStatus").value("REJECTED"))
                .andExpect(jsonPath("$.enabled").value(false));
        review(promptId, reviewerToken, "APPROVE", "SECOND_REVIEW_ATTEMPT")
                .andExpect(status().isConflict());
        activate(promptId, creatorToken, "REJECTED_ACTIVATION_ATTEMPT")
                .andExpect(status().isConflict());
        recordPassingEvaluation(promptId, reviewerToken)
                .andExpect(status().isConflict());
    }

    @Test
    void failedOrSingleReviewerEvaluationCannotUnlockForwardActivation() throws Exception {
        String creatorToken = loginAdmin("admin-eval-creator", "13800138107");
        String evaluatorToken = loginAdmin("admin-eval-reviewer", "13800138108");
        long promptId = createPrompt(
                creatorToken,
                "Persona evaluation gate",
                "A candidate prompt.",
                1);
        review(promptId, evaluatorToken, "APPROVE", "INDEPENDENT_REVIEW")
                .andExpect(status().isOk());

        recordEvaluation(promptId, evaluatorToken, 1, 1.74, true, "Product A", "Engineer B")
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.latestEvaluation.passed").value(false));
        activate(promptId, creatorToken, "FAILED_EVALUATION")
                .andExpect(status().isConflict());
        recordEvaluation(promptId, evaluatorToken, 0, 2.0, true, "Same Person", "same person")
                .andExpect(status().isConflict());
    }

    @Test
    void promptAdminRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/admin/prompts"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/v1/admin/prompts")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validCreateBody("Unauthorized", "prompt")))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void normalUserCannotAccessPromptAdmin() throws Exception {
        String token = login("normal-prompt-user", "13800138106");

        mockMvc.perform(get("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
        mockMvc.perform(post("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validCreateBody("Forbidden", "prompt")))
                .andExpect(status().isForbidden());
    }

    private long createPrompt(
            String token,
            String name,
            String content,
            int expectedVersion) throws Exception {
        String response = mockMvc.perform(post("/api/v1/admin/prompts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validCreateBody(name, content)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.version").value(expectedVersion))
                .andExpect(jsonPath("$.reviewStatus").value("PENDING"))
                .andExpect(jsonPath("$.active").value(false))
                .andReturn()
                .getResponse()
                .getContentAsString();
        return Long.parseLong(response.split("\"id\":")[1].split(",")[0]);
    }

    private org.springframework.test.web.servlet.ResultActions review(
            long promptId,
            String token,
            String decision,
            String reasonCode) throws Exception {
        return mockMvc.perform(post("/api/v1/admin/prompts/{promptId}/review", promptId)
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {"decision":"%s","reasonCode":"%s"}
                        """.formatted(decision, reasonCode)));
    }

    private org.springframework.test.web.servlet.ResultActions activate(
            long promptId,
            String token,
            String reasonCode) throws Exception {
        return mockMvc.perform(post("/api/v1/admin/prompts/{promptId}/activate", promptId)
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {"reasonCode":"%s"}
                        """.formatted(reasonCode)));
    }

    private org.springframework.test.web.servlet.ResultActions recordPassingEvaluation(
            long promptId,
            String token) throws Exception {
        return recordEvaluation(promptId, token, 0, 1.80, true, "Product Reviewer", "Engineering Reviewer");
    }

    private org.springframework.test.web.servlet.ResultActions recordEvaluation(
            long promptId,
            String token,
            int hardFailureCount,
            double averageScore,
            boolean bilingualReviewed,
            String productReviewer,
            String engineeringReviewer) throws Exception {
        return mockMvc.perform(post("/api/v1/admin/prompts/{promptId}/evaluations", promptId)
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "corpusVersion": "PERSONA_V2_V1",
                          "modelAlias": "RELEASE_MODEL",
                          "hardFailureCount": %d,
                          "safetyScore": 2,
                          "consentScore": 2,
                          "privacyScore": 2,
                          "minimumDimensionScore": 1,
                          "averageScore": %.2f,
                          "bilingualReviewed": %s,
                          "productReviewer": "%s",
                          "engineeringReviewer": "%s",
                          "defectCategories": "STYLE_MINOR",
                          "reasonCode": "PERSONA_V2_EVALUATION"
                        }
                        """.formatted(
                        hardFailureCount,
                        averageScore,
                        bilingualReviewed,
                        productReviewer,
                        engineeringReviewer)));
    }

    private String validCreateBody(String name, String content) {
        return """
                {
                  "code": "COMPANION_REFLECTION",
                  "name": "%s",
                  "content": "%s",
                  "reasonCode": "PERSONA_GOVERNANCE_TEST"
                }
                """.formatted(name, content);
    }

    private String loginAdmin(String uid, String mobile) throws Exception {
        UserEntity admin = new UserEntity(uid, mobile);
        admin.grantRole(UserRole.ADMIN);
        userRepository.save(admin);
        return tokenService.createAdminAccessToken(admin).token();
    }

    private String login(String uid, String mobile) throws Exception {
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
                                    "deviceId": "%s"
                                  }
                                  """.formatted(mobile, uid)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
