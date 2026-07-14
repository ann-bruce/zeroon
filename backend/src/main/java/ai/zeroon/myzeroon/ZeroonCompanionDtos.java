package ai.zeroon.myzeroon;

import java.time.Instant;

public final class ZeroonCompanionDtos {

    private ZeroonCompanionDtos() {
    }

    public record MeetZeroonCompanionRequest(ZeroonCompanionKey companionKey) {
    }

    public record ZeroonCompanionResponse(
            boolean met,
            ZeroonCompanionKey companionKey,
            String displayName,
            String nameplateSerial,
            Instant metAt,
            Instant createdAt,
            Instant updatedAt) {
    }
}
