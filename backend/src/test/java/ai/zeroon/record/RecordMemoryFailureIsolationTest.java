package ai.zeroon.record;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.memory.MemoryProductionService;
import ai.zeroon.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest
@AutoConfigureMockMvc
class RecordMemoryFailureIsolationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ZeroRecordRepository zeroRecordRepository;

    @MockitoBean
    private MemoryProductionService memoryProductionService;

    @Test
    void memoryFailureDoesNotChangeCommittedRecordResponse() throws Exception {
        String mobile = "13200132999";
        String accessToken = login(mobile);
        doThrow(new IllegalStateException("simulated-memory-store-failure"))
                .when(memoryProductionService).ensureForRecord(anyLong(), anyLong());

        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "FOCUS",
                                  "goal": "keep the record",
                                  "content": "memory production may retry later"
                                }
                                """))
                .andExpect(status().isCreated());

        Long userId = userRepository.findByMobile(mobile).orElseThrow().getId();
        assertThat(zeroRecordRepository.countByUserId(userId)).isOne();
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
                                  "deviceId": "memory-failure-test"
                                }
                                """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
