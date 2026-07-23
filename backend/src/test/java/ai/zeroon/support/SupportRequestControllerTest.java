package ai.zeroon.support;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(properties = {
    "zeroon.support.request-hourly-limit=2",
    "zeroon.support.message-hourly-limit=2"
})
@AutoConfigureMockMvc
class SupportRequestControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void endpointsRequireAuthentication() throws Exception {
        mockMvc.perform(post("/api/v1/support/requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(UUID.randomUUID(), "Need help")))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/me/support-requests"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/me/support-requests/ZS-NOT-OWNED"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/v1/me/support-requests/ZS-NOT-OWNED/messages")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"follow up\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void createListDetailAndFollowUpRemainOwnerScoped() throws Exception {
        String ownerToken = login("13700806101", "support-owner").path("accessToken").asText();
        String otherToken = login("13700806102", "support-other").path("accessToken").asText();
        UUID submissionId = UUID.randomUUID();

        String createdBody = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(submissionId, "Login is not working")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reference").value(org.hamcrest.Matchers.matchesPattern(
                        "^ZS-[A-F0-9]{20}$")))
                .andExpect(jsonPath("$.category").value("PRODUCT_PROBLEM"))
                .andExpect(jsonPath("$.status").value("RECEIVED"))
                .andExpect(jsonPath("$.description").value("Private support description"))
                .andExpect(jsonPath("$.diagnostics.locale").value("en"))
                .andExpect(jsonPath("$.statusHistory[0].toStatus").value("RECEIVED"))
                .andExpect(jsonPath("$.messages").isEmpty())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String reference = objectMapper.readTree(createdBody).path("reference").asText();

        mockMvc.perform(get("/api/v1/me/support-requests")
                        .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(1))
                .andExpect(jsonPath("$.items[0].reference").value(reference))
                .andExpect(jsonPath("$.items[0].description").doesNotExist());

        mockMvc.perform(get("/api/v1/me/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isNotFound());

        mockMvc.perform(post("/api/v1/me/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"Here is one more detail.\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.actorType").value("USER"))
                .andExpect(jsonPath("$.body").value("Here is one more detail."));

        mockMvc.perform(get("/api/v1/me/support-requests/{reference}", reference)
                        .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.messages[0].body").value("Here is one more detail."));
    }

    @Test
    void createIsIdempotentAndRejectsSubmissionIdReuseWithDifferentContent() throws Exception {
        String token = login("13700806103", "support-idempotency").path("accessToken").asText();
        UUID submissionId = UUID.randomUUID();
        String request = validRequest(submissionId, "Same request");

        String first = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(request))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String second = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(request))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(objectMapper.readTree(first).path("reference").asText())
                .isEqualTo(objectMapper.readTree(second).path("reference").asText());
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM support_requests WHERE client_submission_id = ?",
                Long.class,
                submissionId.toString())).isEqualTo(1);

        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(submissionId, "Changed request")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("conflict"));
    }

    @Test
    void diagnosticsAreOptInAllowlistedAndBounded() throws Exception {
        String token = login("13700806104", "support-diagnostics").path("accessToken").asText();

        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientSubmissionId": "%s",
                                  "category": "OTHER",
                                  "subject": "Diagnostics without consent",
                                  "description": "Body",
                                  "diagnosticConsent": false,
                                  "diagnostics": {"locale": "en"}
                                }
                                """.formatted(UUID.randomUUID())))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientSubmissionId": "%s",
                                  "category": "OTHER",
                                  "subject": "Unknown diagnostic",
                                  "description": "Body",
                                  "diagnosticConsent": true,
                                  "diagnostics": {"locale": "en", "recordText": "must not pass"}
                                }
                                """.formatted(UUID.randomUUID())))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientSubmissionId": "%s",
                                  "category": "OTHER",
                                  "subject": "Unknown top level",
                                  "description": "Body",
                                  "diagnosticConsent": false,
                                  "recordText": "must not pass"
                                }
                                """.formatted(UUID.randomUUID())))
                .andExpect(status().isBadRequest());
    }

    @Test
    void creationRateLimitReturnsRetryAfterWithoutBreakingIdempotentRetry() throws Exception {
        String token = login("13700806105", "support-rate").path("accessToken").asText();
        UUID firstId = UUID.randomUUID();
        String firstRequest = validRequest(firstId, "First");

        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(firstRequest))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(firstRequest))
                .andExpect(status().isOk());
        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(UUID.randomUUID(), "Second")))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(UUID.randomUUID(), "Third")))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().exists("Retry-After"))
                .andExpect(jsonPath("$.error").value("support_rate_limited"));
    }

    @Test
    void followUpRateLimitReturnsRetryAfter() throws Exception {
        String token = login("13700806107", "support-message-rate")
                .path("accessToken").asText();
        String body = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(UUID.randomUUID(), "Follow-up rate")))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String reference = objectMapper.readTree(body).path("reference").asText();

        for (String message : new String[] {"First detail", "Second detail"}) {
            mockMvc.perform(post("/api/v1/me/support-requests/{reference}/messages", reference)
                            .header("Authorization", "Bearer " + token)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"body\":\"" + message + "\"}"))
                    .andExpect(status().isCreated());
        }
        mockMvc.perform(post("/api/v1/me/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"Third detail\"}"))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().exists("Retry-After"))
                .andExpect(jsonPath("$.error").value("support_rate_limited"));
    }

    @Test
    void closedRequestsRejectFollowUp() throws Exception {
        String token = login("13700806106", "support-closed").path("accessToken").asText();
        String body = mockMvc.perform(post("/api/v1/support/requests")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRequest(UUID.randomUUID(), "Close me")))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String reference = objectMapper.readTree(body).path("reference").asText();
        jdbcTemplate.update(
                "UPDATE support_requests SET status = 'CLOSED', closed_at = CURRENT_TIMESTAMP "
                        + "WHERE public_reference = ?",
                reference);

        mockMvc.perform(post("/api/v1/me/support-requests/{reference}/messages", reference)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"late follow up\"}"))
                .andExpect(status().isConflict());
    }

    private String validRequest(UUID submissionId, String subject) {
        return """
                {
                  "clientSubmissionId": "%s",
                  "category": "PRODUCT_PROBLEM",
                  "subject": "%s",
                  "description": "Private support description",
                  "replyContact": "reply@example.test",
                  "diagnosticConsent": true,
                  "diagnostics": {
                    "appVersion": "1.0.0",
                    "build": "42",
                    "platform": "web",
                    "osFamily": "macOS",
                    "locale": "en",
                    "errorCode": "AUTH.RETRY",
                    "timestamp": "2026-07-23T00:00:00Z"
                  }
                }
                """.formatted(submissionId, subject);
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
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(body);
    }
}
