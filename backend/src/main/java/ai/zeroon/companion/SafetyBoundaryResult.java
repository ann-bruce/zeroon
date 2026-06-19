package ai.zeroon.companion;

public record SafetyBoundaryResult(
        boolean blocked,
        String label,
        String reply) {
}
