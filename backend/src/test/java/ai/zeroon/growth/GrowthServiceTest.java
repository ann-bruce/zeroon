package ai.zeroon.growth;

import static org.assertj.core.api.Assertions.assertThat;

import ai.zeroon.record.ZeroRecordEntity;
import ai.zeroon.record.ZeroRecordRepository;
import ai.zeroon.state.StateHistoryEntity;
import ai.zeroon.state.StateHistoryRepository;
import ai.zeroon.state.StateSource;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserState;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.context.annotation.Import;

@DataJpaTest
@Import(GrowthServiceTestConfig.class)
class GrowthServiceTest {

    @Autowired
    private GrowthService growthService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ZeroRecordRepository zeroRecordRepository;

    @Autowired
    private StateHistoryRepository stateHistoryRepository;

    @Test
    void newUserHasEmptyGrowthSummary() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_new_user",
                "13900000001",
                Instant.parse("2026-06-10T00:00:00Z")));

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.continuousResetDays()).isZero();
        assertThat(summary.cachedEntries()).isZero();
        assertThat(summary.firstRecordDate()).isNull();
        assertThat(summary.companionDays()).isEqualTo(1);
        assertThat(summary.timezone()).isEqualTo("Asia/Shanghai");
    }

    @Test
    void calculatesCompanionDaysAndContinuousResetDaysByTimezone() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_existing_user",
                "13900000002",
                Instant.parse("2025-06-10T16:00:00Z")));
        zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                UserState.CALM,
                "quiet",
                "start",
                "first",
                Instant.parse("2025-06-10T16:30:00Z")));
        zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                UserState.FOCUS,
                null,
                "yesterday",
                null,
                Instant.parse("2026-06-08T16:30:00Z")));
        zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                UserState.CREATE,
                null,
                "today",
                null,
                Instant.parse("2026-06-09T16:30:00Z")));

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.companionDays()).isEqualTo(365);
        assertThat(summary.cachedEntries()).isEqualTo(3);
        assertThat(summary.firstRecordDate()).isEqualTo("2025-06-11");
        assertThat(summary.continuousResetDays()).isEqualTo(2);
        assertThat(summary.calculatedAt()).isEqualTo(GrowthServiceTestConfig.FIXED_INSTANT);
    }

    @Test
    void multipleRecordsOnSameCalendarDateCountOnce() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_same_day_user",
                "13900000005",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(user, "2026-06-08T16:10:00Z");
        saveRecord(user, "2026-06-08T23:30:00Z");
        saveRecord(user, "2026-06-09T16:10:00Z");
        saveRecord(user, "2026-06-09T17:10:00Z");

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.cachedEntries()).isEqualTo(4);
        assertThat(summary.continuousResetDays()).isEqualTo(2);
    }

    @Test
    void streakCanEndYesterdayWhenTodayHasNoRecord() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_yesterday_user",
                "13900000006",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(user, "2026-06-06T16:10:00Z");
        saveRecord(user, "2026-06-07T16:10:00Z");
        saveRecord(user, "2026-06-08T16:10:00Z");

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.continuousResetDays()).isEqualTo(3);
    }

    @Test
    void brokenStreakDoesNotCountOlderHistory() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_broken_user",
                "13900000007",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(user, "2026-06-04T16:10:00Z");
        saveRecord(user, "2026-06-06T16:10:00Z");
        saveRecord(user, "2026-06-09T16:10:00Z");

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.continuousResetDays()).isEqualTo(1);
        assertThat(summary.cachedEntries()).isEqualTo(3);
    }

    @Test
    void timezoneChangesCalendarDateInterpretationOnly() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_timezone_user",
                "13900000008",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(user, "2026-06-09T16:30:00Z");

        var shanghaiSummary = growthService.summary(user.getId(), "Asia/Shanghai");
        var utcSummary = growthService.summary(user.getId(), "UTC");

        assertThat(shanghaiSummary.firstRecordDate()).isEqualTo("2026-06-10");
        assertThat(shanghaiSummary.continuousResetDays()).isEqualTo(1);
        assertThat(utcSummary.firstRecordDate()).isEqualTo("2026-06-09");
        assertThat(utcSummary.continuousResetDays()).isEqualTo(1);
    }

    @Test
    void staleRecordDoesNotCreateCurrentStreak() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_stale_user",
                "13900000009",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(user, "2026-06-05T16:10:00Z");
        saveRecord(user, "2026-06-06T16:10:00Z");

        var summary = growthService.summary(user.getId(), "Asia/Shanghai");

        assertThat(summary.continuousResetDays()).isZero();
        assertThat(summary.cachedEntries()).isEqualTo(2);
    }

    @Test
    void statePatternSummarizesRecentUserVisibleStateHistory() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_pattern_user",
                "13900000014",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveState(user, null, UserState.CALM, "2026-06-08T00:00:00Z");
        saveState(user, UserState.CALM, UserState.FOCUS, "2026-06-09T00:00:00Z");
        saveState(user, UserState.FOCUS, UserState.FOCUS, "2026-06-10T00:00:00Z");
        saveState(user, UserState.FOCUS, UserState.TIRED, "2026-05-01T00:00:00Z");

        var summary = growthService.statePattern(user.getId(), "Asia/Shanghai", 7);

        assertThat(summary.days()).isEqualTo(7);
        assertThat(summary.sampleSize()).isEqualTo(3);
        assertThat(summary.dominantState()).isEqualTo(UserState.FOCUS);
        assertThat(summary.distribution().get(UserState.FOCUS)).isEqualTo(2);
        assertThat(summary.distribution().get(UserState.CALM)).isEqualTo(1);
        assertThat(summary.distribution().get(UserState.TIRED)).isZero();
        assertThat(summary.observation()).contains("不代表固定标签");
        assertThat(summary.dataSources()).containsExactly("state_history.current_state", "state_history.created_at");
    }

    @Test
    void statePatternHasClearEmptyObservation() {
        UserEntity user = userRepository.save(new UserEntity(
                "growth_pattern_empty_user",
                "13900000015",
                Instant.parse("2026-06-01T00:00:00Z")));

        var summary = growthService.statePattern(user.getId(), "Asia/Shanghai", 14);

        assertThat(summary.sampleSize()).isZero();
        assertThat(summary.dominantState()).isNull();
        assertThat(summary.observation()).contains("还没有足够的状态记录");
    }

    @Test
    void growthSummaryIgnoresOtherUsersRecords() {
        UserEntity owner = userRepository.save(new UserEntity(
                "growth_owner_user",
                "13900000018",
                Instant.parse("2026-06-01T00:00:00Z")));
        UserEntity other = userRepository.save(new UserEntity(
                "growth_other_user",
                "13900000019",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveRecord(owner, "2026-06-09T16:10:00Z");
        saveRecord(other, "2026-06-08T16:10:00Z");
        saveRecord(other, "2026-06-09T16:10:00Z");

        var summary = growthService.summary(owner.getId(), "Asia/Shanghai");

        assertThat(summary.cachedEntries()).isEqualTo(1);
        assertThat(summary.continuousResetDays()).isEqualTo(1);
    }

    @Test
    void statePatternIgnoresOtherUsersStateHistory() {
        UserEntity owner = userRepository.save(new UserEntity(
                "pattern_owner_user",
                "13900000020",
                Instant.parse("2026-06-01T00:00:00Z")));
        UserEntity other = userRepository.save(new UserEntity(
                "pattern_other_user",
                "13900000021",
                Instant.parse("2026-06-01T00:00:00Z")));
        saveState(owner, null, UserState.CALM, "2026-06-10T00:00:00Z");
        saveState(other, null, UserState.OVERLOAD, "2026-06-10T00:00:00Z");
        saveState(other, UserState.OVERLOAD, UserState.OVERLOAD, "2026-06-09T00:00:00Z");

        var summary = growthService.statePattern(owner.getId(), "Asia/Shanghai", 14);

        assertThat(summary.sampleSize()).isEqualTo(1);
        assertThat(summary.dominantState()).isEqualTo(UserState.CALM);
        assertThat(summary.distribution().get(UserState.OVERLOAD)).isZero();
    }

    private void saveRecord(UserEntity user, String createdAt) {
        zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                UserState.CALM,
                null,
                null,
                "record",
                Instant.parse(createdAt)));
    }

    private void saveState(UserEntity user, UserState previousState, UserState currentState, String createdAt) {
        stateHistoryRepository.save(new StateHistoryEntity(
                user,
                previousState,
                currentState,
                StateSource.MANUAL,
                Instant.parse(createdAt)));
    }
}

class GrowthServiceTestConfig {

    static final Instant FIXED_INSTANT = Instant.parse("2026-06-10T04:00:00Z");

    @org.springframework.context.annotation.Bean
    Clock clock() {
        return Clock.fixed(FIXED_INSTANT, ZoneOffset.UTC);
    }

    @org.springframework.context.annotation.Bean
    GrowthService growthService(
            UserRepository userRepository,
            ZeroRecordRepository zeroRecordRepository,
            StateHistoryRepository stateHistoryRepository,
            Clock clock) {
        return new GrowthService(userRepository, zeroRecordRepository, stateHistoryRepository, clock);
    }
}
