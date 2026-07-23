package ai.zeroon.user;

import ai.zeroon.user.UserDataDtos.AiUsageExport;
import ai.zeroon.user.UserDataDtos.ConversationExport;
import ai.zeroon.user.UserDataDtos.CurrentUserResponse;
import ai.zeroon.user.UserDataDtos.MemoryEntryExport;
import ai.zeroon.user.UserDataDtos.MessageExport;
import ai.zeroon.user.UserDataDtos.ProfileExport;
import ai.zeroon.user.UserDataDtos.SessionExport;
import ai.zeroon.user.UserDataDtos.StateChangeExport;
import ai.zeroon.user.UserDataDtos.StateSessionExport;
import ai.zeroon.user.UserDataDtos.UserDataExportResponse;
import ai.zeroon.user.UserDataDtos.ZeroRecordExport;
import ai.zeroon.user.UserDataDtos.ZeroonCompanionExport;
import ai.zeroon.user.UserPreferenceDtos.LanguagePreferenceResponse;
import jakarta.persistence.EntityNotFoundException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserDataControlService {

    private static final String EXPORT_SCHEMA_VERSION = "zeroon-beta-export-v2";

    private final UserRepository userRepository;
    private final JdbcTemplate jdbcTemplate;

    public UserDataControlService(UserRepository userRepository, JdbcTemplate jdbcTemplate) {
        this.userRepository = userRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional(readOnly = true)
    public CurrentUserResponse currentUser(Long userId) {
        return toCurrentUser(requireUser(userId));
    }

    @Transactional(readOnly = true)
    public LanguagePreferenceResponse languagePreference(Long userId) {
        return toLanguagePreference(requireUser(userId));
    }

    @Transactional
    public LanguagePreferenceResponse updateLanguagePreference(
            Long userId, LanguagePreference languagePreference) {
        UserEntity user = requireUser(userId);
        user.changeLanguagePreference(languagePreference);
        return toLanguagePreference(user);
    }

    @Transactional(readOnly = true)
    public UserDataExportResponse export(Long userId) {
        UserEntity user = requireUser(userId);
        Map<Long, List<MessageExport>> messages = messages(userId);
        return new UserDataExportResponse(
                EXPORT_SCHEMA_VERSION,
                Instant.now(),
                toCurrentUser(user),
                profile(userId),
                zeroonCompanion(userId),
                sessions(userId),
                stateHistory(userId),
                stateSessions(userId),
                records(userId),
                conversations(userId, messages),
                memoryEntries(userId),
                aiUsage(userId));
    }

    @Transactional
    public void deleteAccount(Long userId) {
        if (!userRepository.existsById(userId)) {
            return;
        }
        userRepository.deleteById(userId);
        userRepository.flush();
    }

    private UserEntity requireUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }

    private CurrentUserResponse toCurrentUser(UserEntity user) {
        return new CurrentUserResponse(
                user.getUid(),
                user.getMobile(),
                user.getCurrentState().name(),
                user.getStatus().name(),
                user.getRoles().stream().map(Enum::name).sorted().toList(),
                user.getLanguagePreference().name(),
                user.getCreatedAt());
    }

    private LanguagePreferenceResponse toLanguagePreference(UserEntity user) {
        return new LanguagePreferenceResponse(user.getLanguagePreference());
    }

    private ProfileExport profile(Long userId) {
        return jdbcTemplate.query("""
                SELECT nickname, avatar_preset, age_range, occupation, self_description,
                       ai_profile_context_enabled, created_at, updated_at
                FROM user_profiles WHERE user_id = ?
                """, (rs, row) -> new ProfileExport(
                rs.getString("nickname"),
                rs.getString("avatar_preset"),
                rs.getString("age_range"),
                rs.getString("occupation"),
                rs.getString("self_description"),
                rs.getBoolean("ai_profile_context_enabled"),
                instant(rs, "created_at"),
                instant(rs, "updated_at")), userId).stream().findFirst().orElse(null);
    }

    private ZeroonCompanionExport zeroonCompanion(Long userId) {
        return jdbcTemplate.query("""
                SELECT companion_key, display_name, nameplate_serial, met_at
                FROM user_zeroon_companions WHERE user_id = ?
                """, (rs, row) -> new ZeroonCompanionExport(
                rs.getString("companion_key"),
                rs.getString("display_name"),
                rs.getString("nameplate_serial"),
                instant(rs, "met_at")), userId).stream().findFirst().orElse(null);
    }

    private List<SessionExport> sessions(Long userId) {
        return jdbcTemplate.query("""
                SELECT device_id, expires_at, revoked_at, created_at
                FROM refresh_sessions WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> new SessionExport(
                rs.getString("device_id"),
                instant(rs, "expires_at"),
                instant(rs, "revoked_at"),
                instant(rs, "created_at")), userId);
    }

    private List<StateChangeExport> stateHistory(Long userId) {
        return jdbcTemplate.query("""
                SELECT previous_state, current_state, source, created_at
                FROM state_history WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> new StateChangeExport(
                rs.getString("previous_state"),
                rs.getString("current_state"),
                rs.getString("source"),
                instant(rs, "created_at")), userId);
    }

    private List<StateSessionExport> stateSessions(Long userId) {
        return jdbcTemplate.query("""
                SELECT id, state, source, started_at, ended_at, ended_by_record_id
                FROM state_sessions WHERE user_id = ? ORDER BY started_at
                """, (rs, row) -> new StateSessionExport(
                rs.getLong("id"),
                rs.getString("state"),
                rs.getString("source"),
                instant(rs, "started_at"),
                instant(rs, "ended_at"),
                nullableLong(rs, "ended_by_record_id")), userId);
    }

    private List<ZeroRecordExport> records(Long userId) {
        return jdbcTemplate.query("""
                SELECT id, state, goal, content, ai_summary, state_session_id, created_at, updated_at
                FROM zero_records WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> new ZeroRecordExport(
                rs.getLong("id"),
                rs.getString("state"),
                rs.getString("goal"),
                rs.getString("content"),
                rs.getString("ai_summary"),
                nullableLong(rs, "state_session_id"),
                instant(rs, "created_at"),
                instant(rs, "updated_at")), userId);
    }

    private Map<Long, List<MessageExport>> messages(Long userId) {
        List<MessageRow> rows = jdbcTemplate.query("""
                SELECT m.conversation_id, m.id, m.role, m.content, m.safety_label, m.created_at
                FROM messages m
                JOIN conversations c ON c.id = m.conversation_id
                WHERE c.user_id = ?
                ORDER BY m.created_at
                """, (rs, row) -> new MessageRow(
                rs.getLong("conversation_id"),
                new MessageExport(
                        rs.getLong("id"),
                        rs.getString("role"),
                        rs.getString("content"),
                        rs.getString("safety_label"),
                        instant(rs, "created_at"))), userId);
        Map<Long, List<MessageExport>> grouped = new LinkedHashMap<>();
        for (MessageRow row : rows) {
            grouped.computeIfAbsent(row.conversationId(), ignored -> new java.util.ArrayList<>())
                    .add(row.message());
        }
        return grouped;
    }

    private List<ConversationExport> conversations(Long userId, Map<Long, List<MessageExport>> messages) {
        return jdbcTemplate.query("""
                SELECT id, title, created_at, updated_at
                FROM conversations WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> {
            long conversationId = rs.getLong("id");
            return new ConversationExport(
                    conversationId,
                    rs.getString("title"),
                    instant(rs, "created_at"),
                    instant(rs, "updated_at"),
                    List.copyOf(messages.getOrDefault(conversationId, List.of())));
        }, userId);
    }

    private List<MemoryEntryExport> memoryEntries(Long userId) {
        return jdbcTemplate.query("""
                SELECT id, type, title, summary, importance, source_type, source_id, expires_at,
                       enabled, ai_context_enabled, created_at, updated_at
                FROM memory_entries WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> new MemoryEntryExport(
                rs.getLong("id"),
                rs.getString("type"),
                rs.getString("title"),
                rs.getString("summary"),
                rs.getShort("importance"),
                rs.getString("source_type"),
                nullableLong(rs, "source_id"),
                instant(rs, "expires_at"),
                rs.getBoolean("enabled"),
                rs.getBoolean("ai_context_enabled"),
                instant(rs, "created_at"),
                instant(rs, "updated_at")), userId);
    }

    private List<AiUsageExport> aiUsage(Long userId) {
        return jdbcTemplate.query("""
                SELECT provider, model, operation, outcome, fallback_used, duration_ms,
                       prompt_template_code, prompt_template_version, input_chars, output_chars,
                       input_tokens, output_tokens, error_code, created_at
                FROM ai_usage_logs WHERE user_id = ? ORDER BY created_at
                """, (rs, row) -> new AiUsageExport(
                rs.getString("provider"),
                rs.getString("model"),
                rs.getString("operation"),
                rs.getString("outcome"),
                rs.getBoolean("fallback_used"),
                rs.getInt("duration_ms"),
                rs.getString("prompt_template_code"),
                nullableInteger(rs, "prompt_template_version"),
                rs.getInt("input_chars"),
                rs.getInt("output_chars"),
                nullableInteger(rs, "input_tokens"),
                nullableInteger(rs, "output_tokens"),
                rs.getString("error_code"),
                instant(rs, "created_at")), userId);
    }

    private Long nullableLong(ResultSet resultSet, String column) throws SQLException {
        long value = resultSet.getLong(column);
        return resultSet.wasNull() ? null : value;
    }

    private Integer nullableInteger(ResultSet resultSet, String column) throws SQLException {
        int value = resultSet.getInt(column);
        return resultSet.wasNull() ? null : value;
    }

    private Instant instant(ResultSet resultSet, String column) throws SQLException {
        Object value = resultSet.getObject(column);
        if (value == null) {
            return null;
        }
        if (value instanceof Instant instant) {
            return instant;
        }
        if (value instanceof OffsetDateTime offsetDateTime) {
            return offsetDateTime.toInstant();
        }
        if (value instanceof Timestamp timestamp) {
            return timestamp.toInstant();
        }
        throw new SQLException("Unsupported timestamp value for " + column);
    }

    private record MessageRow(Long conversationId, MessageExport message) {
    }
}
