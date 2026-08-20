package ai.zeroon.record;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.memory.MemoryEntryRepository;
import ai.zeroon.memory.MemoryEntryType;
import ai.zeroon.memory.MemoryProductionService;
import ai.zeroon.state.StateSessionRepository;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
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

    @Autowired
    private ZeroRecordRepository zeroRecordRepository;

    @Autowired
    private StateSessionRepository stateSessionRepository;

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
    void ownerCanHardDeleteRecordMemoryAndStateSessionLink() throws Exception {
        String accessToken = login("13400134010");
        mockMvc.perform(post("/api/v1/state/sessions")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\"}"))
                .andExpect(status().isCreated());
        Long recordId = createRecord(accessToken, "CALM", "private goal", "private content");
        Long userId = userRepository.findByMobile("13400134010").orElseThrow().getId();
        var endedSession = stateSessionRepository.findAll().stream()
                .filter(session -> recordId.equals(session.getEndedByRecordId()))
                .findFirst()
                .orElseThrow();

        mockMvc.perform(delete("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNoContent());

        assertThat(zeroRecordRepository.findById(recordId)).isEmpty();
        assertThat(memoryEntryRepository.countByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", recordId)).isZero();
        var detachedSession = stateSessionRepository.findById(endedSession.getId()).orElseThrow();
        assertThat(detachedSession.getEndedAt()).isNotNull();
        assertThat(detachedSession.getEndedByRecordId()).isNull();
        mockMvc.perform(get("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNotFound());
    }

    @Test
    void userCannotDeleteAnotherUsersRecord() throws Exception {
        String ownerToken = login("13400134011");
        String otherToken = login("13400134012");
        Long recordId = createRecord(ownerToken, "CREATE", "owned", "private");

        mockMvc.perform(delete("/api/v1/records/{recordId}", recordId)
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isNotFound());

        assertThat(zeroRecordRepository.findById(recordId)).isPresent();
    }

    @Test
    void repeatedSaveTapsDoNotCreateDuplicateRecords() throws Exception {
        String accessToken = login("13200132000");
        String idempotencyKey = "retry-same-intent";

        Long firstId = createRecord(accessToken, "TIRED", "rest", "same content", idempotencyKey);
        Long userId = userRepository.findByMobile("13200132000").orElseThrow().getId();
        var firstMemory = memoryEntryRepository.findByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", firstId).orElseThrow();
        memoryEntryRepository.delete(firstMemory);
        Long repeatedId = createRecord(accessToken, "TIRED", "rest", "same content", idempotencyKey);

        mockMvc.perform(get("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(firstId))
                .andExpect(jsonPath("$.items[0].id").value(repeatedId));

        assertThat(memoryEntryRepository.countByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, "ZERO_RECORD", firstId)).isZero();
    }

    @Test
    void matchingContentWithDifferentIntentKeysCreatesDistinctRecords() throws Exception {
        String accessToken = login("13200132004");

        Long firstId = createRecord(accessToken, "CALM", "same", "same", "intent-one");
        Long secondId = createRecord(accessToken, "CALM", "same", "same", "intent-two");

        assertThat(secondId).isNotEqualTo(firstId);
        mockMvc.perform(get("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(2)));
    }

    @Test
    void idempotencyKeyCannotBeReusedForDifferentPayload() throws Exception {
        String accessToken = login("13200132005");
        createRecord(accessToken, "CALM", "first", "payload", "conflicting-intent");

        mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Idempotency-Key", "conflicting-intent")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "state": "CALM",
                                  "goal": "changed",
                                  "content": "payload"
                }
                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("conflict"))
                .andExpect(jsonPath("$.message").value(
                        "Idempotency-Key was already used for a different record payload"));
    }

    @Test
    void concurrentRetriesWithOneIntentCreateOneRecord() throws Exception {
        String accessToken = login("13200132006");
        var ready = new CountDownLatch(2);
        var start = new CountDownLatch(1);
        var executor = Executors.newFixedThreadPool(2);
        try {
            var first = executor.submit(() -> {
                ready.countDown();
                start.await();
                return createRecord(accessToken, "CALM", "one", "intent", "concurrent-intent");
            });
            var second = executor.submit(() -> {
                ready.countDown();
                start.await();
                return createRecord(accessToken, "CALM", "one", "intent", "concurrent-intent");
            });
            ready.await();
            start.countDown();

            assertThat(first.get()).isEqualTo(second.get());
        } finally {
            executor.shutdownNow();
        }

        Long userId = userRepository.findByMobile("13200132006").orElseThrow().getId();
        assertThat(zeroRecordRepository.countByUserId(userId)).isOne();
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

        mockMvc.perform(delete("/api/v1/records/1"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(get("/api/v1/records/continuity-cue"))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/records")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"state\":\"CALM\",\"content\":\"private\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void continuityCueReturnsNoCueWhenTheOwnerHasNoEligibleRecord() throws Exception {
        String accessToken = login("13100131002");

        mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cue").doesNotExist());
    }

    @Test
    void continuityCueReturnsOneStableOlderOwnedRecordOnly() throws Exception {
        String accessToken = login("13100131003");
        var user = userRepository.findByMobile("13100131003").orElseThrow();
        Long firstOldRecordId = saveRecord(user, "CALM", "first old goal", "first old content", 5);
        Long secondOldRecordId = saveRecord(user, "FOCUS", "second old goal", "second old content", 4);
        saveRecord(user, "CREATE", "new goal", "new content", 1);

        String firstBody = mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .param("timezone", "Asia/Shanghai")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cue.recordId").isNumber())
                .andExpect(jsonPath("$.cue.state").exists())
                .andExpect(jsonPath("$.cue.preview").isString())
                .andExpect(jsonPath("$.cue.goal").doesNotExist())
                .andExpect(jsonPath("$.cue.content").doesNotExist())
                .andExpect(jsonPath("$.cue.createdAt").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();
        long selectedId = objectMapper.readTree(firstBody).path("cue").path("recordId").asLong();
        assertThat(selectedId).isIn(firstOldRecordId, secondOldRecordId);

        String secondBody = mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .param("timezone", "Asia/Shanghai")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(objectMapper.readTree(secondBody).path("cue").path("recordId").asLong())
                .isEqualTo(selectedId);

        mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .param("timezone", "+05:30")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cue.preview").isString());
    }

    @Test
    void continuityCueNeverReturnsAnotherUsersRecordAndRejectsInvalidTimezone() throws Exception {
        String ownerToken = login("13100131004");
        String otherToken = login("13100131005");
        var owner = userRepository.findByMobile("13100131004").orElseThrow();
        saveRecord(owner, "TIRED", "private goal", "private content", 4);

        mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cue").doesNotExist());

        mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .param("timezone", "not/a-timezone")
                        .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isBadRequest());
    }

    @Test
    void continuityCueReturnsOnlyABoundedUnicodePreview() throws Exception {
        String accessToken = login("13100131006");
        var user = userRepository.findByMobile("13100131006").orElseThrow();
        saveRecord(user, "CALM", null, "🙂".repeat(200), 4);

        String body = mockMvc.perform(get("/api/v1/records/continuity-cue")
                        .param("timezone", "Asia/Shanghai")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cue.preview").isString())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String preview = objectMapper.readTree(body).path("cue").path("preview").asText();
        assertThat(preview.codePointCount(0, preview.length())).isEqualTo(160);
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
        return createRecord(
                accessToken,
                state,
                goal,
                content,
                "test-" + java.util.UUID.randomUUID());
    }

    private Long createRecord(
            String accessToken,
            String state,
            String goal,
            String content,
            String idempotencyKey) throws Exception {
        String body = mockMvc.perform(post("/api/v1/records")
                        .header("Authorization", "Bearer " + accessToken)
                        .header("Idempotency-Key", idempotencyKey)
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

    private Long saveRecord(
            ai.zeroon.user.UserEntity user,
            String state,
            String goal,
            String content,
            long ageInDays) {
        return zeroRecordRepository.save(new ZeroRecordEntity(
                        user,
                        ai.zeroon.user.UserState.valueOf(state),
                        goal,
                        content,
                        Instant.now().minus(Duration.ofDays(ageInDays))))
                .getId();
    }
}
