package ai.zeroon.growth;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class GrowthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void growthSummaryRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/growth/summary")
                        .param("timezone", "Asia/Shanghai"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void growthSummaryReturnsCurrentUsersMetrics() throws Exception {
        String token = login("13900000003");

        mockMvc.perform(get("/api/v1/growth/summary")
                        .header("Authorization", "Bearer " + token)
                        .param("timezone", "Asia/Shanghai"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.continuousResetDays").value(0))
                .andExpect(jsonPath("$.cachedEntries").value(0))
                .andExpect(jsonPath("$.firstRecordDate").doesNotExist())
                .andExpect(jsonPath("$.companionDays").value(1))
                .andExpect(jsonPath("$.timezone").value("Asia/Shanghai"));
    }

    @Test
    void growthSummaryRejectsInvalidTimezone() throws Exception {
        String token = login("13900000004");

        mockMvc.perform(get("/api/v1/growth/summary")
                        .header("Authorization", "Bearer " + token)
                        .param("timezone", "Bad/Timezone"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void statePatternReturnsNonDiagnosticObservation() throws Exception {
        String token = login("13900000016");

        mockMvc.perform(get("/api/v1/growth/state-pattern")
                        .header("Authorization", "Bearer " + token)
                        .param("timezone", "Asia/Shanghai")
                        .param("days", "14"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.days").value(14))
                .andExpect(jsonPath("$.sampleSize").value(0))
                .andExpect(jsonPath("$.observation").value(org.hamcrest.Matchers.containsString("状态记录")))
                .andExpect(jsonPath("$.dataSources[0]").value("state_history.current_state"));
    }

    private String login(String mobile) throws Exception {
        mockMvc.perform(post("/api/v1/auth/codes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                  {"mobile": "%s"}
                                  """.formatted(mobile)))
                .andExpect(status().isAccepted());
        String body = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                  {
                                    "mobile": "%s",
                                    "code": "000000",
                                    "deviceId": "growth-test"
                                  }
                                  """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
