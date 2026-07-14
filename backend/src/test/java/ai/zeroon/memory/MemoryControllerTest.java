package ai.zeroon.memory;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class MemoryControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MemoryEntryRepository memoryEntryRepository;

    @Test
    void memoryEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/memory"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(patch("/api/v1/memory/{memoryId}", 1)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false}"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(delete("/api/v1/memory/{memoryId}", 1))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void userCanListAndReadOwnedMemoryEntriesOnly() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_owner",
                "13900000010",
                Instant.parse("2026-06-01T00:00:00Z")));
        UserEntity other = userRepository.save(new UserEntity(
                "memory_other",
                "13900000011",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity owned = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.ZERO_RECORD,
                "第一次归零",
                "今天第一次把状态放进 Archive。",
                (short) 3,
                "ZERO_RECORD",
                1L,
                Instant.parse("2026-06-10T00:00:00Z")));
        memoryEntryRepository.save(new MemoryEntryEntity(
                other,
                MemoryEntryType.GROWTH,
                "他人的成长",
                "这条记忆不应被当前用户看到。",
                (short) 5,
                "GROWTH",
                2L,
                Instant.parse("2026-06-11T00:00:00Z")));
        String token = login("13900000010");

        mockMvc.perform(get("/api/v1/memory")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(owned.getId()))
                .andExpect(jsonPath("$.items[0].type").value("ZERO_RECORD"))
                .andExpect(jsonPath("$.items[0].summary").value("今天第一次把状态放进 Archive。"))
                .andExpect(jsonPath("$.items[0].enabled").value(true))
                .andExpect(jsonPath("$.items[0].aiContextEnabled").value(false))
                .andExpect(jsonPath("$.items[0].updatedAt").value("2026-06-10T00:00:00Z"))
                .andExpect(jsonPath("$.totalElements").value(1));

        mockMvc.perform(get("/api/v1/memory/{memoryId}", owned.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(owned.getId()))
                .andExpect(jsonPath("$.sourceType").value("ZERO_RECORD"))
                .andExpect(jsonPath("$.enabled").value(true))
                .andExpect(jsonPath("$.aiContextEnabled").value(false));
    }

    @Test
    void crossUserMemoryDetailReturnsNotFound() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_owner_2",
                "13900000012",
                Instant.parse("2026-06-01T00:00:00Z")));
        UserEntity other = userRepository.save(new UserEntity(
                "memory_other_2",
                "13900000013",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity otherMemory = memoryEntryRepository.save(new MemoryEntryEntity(
                other,
                MemoryEntryType.GROWTH,
                "他人的成长",
                "不属于当前用户。",
                (short) 5,
                "GROWTH",
                2L,
                Instant.parse("2026-06-11T00:00:00Z")));
        String token = login(owner.getMobile());

        mockMvc.perform(get("/api/v1/memory/{memoryId}", otherMemory.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound());
    }

    @Test
    void expiredMemoryEntriesAreHiddenFromListAndDetail() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_expired_owner",
                "13900000017",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity visible = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.ZERO_RECORD,
                "可见记忆",
                "这条记忆仍然可见。",
                (short) 3,
                "ZERO_RECORD",
                1L,
                Instant.parse("2026-06-10T00:00:00Z")));
        MemoryEntryEntity expired = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.STATE,
                "过期记忆",
                "这条记忆已经不应展示。",
                (short) 2,
                "STATE",
                2L,
                Instant.parse("2026-06-09T00:00:00Z"),
                Instant.parse("2026-06-10T00:00:00Z")));
        String token = login(owner.getMobile());

        mockMvc.perform(get("/api/v1/memory")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items", hasSize(1)))
                .andExpect(jsonPath("$.items[0].id").value(visible.getId()))
                .andExpect(jsonPath("$.totalElements").value(1));

        mockMvc.perform(get("/api/v1/memory/{memoryId}", expired.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound());
        mockMvc.perform(patch("/api/v1/memory/{memoryId}", expired.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false}"))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete("/api/v1/memory/{memoryId}", expired.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound());
    }

    @Test
    void ownerCanUpdateMemoryControlsWithoutSilentlyChangingAiPreference() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_control_owner",
                "13900000018",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity memory = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.ZERO_RECORD,
                "可控记忆",
                "这条记忆由用户决定如何使用。",
                (short) 1,
                "ZERO_RECORD",
                18L,
                Instant.parse("2026-06-10T00:00:00Z")));
        String token = login(owner.getMobile());

        mockMvc.perform(patch("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"aiContextEnabled\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(true))
                .andExpect(jsonPath("$.aiContextEnabled").value(true));

        mockMvc.perform(patch("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(false))
                .andExpect(jsonPath("$.aiContextEnabled").value(true))
                .andExpect(jsonPath("$.updatedAt").isNotEmpty());

        mockMvc.perform(patch("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void crossUserCannotUpdateOrDeleteMemory() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_mutation_owner",
                "13900000019",
                Instant.parse("2026-06-01T00:00:00Z")));
        UserEntity other = userRepository.save(new UserEntity(
                "memory_mutation_other",
                "13900000020",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity memory = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.ZERO_RECORD,
                "仅属于所有者",
                "另一位用户不能控制它。",
                (short) 1,
                "ZERO_RECORD",
                19L,
                Instant.parse("2026-06-10T00:00:00Z")));
        String otherToken = login(other.getMobile());

        mockMvc.perform(patch("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + otherToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false}"))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isNotFound());

        assertThat(memoryEntryRepository.findById(memory.getId())).isPresent();
    }

    @Test
    void ownerHardDeleteRemovesMemoryContent() throws Exception {
        UserEntity owner = userRepository.save(new UserEntity(
                "memory_delete_owner",
                "13900000021",
                Instant.parse("2026-06-01T00:00:00Z")));
        MemoryEntryEntity memory = memoryEntryRepository.save(new MemoryEntryEntity(
                owner,
                MemoryEntryType.ZERO_RECORD,
                "准备删除",
                "删除后这段正文不应保留。",
                (short) 1,
                "ZERO_RECORD",
                21L,
                Instant.parse("2026-06-10T00:00:00Z")));
        String token = login(owner.getMobile());

        mockMvc.perform(delete("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNoContent());

        assertThat(memoryEntryRepository.findById(memory.getId())).isEmpty();
        mockMvc.perform(get("/api/v1/memory/{memoryId}", memory.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound());
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
                                    "deviceId": "memory-test"
                                  }
                                  """.formatted(mobile)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return body.split("\"accessToken\":\"")[1].split("\"")[0];
    }
}
