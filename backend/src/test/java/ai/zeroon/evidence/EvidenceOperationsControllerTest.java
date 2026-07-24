package ai.zeroon.evidence;

import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class EvidenceOperationsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Test
    void adminReceivesOnlyASuppressedAggregateForASmallCohort() throws Exception {
        String token = loginAdmin("13800138120");

        mockMvc.perform(get("/api/v1/admin/evidence/cohorts")
                        .queryParam("cohortStart", "2026-07-01")
                        .queryParam("cohortEnd", "2026-07-01")
                        .queryParam("asOfDate", "2026-07-01")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.suppressed").value(true))
                .andExpect(jsonPath("$.minimumCohortSize").value(5))
                .andExpect(jsonPath("$.authenticatedSubjects").value(nullValue()))
                .andExpect(jsonPath("$.activation").value(nullValue()))
                .andExpect(content().string(org.hamcrest.Matchers.not(
                        org.hamcrest.Matchers.containsString("subjectId"))))
                .andExpect(content().string(org.hamcrest.Matchers.not(
                        org.hamcrest.Matchers.containsString("eventFingerprint"))));
    }

    @Test
    void evidenceOperationsRequiresAdminRole() throws Exception {
        mockMvc.perform(get("/api/v1/admin/evidence/cohorts")
                        .queryParam("cohortStart", "2026-07-01")
                        .queryParam("cohortEnd", "2026-07-01")
                        .queryParam("asOfDate", "2026-07-01"))
                .andExpect(status().isUnauthorized());

        String token = login("13800138121");
        mockMvc.perform(get("/api/v1/admin/evidence/cohorts")
                        .queryParam("cohortStart", "2026-07-01")
                        .queryParam("cohortEnd", "2026-07-01")
                        .queryParam("asOfDate", "2026-07-01")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void rejectsAnInvalidCohortWindow() throws Exception {
        String token = loginAdmin("13800138122");

        mockMvc.perform(get("/api/v1/admin/evidence/cohorts")
                        .queryParam("cohortStart", "2026-07-02")
                        .queryParam("cohortEnd", "2026-07-01")
                        .queryParam("asOfDate", "2026-07-01")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isBadRequest());
    }

    private String loginAdmin(String mobile) throws Exception {
        UserEntity admin = new UserEntity("evidence-op-" + mobile.substring(7), mobile);
        admin.grantRole(UserRole.ADMIN);
        userRepository.save(admin);
        return login(mobile);
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
                                    "deviceId": "evidence-operations-test"
                                  }
                                  """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
