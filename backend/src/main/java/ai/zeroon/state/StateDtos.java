package ai.zeroon.state;

import ai.zeroon.user.UserState;
import java.time.Instant;

public final class StateDtos {

    private StateDtos() {
    }

    public record StateSnapshot(
            UserState state,
            StateSource source,
            Instant changedAt,
            Long sessionId,
            Instant startedAt,
            long elapsedSeconds) {
    }

    public record StateChangeRequest(
            UserState state) {
    }

    public record StartStateSessionRequest(
            UserState state) {
    }
}
