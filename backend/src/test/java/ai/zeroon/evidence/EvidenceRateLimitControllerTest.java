package ai.zeroon.evidence;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(properties = "zeroon.evidence.event-hourly-limit=1")
@AutoConfigureMockMvc
class EvidenceRateLimitControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void limitsNewEventsButStillAllowsAnIdenticalIdempotentRetry() throws Exception {
        String token = login();
        mockMvc.perform(put("/api/v1/me/preferences/beta-evidence")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"enabled":true,"adultConfirmed":true,"noticeVersion":"beta-evidence-v2"}
                                """))
                .andExpect(status().isOk());

        UUID firstId = UUID.randomUUID();
        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(event(firstId)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(event(firstId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.duplicate").value(true));

        mockMvc.perform(post("/api/v1/evidence/events")
                        .header("Authorization", bearer(token))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(event(UUID.randomUUID())))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().string("Retry-After", "3600"))
                .andExpect(jsonPath("$.error").value("evidence_event_rate_limited"));
    }

    private String event(UUID eventId) {
        return """
                {
                  "clientEventId":"%s",
                  "eventName":"ARCHIVE_VIEWED",
                  "schemaVersion":1,
                  "occurredDate":"%s",
                  "entrySource":"NOW",
                  "itemCountBucket":"ONE"
                }
                """.formatted(eventId, LocalDate.now(ZoneId.of("Asia/Shanghai")));
    }

    private String login() throws Exception {
        mockMvc.perform(post("/api/v1/auth/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mobile\":\"13700806009\"}"))
                .andExpect(status().isAccepted());
        String response = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "mobile":"13700806009",
                                  "code":"000000",
                                  "deviceId":"evidence-rate-limit"
                                }
                                """))
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
}
