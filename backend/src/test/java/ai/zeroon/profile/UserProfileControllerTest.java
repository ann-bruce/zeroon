package ai.zeroon.profile;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
class UserProfileControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void profileEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/me/profile"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(put("/api/v1/me/profile")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void defaultProfileIsPrivateAndEmpty() throws Exception {
        String accessToken = login("13700501000");

        mockMvc.perform(get("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").doesNotExist())
                .andExpect(jsonPath("$.avatarPreset").doesNotExist())
                .andExpect(jsonPath("$.ageRange").doesNotExist())
                .andExpect(jsonPath("$.occupation").doesNotExist())
                .andExpect(jsonPath("$.selfDescription").doesNotExist())
                .andExpect(jsonPath("$.aiProfileContextEnabled").value(false));
    }

    @Test
    void userCanCreateAndUpdateOwnProfile() throws Exception {
        String accessToken = login("13700501001");

        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "nickname": "  Bruce  ",
                                  "avatarPreset": "MOON",
                                  "ageRange": "25_34",
                                  "occupation": "founder",
                                  "selfDescription": "I want ZEROON to understand my quiet side.",
                                  "aiProfileContextEnabled": true
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").value("Bruce"))
                .andExpect(jsonPath("$.avatarPreset").value("MOON"))
                .andExpect(jsonPath("$.ageRange").value("25_34"))
                .andExpect(jsonPath("$.occupation").value("founder"))
                .andExpect(jsonPath("$.selfDescription").value("I want ZEROON to understand my quiet side."))
                .andExpect(jsonPath("$.aiProfileContextEnabled").value(true))
                .andExpect(jsonPath("$.createdAt").exists())
                .andExpect(jsonPath("$.updatedAt").exists());

        mockMvc.perform(get("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").value("Bruce"))
                .andExpect(jsonPath("$.ageRange").value("25_34"));
    }

    @Test
    void blankFieldsAreStoredAsNullAndAiContextDefaultsToFalse() throws Exception {
        String accessToken = login("13700501002");

        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "nickname": "   ",
                                  "occupation": "",
                                  "selfDescription": "  "
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").doesNotExist())
                .andExpect(jsonPath("$.occupation").doesNotExist())
                .andExpect(jsonPath("$.selfDescription").doesNotExist())
                .andExpect(jsonPath("$.aiProfileContextEnabled").value(false));
    }

    @Test
    void usersOnlyReadTheirOwnProfiles() throws Exception {
        String ownerToken = login("13700501003");
        String otherToken = login("13700501004");

        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"nickname\":\"Owner\",\"aiProfileContextEnabled\":true}"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").doesNotExist())
                .andExpect(jsonPath("$.aiProfileContextEnabled").value(false));
    }

    @Test
    void invalidProfileFieldsReturnBadRequest() throws Exception {
        String accessToken = login("13700501005");

        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"nickname\":\"1234567890123456789012345678901\"}"))
                .andExpect(status().isBadRequest());

        mockMvc.perform(put("/api/v1/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"ageRange\":\"UNKNOWN\"}"))
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
