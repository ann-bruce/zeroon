package ai.zeroon.state;

import ai.zeroon.user.UserState;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public final class StateDtos {

    private StateDtos() {
    }

    public record StateSnapshot(
            UserState state,
            StateSource source,
            Instant changedAt) {
    }

    public record StateChangeRequest(
            @NotNull UserState state) {
    }
}
