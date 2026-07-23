package ai.zeroon.support;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;
import ai.zeroon.ai.LlmProvider;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.mockito.Mockito.verifyNoInteractions;

@SpringBootTest
@AutoConfigureMockMvc
class SupportAdminControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private SupportRetentionService supportRetentionService;

    @MockitoBean
    private LlmProvider llmProvider;

    @Test
    void adminEndpointsRequireAdminAuthority() throws Exception {
        String userToken = login("13700806201", "support-admin-normal")
                .path("accessToken").asText();

        mockMvc.perform(get("/api/v1/admin/support-requests"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/admin/support-requests")
                        .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isForbidden());
        mockMvc.perform(patch("/api/v1/admin/support-requests/ZS-NOT-FOUND")
                        .header("Authorization", "Bearer " + userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "assignToMe": true,
                                  "reasonCode": "TRIAGE_ACCEPTED"
                                }
                                """))
                .andExpect(status().isForbidden());
    }

    @Test
    void adminTriageReplyInternalNoteAndCloseAreBoundedAndAudited() throws Exception {
        JsonNode ownerSession = login("13700806202", "support-admin-owner");
        String ownerToken = ownerSession.path("accessToken").asText();
        JsonNode adminSession = loginAdmin("13700806203", "support-admin-operator");
        String adminToken = adminSession.path("accessToken").asText();
        String adminUid = adminSession.path("user").path("uid").asText();

        String createBody = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest()))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String reference = objectMapper.readTree(createBody).path("reference").asText();

        mockMvc.perform(get("/api/v1/admin/support-requests")
                        .header("Authorization", "Bearer " + adminToken)
                        .param("status", "RECEIVED")
                        .param("category", "PRODUCT_PROBLEM")
                        .param("escalated", "false"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].reference").value(reference))
                .andExpect(jsonPath("$.items[0].descriptionPreview")
                        .value("Private support description"))
                .andExpect(jsonPath("$.items[0].ownerUid").isNotEmpty())
                .andExpect(jsonPath("$.items[0].mobile").doesNotExist());

        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "category": "SUGGESTION",
                                  "status": "IN_REVIEW",
                                  "assignToMe": true,
                                  "escalated": true,
                                  "escalationCode": "ENGINEERING",
                                  "reasonCode": "TRIAGE_ACCEPTED"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("IN_REVIEW"))
                .andExpect(jsonPath("$.category").value("SUGGESTION"))
                .andExpect(jsonPath("$.assignedAdminUid").value(adminUid))
                .andExpect(jsonPath("$.escalated").value(true))
                .andExpect(jsonPath("$.escalationCode").value("ENGINEERING"))
                .andExpect(jsonPath("$.audit", hasSize(4)));

        mockMvc.perform(post("/api/v1/admin/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "body": "Internal reproduction note",
                                  "visibility": "INTERNAL",
                                  "reasonCode": "REPRODUCTION_CAPTURED"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.messages[0].visibility").value("INTERNAL"))
                .andExpect(jsonPath("$.messages[0].body").value("Internal reproduction note"))
                .andExpect(jsonPath("$.audit", hasSize(5)));

        mockMvc.perform(post("/api/v1/admin/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "body": "Please tell us which browser you used.",
                                  "visibility": "USER_VISIBLE",
                                  "nextStatus": "WAITING_FOR_USER",
                                  "reasonCode": "CLARIFICATION_REQUESTED"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("WAITING_FOR_USER"))
                .andExpect(jsonPath("$.messages", hasSize(2)))
                .andExpect(jsonPath("$.statusHistory", hasSize(3)))
                .andExpect(jsonPath("$.audit", hasSize(7)))
                .andExpect(jsonPath("$.audit[0].body").doesNotExist());

        String ownerDetail = mockMvc.perform(get("/api/v1/me/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("WAITING_FOR_USER"))
                .andExpect(jsonPath("$.messages", hasSize(1)))
                .andExpect(jsonPath("$.messages[0].body")
                        .value("Please tell us which browser you used."))
                .andExpect(jsonPath("$.audit").doesNotExist())
                .andExpect(jsonPath("$.assignedAdminUid").doesNotExist())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(ownerDetail).doesNotContain("Internal reproduction note");

        mockMvc.perform(post("/api/v1/admin/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "body": "We are closing this request. Create a new request if it continues.",
                                  "visibility": "USER_VISIBLE",
                                  "nextStatus": "CLOSED",
                                  "reasonCode": "HANDLING_ENDED"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("CLOSED"))
                .andExpect(jsonPath("$.closedAt").isNotEmpty());

        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "IN_REVIEW",
                                  "reasonCode": "REOPEN_ATTEMPTED"
                                }
                                """))
                .andExpect(status().isConflict());

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_admin_audit WHERE request_id = "
                        + "(SELECT id FROM support_requests WHERE public_reference = ?)",
                Long.class,
                reference)).isEqualTo(9);
        assertThat(jdbcTemplate.queryForList(
                "SELECT DISTINCT actor_user_id FROM support_admin_audit WHERE request_id = "
                        + "(SELECT id FROM support_requests WHERE public_reference = ?)",
                Long.class,
                reference)).containsExactly(
                        userRepository.findByMobile("13700806203").orElseThrow().getId());
        verifyNoInteractions(llmProvider);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM conversations WHERE user_id = "
                        + "(SELECT id FROM users WHERE mobile = '13700806202')",
                Long.class)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM memory_entries WHERE user_id = "
                        + "(SELECT id FROM users WHERE mobile = '13700806202')",
                Long.class)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM user_profiles WHERE user_id = "
                        + "(SELECT id FROM users WHERE mobile = '13700806202')",
                Long.class)).isZero();
    }

    @Test
    void adminMutationsRejectUnknownFieldsInvalidVisibilityAndArbitraryTransitions()
            throws Exception {
        String ownerToken = login("13700806204", "support-admin-invalid-owner")
                .path("accessToken").asText();
        String adminToken = loginAdmin("13700806205", "support-admin-invalid-operator")
                .path("accessToken").asText();
        String created = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest()))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String reference = objectMapper.readTree(created).path("reference").asText();

        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "REPLIED",
                                  "reasonCode": "ARBITRARY_SKIP"
                                }
                                """))
                .andExpect(status().isConflict());
        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "assignToMe": true,
                                  "recordText": "must not pass",
                                  "reasonCode": "TRIAGE_ACCEPTED"
                                }
                                """))
                .andExpect(status().isBadRequest());
        mockMvc.perform(post("/api/v1/admin/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "body": "Internal only",
                                  "visibility": "INTERNAL",
                                  "nextStatus": "IN_REVIEW",
                                  "reasonCode": "NOTE"
                                }
                                """))
                .andExpect(status().isBadRequest());
        mockMvc.perform(post("/api/v1/admin/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "body": "Visible reply",
                                  "visibility": "USER_VISIBLE",
                                  "reasonCode": "RESPONSE_SENT"
                                }
                                """))
                .andExpect(status().isBadRequest());
    }

    @Test
    void assignmentCannotBeTakenOrClearedByAnotherAdministrator() throws Exception {
        String ownerToken = login("13700806206", "support-assignment-owner")
                .path("accessToken").asText();
        String firstAdminToken = loginAdmin("13700806207", "support-assignment-first")
                .path("accessToken").asText();
        String secondAdminToken = loginAdmin("13700806208", "support-assignment-second")
                .path("accessToken").asText();
        String created = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest()))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String reference = objectMapper.readTree(created).path("reference").asText();

        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + firstAdminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "assignToMe": true,
                                  "reasonCode": "TRIAGE_ACCEPTED"
                                }
                                """))
                .andExpect(status().isOk());

        for (boolean assignToMe : new boolean[] {true, false}) {
            mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                            .header("Authorization", "Bearer " + secondAdminToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("""
                                    {
                                      "assignToMe": %s,
                                      "reasonCode": "ASSIGNMENT_UPDATED"
                                    }
                                    """.formatted(assignToMe)))
                    .andExpect(status().isConflict());
        }

        mockMvc.perform(patch("/api/v1/admin/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + firstAdminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "assignToMe": false,
                                  "reasonCode": "ASSIGNMENT_UPDATED"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.assignedAdminUid").doesNotExist());
    }

    @Test
    void retentionPurgesOnlyClosedRequestsOlderThanTheConfiguredMaximum()
            throws Exception {
        String ownerToken = login("13700806209", "support-retention-owner")
                .path("accessToken").asText();
        String adminToken = loginAdmin("13700806210", "support-retention-admin")
                .path("accessToken").asText();
        String expiredReference = createRequest(ownerToken, "Expired support");
        String recentReference = createRequest(ownerToken, "Recent support");
        String openReference = createRequest(ownerToken, "Open support");

        Instant now = Instant.now();
        jdbcTemplate.update(
                "UPDATE support_requests SET status = 'CLOSED', closed_at = ? "
                        + "WHERE public_reference = ?",
                now.minusSeconds(181L * 24 * 60 * 60),
                expiredReference);
        jdbcTemplate.update(
                "UPDATE support_requests SET status = 'CLOSED', closed_at = ? "
                        + "WHERE public_reference = ?",
                now.minusSeconds(179L * 24 * 60 * 60),
                recentReference);
        Long expiredId = jdbcTemplate.queryForObject(
                "SELECT id FROM support_requests WHERE public_reference = ?",
                Long.class,
                expiredReference);
        Long adminId = userRepository.findByMobile("13700806210").orElseThrow().getId();
        jdbcTemplate.update("""
                INSERT INTO support_messages (
                    request_id, actor_user_id, actor_type, visibility, body
                ) VALUES (?, ?, 'ADMIN', 'INTERNAL', 'retention cascade note')
                """, expiredId, adminId);
        jdbcTemplate.update("""
                INSERT INTO support_admin_audit (
                    request_id, actor_user_id, action_type, reason_code
                ) VALUES (?, ?, 'INTERNAL_NOTE', 'RETENTION_TEST')
                """, expiredId, adminId);

        assertThat(supportRetentionService.purgeExpiredClosedRequests()).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_requests WHERE public_reference = ?",
                Long.class,
                expiredReference)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_messages WHERE request_id = ?",
                Long.class,
                expiredId)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_admin_audit WHERE request_id = ?",
                Long.class,
                expiredId)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_requests WHERE public_reference IN (?, ?)",
                Long.class,
                recentReference,
                openReference)).isEqualTo(2);
        verifyNoInteractions(llmProvider);
    }

    private String validRequest() {
        return """
                {
                  "clientSubmissionId": "%s",
                  "category": "PRODUCT_PROBLEM",
                  "subject": "Admin handling test",
                  "description": "Private support description",
                  "diagnosticConsent": false
                }
                """.formatted(UUID.randomUUID());
    }

    private String createRequest(String ownerToken, String subject) throws Exception {
        String created = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest().replace(
                                "\"Admin lifecycle\"",
                                "\"" + subject + "\"")))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(created).path("reference").asText();
    }

    private JsonNode loginAdmin(String mobile, String deviceId) throws Exception {
        UserEntity admin = new UserEntity(
                "admin-support-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12),
                mobile);
        admin.grantRole(UserRole.ADMIN);
        userRepository.save(admin);
        return login(mobile, deviceId);
    }

    private JsonNode login(String mobile, String deviceId) throws Exception {
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
                                """.formatted(mobile, deviceId)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return objectMapper.readTree(body);
    }
}
