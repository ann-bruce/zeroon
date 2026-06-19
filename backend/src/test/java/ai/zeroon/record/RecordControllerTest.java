package ai.zeroon.record;

import static org.hamcrest.Matchers.hasSize;
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
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class RecordControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void userCanCreateListAndReadOwnRecords() throws Exception {
        String accessToken = login("13500135000");

        Long firstId = createRecord(accessToken, "CALM", "quiet", "first step", "today I paused");
        Long secondId = createRecord(accessToken, "FOCUS", "clear", "next step", "I finished a small task");

        mockMvc.perform(get("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(2)))
                .andExpect(jsonPath("$.items[0].id").value(secondId))
                .andExpect(jsonPath("$.items[1].id").value(firstId))
                .andExpect(jsonPath("$.totalElements").value(2));

        mockMvc.perform(get("/api/v1/records/{recordId}", firstId)
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(firstId))
                .andExpect(jsonPath("$.state").value("CALM"))
                .andExpect(jsonPath("$.mood").value("quiet"))
                .andExpect(jsonPath("$.goal").value("first step"))
                .andExpect(jsonPath("$.content").value("today I paused"))
                .andExpect(jsonPath("$.createdAt", notNullValue()));
    }

    @Test
    void userCannotReadAnotherUsersRecord() throws Exception {
        String ownerToken = login("13400134000");
        String otherToken = login("13300133000");
        Long recordId = createRecord(ownerToken, "CREATE", "open", "write", "private content");

        mockMvc.perform(get("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isNotFound());
    }

    @Test
    void repeatedSaveTapsDoNotCreateDuplicateRecords() throws Exception {
        String accessToken = login("13200132000");

        Long firstId = createRecord(accessToken, "TIRED", "low", "rest", "same content");
        Long repeatedId = createRecord(accessToken, "TIRED", "low", "rest", "same content");

        mockMvc.perform(get("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(firstId))
                .andExpect(jsonPath("$.items[0].id").value(repeatedId));
    }

    @Test
    void recordEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/records"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/records")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\",\"content\":\"private\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void recordRequiresContentBeyondState() throws Exception {
        String accessToken = login("13100131000");

        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\"}"))
                .andExpect(status().isBadRequest());
    }

    private Long createRecord(
            String accessToken,
            String state,
            String mood,
            String goal,
            String content) throws Exception {
        String body = mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "%s",
                                  "mood": "%s",
                                  "goal": "%s",
                                  "content": "%s"
                                }
                                """.formatted(state, mood, goal, content)))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("id").asLong();
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
