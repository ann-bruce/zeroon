package ai.zeroon.profile;

import ai.zeroon.profile.ProfileDtos.AgeRangeValue;
import ai.zeroon.profile.ProfileDtos.UpdateUserProfileRequest;
import ai.zeroon.profile.ProfileDtos.UserProfileResponse;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserProfileService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    public UserProfileService(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse get(Long userId) {
        return userProfileRepository.findByUserId(userId)
                .map(this::toDto)
                .orElseGet(this::defaultProfile);
    }

    @Transactional
    public UserProfileResponse update(Long userId, UpdateUserProfileRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        var profile = userProfileRepository.findByUserId(userId)
                .orElseGet(() -> new UserProfileEntity(user));
        profile.update(
                normalize(request.nickname()),
                request.avatarPreset(),
                toEntityAgeRange(request.ageRange()),
                normalize(request.occupation()),
                normalize(request.selfDescription()),
                Boolean.TRUE.equals(request.aiProfileContextEnabled()));
        return toDto(userProfileRepository.save(profile));
    }

    private UserProfileResponse defaultProfile() {
        return new UserProfileResponse(
                null,
                null,
                null,
                null,
                null,
                false,
                null,
                null);
    }

    private UserProfileResponse toDto(UserProfileEntity profile) {
        return new UserProfileResponse(
                profile.getNickname(),
                profile.getAvatarPreset(),
                AgeRangeValue.fromEntityValue(profile.getAgeRange()),
                profile.getOccupation(),
                profile.getSelfDescription(),
                profile.isAiProfileContextEnabled(),
                profile.getCreatedAt(),
                profile.getUpdatedAt());
    }

    private AgeRange toEntityAgeRange(AgeRangeValue value) {
        return value == null ? null : value.toEntityValue();
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
