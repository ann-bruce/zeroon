package ai.zeroon.state;

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
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class StateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

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
                .andExpect(jsonPath("$.changedAt").exists());

        mockMvc.perform(get("/api/v1/state/current")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state").value("FOCUS"))
                .andExpect(jsonPath("$.source").value("MANUAL"));
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
