package ai.zeroon.user;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.record.ZeroRecordEntity;
import ai.zeroon.record.ZeroRecordRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class UserDataControlControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ZeroRecordRepository zeroRecordRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void dataControlEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/me")).andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/me/export")).andExpect(status().isUnauthorized());
        mockMvc.perform(delete("/api/v1/me/deletion")).andExpect(status().isUnauthorized());
    }

    @Test
    void currentUserAndExportReturnOnlyOwnedDataWithoutCredentialHashes() throws Exception {
        JsonNode ownerSession = login("13700805001", "data-control-owner");
        JsonNode otherSession = login("13700805002", "data-control-other");
        UserEntity owner = userRepository.findByMobile("13700805001").orElseThrow();
        UserEntity other = userRepository.findByMobile("13700805002").orElseThrow();
        zeroRecordRepository.save(new ZeroRecordEntity(
                owner, UserState.FOCUS, "owner goal", "owner private content"));
        zeroRecordRepository.save(new ZeroRecordEntity(
                other, UserState.CALM, "other goal", "other private content"));
        jdbcTemplate.update("""
                INSERT INTO memory_entries (
                    user_id, type, summary, source_type, source_id
                ) VALUES (?, 'ZERO_RECORD', 'owner memory summary', 'ZERO_RECORD', 9001)
                """, owner.getId());

        String accessToken = ownerSession.path("accessToken").asText();
        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "nickname": "River",
                                  "occupation": "Designer",
                                  "aiProfileContextEnabled": true
                                }
                                """))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.uid").value(owner.getUid()))
                .andExpect(jsonPath("$.mobile").value("13700805001"))
                .andExpect(jsonPath("$.roles[0]").value("USER"));

        String export = mockMvc.perform(get("/api/v1/me/export")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(header().string(
                        "Content-Disposition", "attachment; filename=zeroon-data-export.json"))
                .andExpect(jsonPath("$.schemaVersion").value("zeroon-beta-export-v1"))
                .andExpect(jsonPath("$.account.mobile").value("13700805001"))
                .andExpect(jsonPath("$.profile.nickname").value("River"))
                .andExpect(jsonPath("$.records[0].content").value("owner private content"))
                .andExpect(jsonPath("$.memoryEntries[0].enabled").value(true))
                .andExpect(jsonPath("$.memoryEntries[0].aiContextEnabled").value(false))
                .andExpect(jsonPath("$.memoryEntries[0].updatedAt").isNotEmpty())
                .andExpect(jsonPath("$.sessions[0].deviceId").value("data-control-owner"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        assertThat(export)
                .doesNotContain("other private content")
                .doesNotContain("refreshToken")
                .doesNotContain("tokenHash");
        assertThat(otherSession.path("accessToken").asText()).isNotBlank();
    }

    @Test
    void deletionIsImmediateIdempotentAndDeidentifiesRetainedUsageMetadata() throws Exception {
        JsonNode session = login("13700805003", "deletion-device");
        UserEntity user = userRepository.findByMobile("13700805003").orElseThrow();
        zeroRecordRepository.save(new ZeroRecordEntity(
                user, UserState.CALM, "delete goal", "delete private content"));
        jdbcTemplate.update("""
                INSERT INTO ai_usage_logs (
                    user_id, provider, operation, outcome, fallback_used,
                    duration_ms, input_chars, output_chars
                ) VALUES (?, 'test', 'COMPANION_REFLECTION', 'SUCCESS', FALSE, 10, 12, 8)
                """, user.getId());

        String accessToken = session.path("accessToken").asText();
        mockMvc.perform(delete("/api/v1/me/deletion")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNoContent());
        mockMvc.perform(delete("/api/v1/me/deletion")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNoContent());

        assertThat(userRepository.existsById(user.getId())).isFalse();
        assertThat(count("zero_records", "user_id", user.getId())).isZero();
        assertThat(count("refresh_sessions", "user_id", user.getId())).isZero();
        assertThat(count("user_profiles", "user_id", user.getId())).isZero();
        assertThat(jdbcTemplate.queryForObject(
                        "SELECT COUNT(*) FROM ai_usage_logs WHERE user_id IS NULL",
                        Long.class))
                .isPositive();

        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + session.path("refreshToken").asText() + "\"}"))
                .andExpect(status().isUnauthorized());
    }

    private long count(String table, String column, Long id) {
        Long count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + table + " WHERE " + column + " = ?",
                Long.class,
                id);
        return count == null ? 0 : count;
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
