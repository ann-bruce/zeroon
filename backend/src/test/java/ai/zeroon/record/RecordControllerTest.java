package ai.zeroon.record;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.memory.MemoryEntryRepository;
import ai.zeroon.memory.MemoryEntryType;
import ai.zeroon.memory.MemoryProductionService;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
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

    @Autowired
    private MemoryEntryRepository memoryEntryRepository;

    @Autowired
    private MemoryProductionService memoryProductionService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void userCanCreateListAndReadOwnRecords() throws Exception {
        String accessToken = login("13500135000");

        Long firstId = createRecord(accessToken, "CALM", "first step", "today I paused");
        Long secondId = createRecord(accessToken, "FOCUS", "next step", "I finished a small task");

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
                .andExpect(jsonPath("$.goal").value("first step"))
                .andExpect(jsonPath("$.content").value("today I paused"))
                .andExpect(jsonPath("$.createdAt", notNullValue()));
    }

    @Test
    void userCannotReadAnotherUsersRecord() throws Exception {
        String ownerToken = login("13400134000");
        String otherToken = login("13300133000");
        Long recordId = createRecord(ownerToken, "CREATE", "write", "private content");

        mockMvc.perform(get("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isNotFound());
    }

    @Test
    void repeatedSaveTapsDoNotCreateDuplicateRecords() throws Exception {
        String accessToken = login("13200132000");

        Long firstId = createRecord(accessToken, "TIRED", "rest", "same content");
        Long userId = userRepository.findByMobile("13200132000").orElseThrow().getId();
        var firstMemory = memoryEntryRepository.findByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", firstId).orElseThrow();
        memoryEntryRepository.delete(firstMemory);
        Long repeatedId = createRecord(accessToken, "TIRED", "rest", "same content");

        mockMvc.perform(get("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(firstId))
                .andExpect(jsonPath("$.items[0].id").value(repeatedId));

        assertThat(memoryEntryRepository.countByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", firstId)).isOne();
    }

    @Test
    void committedRecordCreatesOwnedSourceLinkedMemoryWithSafeDefaults() throws Exception {
        String accessToken = login("13200132001");
        Long recordId = createRecord(
                accessToken,
                "CREATE",
                "finish a small draft",
                "I kept the first version without judging it.");
        Long userId = userRepository.findByMobile("13200132001").orElseThrow().getId();

        var memory = memoryEntryRepository.findByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", recordId).orElseThrow();

        assertThat(memory.getTitle()).isEqualTo("finish a small draft");
        assertThat(memory.getSummary()).isEqualTo("I kept the first version without judging it.");
        assertThat(memory.getSourceId()).isEqualTo(recordId);
        assertThat(memory.isEnabled()).isTrue();
        assertThat(memory.isAiContextEnabled()).isFalse();
    }

    @Test
    void memoryProductionRejectsRecordOwnedByAnotherUser() throws Exception {
        String ownerToken = login("13200132002");
        login("13200132003");
        Long recordId = createRecord(ownerToken, "CALM", "private goal", "private source");
        Long otherUserId = userRepository.findByMobile("13200132003").orElseThrow().getId();

        assertThatThrownBy(() -> memoryProductionService.ensureForRecord(otherUserId, recordId))
                .isInstanceOf(EntityNotFoundException.class)
                .hasMessage("Record not found");
        assertThat(memoryEntryRepository.countByUserIdAndTypeAndSourceTypeAndSourceId(
                otherUserId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", recordId)).isZero();
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

    @Test
    void recordWithoutActiveSessionOrCompatibilityStateReturnsConflict() throws Exception {
        String accessToken = login("13100131001");

        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"content\":\"private\"}"))
                .andExpect(status().isConflict());
    }

    private Long createRecord(
            String accessToken,
            String state,
            String goal,
            String content) throws Exception {
        String body = mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "%s",
                                  "goal": "%s",
                                  "content": "%s"
                                }
                                """.formatted(state, goal, content)))
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
