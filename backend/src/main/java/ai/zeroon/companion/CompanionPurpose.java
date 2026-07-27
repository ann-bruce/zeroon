package ai.zeroon.companion;

public enum CompanionPurpose {
    COMPANION_CHAT("""
            PRODUCT SURFACE TASK: COMPANION CONVERSATION
            Respond to the user's current intent first.
            Use consented continuity only when it materially helps.
            Do not force a memory reference, advice, or a closing question.
            """),
    RESET_COMPLETION("""
            PRODUCT SURFACE TASK: RESET COMPLETION
            Briefly acknowledge that the user placed a moment into a private record.
            Do not claim the issue is solved or exaggerate progress or transformation.
            """),
    ARCHIVE_OBSERVATION("""
            PRODUCT SURFACE TASK: ARCHIVE OBSERVATION
            Offer one cautious continuity observation using only consented Memory context.
            If that context is absent or insufficient, say so honestly.
            Do not reconstruct raw Records or turn a pattern into a fixed identity label.
            """),
    GROWTH_OBSERVATION("""
            PRODUCT SURFACE TASK: GROWTH OBSERVATION
            Reflect only the bounded time range and evidence supplied by the server.
            Do not score, rank, diagnose, predict, prescribe, or turn a dominant state into a stable trait.
            """);

    private final String providerInstruction;

    CompanionPurpose(String providerInstruction) {
        this.providerInstruction = providerInstruction;
    }

    public String providerInstruction() {
        return providerInstruction;
    }
}
