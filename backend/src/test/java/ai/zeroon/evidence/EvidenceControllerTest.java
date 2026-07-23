package ai.zeroon.evidence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDate;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.util.UUID;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class EvidenceControllerTest {

    private static final String NOTICE_VERSION = "beta-evidence-v1";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private EvidenceRetentionService retentionService;

    @Test
    void evidenceEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/me/preferences/beta-evidence"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(preference(true, NOTICE_VERSION)))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/v1/evidence/events")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void collectionDefaultsOffRequiresCurrentNoticeAndCreatesNoDisabledEvent() throws Exception {
        String token = login("13700806001", "evidence-default");

        mockMvc.perform(get("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true))
                .andExpect(jsonPath("$.enabled").value(false))
                .andExpect(jsonPath("$.requiredNoticeVersion").value(NOTICE_VERSION))
                .andExpect(jsonPath("$.acceptedNoticeVersion").doesNotExist())
                .andExpect(jsonPath("$.choiceChangedAt").doesNotExist());

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stored").value(false))
                .andExpect(jsonPath("$.duplicate").value(false));

        assertThat(subjectCount("13700806001")).isZero();
        assertThat(eventCount("13700806001")).isZero();

        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(preference(true, "old-notice")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("bad_request"));

        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "enabled": true,
                                  "noticeVersion": "beta-evidence-v1",
                                  "privateContent": "must not be accepted"
                                }
                                """))
                .andExpect(status().isBadRequest());
    }

    @Test
    void storesOnlyTypedAllowedPropertiesAndEnforcesIdempotency() throws Exception {
        String token = login("13700806002", "evidence-contract");
        enable(token);
        UUID eventId = UUID.randomUUID();

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(eventId, true)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.stored").value(true))
                .andExpect(jsonPath("$.duplicate").value(false))
                .andExpect(jsonPath("$.eventName").value("RECORD_SAVED"));

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(eventId, true)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stored").value(true))
                .andExpect(jsonPath("$.duplicate").value(true));

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(eventId, false)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("conflict"));

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)
                                .replace("\"retryCountBucket\": \"ZERO\"",
                                        "\"retryCountBucket\": \"ZERO\", \"appVersion\": \"1.0.0\"")))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)
                                .replace("\"retryCountBucket\": \"ZERO\"",
                                        "\"retryCountBucket\": \"ZERO\", \"content\": \"private\"")))
                .andExpect(status().isBadRequest());

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)
                                .replace("\"latencyBucket\": \"UNDER_500_MS\",\n", "")))
                .andExpect(status().isBadRequest());

        assertThat(eventCount("13700806002")).isEqualTo(1);
    }

    @Test
    void disablingStopsNewEventsAndReenablingDoesNotBackfill() throws Exception {
        String token = login("13700806003", "evidence-disable");
        enable(token);
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isCreated());

        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(preference(false, NOTICE_VERSION)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(false));

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stored").value(false));

        enable(token);
        assertThat(eventCount("13700806003")).isEqualTo(1);
    }

    @Test
    void exportIsOwnerScopedAndDeletionHardDeletesEvidence() throws Exception {
        String ownerToken = login("13700806004", "evidence-owner");
        String otherToken = login("13700806005", "evidence-other");
        enable(ownerToken);
        enable(otherToken);

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(ownerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(otherToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), false)))
                .andExpect(status().isCreated());

        String export = mockMvc.perform(get("/api/v1/me/export")
                        .header("Authorization", bearer(ownerToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.schemaVersion").value("zeroon-beta-export-v4"))
                .andExpect(jsonPath("$.betaEvidencePreference.enabled").value(true))
                .andExpect(jsonPath("$.betaEvidencePreference.acceptedNoticeVersion")
                        .value(NOTICE_VERSION))
                .andExpect(jsonPath("$.betaEvidenceEvents.length()").value(1))
                .andExpect(jsonPath("$.betaEvidenceEvents[0].eventName").value("RECORD_SAVED"))
                .andExpect(jsonPath("$.betaEvidenceEvents[0].properties.hasContent").value(true))
                .andReturn()
                .getResponse()
                .getContentAsString();

        assertThat(export)
                .doesNotContain("subjectUuid")
                .doesNotContain("eventFingerprint")
                .doesNotContain("privateContent");

        Long ownerId = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE mobile = '13700806004'", Long.class);
        Long otherId = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE mobile = '13700806005'", Long.class);
        Long subjectId = jdbcTemplate.queryForObject(
                "SELECT id FROM evidence_subjects WHERE user_id = ?", Long.class, ownerId);
        mockMvc.perform(delete("/api/v1/me/deletion")
                        .header("Authorization", bearer(ownerToken)))
                .andExpect(status().isNoContent());

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM evidence_subjects WHERE user_id = ?",
                Long.class,
                ownerId)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM evidence_events WHERE subject_id = ?",
                Long.class,
                subjectId)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM evidence_subjects WHERE user_id = ?",
                Long.class,
                otherId)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM evidence_events event
                JOIN evidence_subjects subject ON subject.id = event.subject_id
                WHERE subject.user_id = ?
                """, Long.class, otherId)).isEqualTo(1);
    }

    @Test
    void retentionPurgesExpiredEventsThenStaleSubjectsAndKeepsRecentEvidence() throws Exception {
        String expiredToken = login("13700806006", "evidence-expired");
        String recentToken = login("13700806007", "evidence-recent");
        enable(expiredToken);
        enable(recentToken);
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(expiredToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(recentToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(recordSaved(UUID.randomUUID(), true)))
                .andExpect(status().isCreated());

        Instant expiredAt = Instant.now().minus(Duration.ofDays(181));
        Long expiredUserId = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE mobile = '13700806006'", Long.class);
        Long expiredSubjectId = jdbcTemplate.queryForObject(
                "SELECT id FROM evidence_subjects WHERE user_id = ?",
                Long.class,
                expiredUserId);
        jdbcTemplate.update(
                "UPDATE evidence_events SET received_at = ? WHERE subject_id = ?",
                expiredAt,
                expiredSubjectId);
        jdbcTemplate.update(
                "UPDATE evidence_subjects SET choice_changed_at = ? WHERE id = ?",
                expiredAt,
                expiredSubjectId);

        EvidenceRetentionService.PurgeResult result = retentionService.purgeExpiredEvidence();

        assertThat(result.events()).isPositive();
        assertThat(result.subjects()).isPositive();
        assertThat(subjectCount("13700806006")).isZero();
        assertThat(eventCount("13700806006")).isZero();
        assertThat(subjectCount("13700806007")).isEqualTo(1);
        assertThat(eventCount("13700806007")).isEqualTo(1);
    }

    @Test
    void everyApprovedEventNameAcceptsOnlyItsReviewedTypedShape() throws Exception {
        String token = login("13700806008", "evidence-dictionary");
        enable(token);
        List<EventCase> cases = List.of(
                new EventCase("AUTH_COMPLETED",
                        "\"accountType\":\"NEW\",\"platform\":\"WEB\",\"appVersion\":\"1.0.0\""),
                new EventCase("ZEROON_ENCOUNTER_VIEWED",
                        "\"entrySource\":\"LOGIN\",\"appVersion\":\"1.0.0\""),
                new EventCase("ZEROON_ENCOUNTER_COMPLETED",
                        "\"durationBucket\":\"UNDER_10_SECONDS\",\"retryCountBucket\":\"ZERO\""),
                new EventCase("STATE_STARTED",
                        "\"state\":\"FOCUS\",\"source\":\"MANUAL\""),
                new EventCase("RESET_STARTED",
                        "\"entrySource\":\"NOW\",\"activeStatePresent\":true"),
                new EventCase("RECORD_SAVED",
                        "\"state\":\"CALM\",\"hasGoal\":true,\"hasContent\":true,"
                                + "\"latencyBucket\":\"UNDER_500_MS\",\"retryCountBucket\":\"ZERO\""),
                new EventCase("RECORD_SAVE_FAILED",
                        "\"errorClass\":\"NETWORK\",\"retryable\":true,\"networkStatus\":\"OFFLINE\""),
                new EventCase("ARCHIVE_VIEWED",
                        "\"entrySource\":\"NOW\",\"itemCountBucket\":\"TWO_TO_FIVE\""),
                new EventCase("RECORD_DETAIL_VIEWED",
                        "\"recordAgeBucket\":\"ONE_TO_SIX_DAYS\",\"sourceType\":\"ZERO_RECORD\""),
                new EventCase("REFLECTION_REQUESTED",
                        "\"surface\":\"ARCHIVE\",\"contextClasses\":[\"PROFILE\",\"MEMORY\"]"),
                new EventCase("REFLECTION_COMPLETED",
                        "\"outcome\":\"SUCCESS\",\"latencyBucket\":\"FROM_500_TO_1499_MS\","
                                + "\"promptVersion\":\"companion-v1\",\"modelAlias\":\"primary\""),
                new EventCase("MEMORY_CONTROL_CHANGED",
                        "\"action\":\"DISALLOW_AI\",\"sourceType\":\"MEMORY\""),
                new EventCase("PROFILE_AI_CONTEXT_CHANGED",
                        "\"enabled\":false,\"surface\":\"PROFILE\""),
                new EventCase("DATA_EXPORT_REQUESTED",
                        "\"surface\":\"DATA_CONTROL\",\"outcome\":\"COMPLETED\""),
                new EventCase("ACCOUNT_DELETE_REQUESTED",
                        "\"surface\":\"DATA_CONTROL\",\"outcome\":\"STARTED\","
                                + "\"reasonCategory\":\"PRIVACY_CONCERN\""));

        for (int index = 0; index < cases.size(); index++) {
            EventCase eventCase = cases.get(index);
            UUID eventId = UUID.fromString(
                    "60800000-0000-4000-8000-%012d".formatted(index + 1));
            mockMvc.perform(post("/api/v1/evidence/events")
                            .header("Authorization", bearer(token))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(typedEvent(eventId, eventCase.eventName(), eventCase.properties())))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.eventName").value(eventCase.eventName()));
        }

        assertThat(eventCount("13700806008")).isEqualTo(cases.size());

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(typedEvent(
                                UUID.randomUUID(),
                                "AUTH_COMPLETED",
                                "\"accountType\":\"NEW\",\"platform\":\"WEB\","
                                        + "\"appVersion\":\"1.0.0\",\"goal\":\"private\"")))
                .andExpect(status().isBadRequest());

        String outsideWindow = typedEvent(
                UUID.randomUUID(),
                "AUTH_COMPLETED",
                "\"accountType\":\"NEW\",\"platform\":\"WEB\",\"appVersion\":\"1.0.0\"")
                .replace(
                        LocalDate.now(ZoneId.of("Asia/Shanghai")).toString(),
                        LocalDate.now(ZoneId.of("Asia/Shanghai")).minusDays(8).toString());
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(outsideWindow))
                .andExpect(status().isBadRequest());
    }

    private void enable(String token) throws Exception {
        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(preference(true, NOTICE_VERSION)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(true));
    }

    private String preference(boolean enabled, String noticeVersion) {
        return """
                {
                  "enabled": %s,
                  "noticeVersion": "%s"
                }
                """.formatted(enabled, noticeVersion);
    }

    private String recordSaved(UUID eventId, boolean hasContent) {
        return """
                {
                  "clientEventId": "%s",
                  "eventName": "RECORD_SAVED",
                  "schemaVersion": 1,
                  "occurredDate": "%s",
                  "state": "CALM",
                  "hasGoal": true,
                  "hasContent": %s,
                  "latencyBucket": "UNDER_500_MS",
                  "retryCountBucket": "ZERO"
                }
                """.formatted(
                eventId,
                LocalDate.now(ZoneId.of("Asia/Shanghai")),
                hasContent);
    }

    private String typedEvent(UUID eventId, String eventName, String properties) {
        return """
                {
                  "clientEventId": "%s",
                  "eventName": "%s",
                  "schemaVersion": 1,
                  "occurredDate": "%s",
                  %s
                }
                """.formatted(
                eventId,
                eventName,
                LocalDate.now(ZoneId.of("Asia/Shanghai")),
                properties);
    }

    private String login(String mobile, String deviceId) throws Exception {
        mockMvc.perform(post("/api/v1/auth/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mobile\":\"" + mobile + "\"}"))
                .andExpect(status().isAccepted());
        String response = mockMvc.perform(post("/api/v1/auth/login")
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
        JsonNode session = objectMapper.readTree(response);
        return session.path("accessToken").asText();
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private long subjectCount(String mobile) {
        Long count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM evidence_subjects subject
                JOIN users user_account ON user_account.id = subject.user_id
                WHERE user_account.mobile = ?
                """, Long.class, mobile);
        return count == null ? 0 : count;
    }

    private long eventCount(String mobile) {
        Long count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM evidence_events event
                JOIN evidence_subjects subject ON subject.id = event.subject_id
                JOIN users user_account ON user_account.id = subject.user_id
                WHERE user_account.mobile = ?
                """, Long.class, mobile);
        return count == null ? 0 : count;
    }

    private record EventCase(String eventName, String properties) {
    }
}
