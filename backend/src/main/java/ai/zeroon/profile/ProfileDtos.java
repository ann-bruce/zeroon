package ai.zeroon.profile;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;
import jakarta.validation.constraints.Size;
import java.time.Instant;

public final class ProfileDtos {

    private ProfileDtos() {
    }

    public record UpdateUserProfileRequest(
            @Size(max = 30) String nickname,
            AvatarPreset avatarPreset,
            AgeRangeValue ageRange,
            @Size(max = 40) String occupation,
            @Size(max = 120) String selfDescription,
            @JsonProperty("aiProfileContextEnabled")
            Boolean aiProfileContextEnabled) {
    }

    public record UserProfileResponse(
            String nickname,
            AvatarPreset avatarPreset,
            AgeRangeValue ageRange,
            String occupation,
            String selfDescription,
            boolean aiProfileContextEnabled,
            Instant createdAt,
            Instant updatedAt) {
    }

    public enum AgeRangeValue {
        UNDER_18("UNDER_18"),
        AGE_18_24("18_24"),
        AGE_25_34("25_34"),
        AGE_35_44("35_44"),
        AGE_45_54("45_54"),
        AGE_55_PLUS("55_PLUS"),
        PREFER_NOT_TO_SAY("PREFER_NOT_TO_SAY");

        private final String value;

        AgeRangeValue(String value) {
            this.value = value;
        }

        @JsonValue
        public String value() {
            return value;
        }

        @JsonCreator
        public static AgeRangeValue fromJson(String value) {
            if (value == null) {
                return null;
            }
            for (AgeRangeValue candidate : values()) {
                if (candidate.value.equals(value)) {
                    return candidate;
                }
            }
            throw new IllegalArgumentException("Invalid age range: " + value);
        }

        AgeRange toEntityValue() {
            return switch (this) {
                case UNDER_18 -> AgeRange.UNDER_18;
                case AGE_18_24 -> AgeRange.AGE_18_24;
                case AGE_25_34 -> AgeRange.AGE_25_34;
                case AGE_35_44 -> AgeRange.AGE_35_44;
                case AGE_45_54 -> AgeRange.AGE_45_54;
                case AGE_55_PLUS -> AgeRange.AGE_55_PLUS;
                case PREFER_NOT_TO_SAY -> AgeRange.PREFER_NOT_TO_SAY;
            };
        }

        static AgeRangeValue fromEntityValue(AgeRange value) {
            if (value == null) {
                return null;
            }
            return switch (value) {
                case UNDER_18 -> UNDER_18;
                case AGE_18_24 -> AGE_18_24;
                case AGE_25_34 -> AGE_25_34;
                case AGE_35_44 -> AGE_35_44;
                case AGE_45_54 -> AGE_45_54;
                case AGE_55_PLUS -> AGE_55_PLUS;
                case PREFER_NOT_TO_SAY -> PREFER_NOT_TO_SAY;
            };
        }
    }
}
