package ai.zeroon.state;

import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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
class StateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void userCanReadAndChangeOwnCurrentState() throws Exception {
        String accessToken = login("13700137000");

        mockMvc.perform(get("/api/v1/state/current")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state").value("CALM"))
                .andExpect(jsonPath("$.source").value("SYSTEM"))
                .andExpect(jsonPath("$.changedAt").exists());

        mockMvc.perform(post("/api/v1/state/changes")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"FOCUS\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("FOCUS"))
                .andExpect(jsonPath("$.source").value("MANUAL"))
                .andExpect(jsonPath("$.changedAt").exists())
                .andExpect(jsonPath("$.sessionId").isNumber())
                .andExpect(jsonPath("$.startedAt").exists())
                .andExpect(jsonPath("$.elapsedSeconds").isNumber());

        mockMvc.perform(get("/api/v1/state/current")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state").value("FOCUS"))
                .andExpect(jsonPath("$.source").value("MANUAL"))
                .andExpect(jsonPath("$.sessionId").isNumber());
    }

    @Test
    void userCanStartStateSessionAndRepeatedStateIsIdempotent() throws Exception {
        String accessToken = login("13700137001");

        String firstBody = mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CREATE\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("CREATE"))
                .andExpect(jsonPath("$.sessionId").isNumber())
                .andReturn()
                .getResponse()
                .getContentAsString();

        long firstSessionId = objectMapper.readTree(firstBody).path("sessionId").asLong();

        mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CREATE\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.sessionId").value(firstSessionId));
    }

    @Test
    void userCanSwitchStateImmediately() throws Exception {
        String accessToken = login("13700137003");

        mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"FOCUS\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("FOCUS"));

        mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("CALM"))
                .andExpect(jsonPath("$.sessionId", notNullValue()));
    }

    @Test
    void userCanSwitchStateAfterActiveSessionAgesOutOfShortWindow() throws Exception {
        String accessToken = login("13700137004");

        String sessionBody = mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"FOCUS\"}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        long sessionId = objectMapper.readTree(sessionBody).path("sessionId").asLong();
        jdbcTemplate.update(
                "UPDATE state_sessions SET started_at = DATEADD('SECOND', -60, started_at) WHERE id = ?",
                sessionId);

        mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("CALM"))
                .andExpect(jsonPath("$.sessionId", notNullValue()));
    }

    @Test
    void savingRecordEndsActiveStateSession() throws Exception {
        String accessToken = login("13700137002");

        String sessionBody = mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"OVERLOAD\"}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();

        long sessionId = objectMapper.readTree(sessionBody).path("sessionId").asLong();

        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"goal\":\"slow down\",\"content\":\"I paused.\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.state").value("OVERLOAD"))
                .andExpect(jsonPath("$.stateSessionId").value(sessionId))
                .andExpect(jsonPath("$.stateStartedAt", notNullValue()))
                .andExpect(jsonPath("$.stateEndedAt", notNullValue()))
                .andExpect(jsonPath("$.stateDurationSeconds", notNullValue()));

        mockMvc.perform(get("/api/v1/state/current")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId").value(nullValue()));
    }

    @Test
    void stateEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/state/current"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/state/changes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"FOCUS\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void invalidStateReturnsBadRequest() throws Exception {
        String accessToken = login("13600136000");

        mockMvc.perform(post("/api/v1/state/changes")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"UNKNOWN\"}"))
                .andExpect(status().isBadRequest());
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
                                  "deviceId": "ios-simulator"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("accessToken").asText();
    }
}
