package ai.zeroon.companion;

public enum SelfHarmSafetyPath {
    IMMINENT("SELF_HARM_IMMINENT"),
    CONCERN("SELF_HARM_CONCERN"),
    THIRD_PARTY("SELF_HARM_THIRD_PARTY");

    private final String label;

    SelfHarmSafetyPath(String label) {
        this.label = label;
    }

    public String label() {
        return label;
    }
}
