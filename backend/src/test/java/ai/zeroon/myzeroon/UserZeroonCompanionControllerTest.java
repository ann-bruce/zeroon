package ai.zeroon.myzeroon;

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
class UserZeroonCompanionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void companionEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/me/zeroon-companion"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/me/zeroon-companion")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void defaultCompanionIsNotMet() throws Exception {
        String accessToken = login("13700601000");

        mockMvc.perform(get("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.met").value(false))
                .andExpect(jsonPath("$.companionKey").doesNotExist())
                .andExpect(jsonPath("$.nameplateSerial").doesNotExist())
                .andExpect(jsonPath("$.metAt").doesNotExist());
    }

    @Test
    void userCanMeetZeroonCompanionIdempotently() throws Exception {
        String accessToken = login("13700601001");

        mockMvc.perform(post("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"companionKey\":\"ZEROON_DEFAULT\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.met").value(true))
                .andExpect(jsonPath("$.companionKey").value("ZEROON_DEFAULT"))
                .andExpect(jsonPath("$.nameplateSerial").value(org.hamcrest.Matchers.matchesPattern("ZR-\\d{8}-[A-Z2-9]{4}")))
                .andExpect(jsonPath("$.metAt").exists())
                .andExpect(jsonPath("$.createdAt").exists())
                .andExpect(jsonPath("$.updatedAt").exists());

        mockMvc.perform(post("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"companionKey\":\"ZEROON_DEFAULT\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.met").value(true))
                .andExpect(jsonPath("$.companionKey").value("ZEROON_DEFAULT"));
    }

    @Test
    void usersOnlyReadTheirOwnCompanion() throws Exception {
        String ownerToken = login("13700601002");
        String otherToken = login("13700601003");

        mockMvc.perform(post("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.met").value(false));
    }

    @Test
    void invalidCompanionKeyReturnsBadRequest() throws Exception {
        String accessToken = login("13700601004");

        mockMvc.perform(post("/api/v1/me/zeroon-companion")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"companionKey\":\"UNKNOWN\"}"))
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
                                  "deviceId": "my-zeroon-test"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("accessToken").asText();
    }
}
