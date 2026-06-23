package ai.zeroon.profile;

import ai.zeroon.profile.ProfileDtos.UpdateUserProfileRequest;
import ai.zeroon.profile.ProfileDtos.UserProfileResponse;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/profile")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping
    UserProfileResponse get(@AuthenticationPrincipal UserPrincipal principal) {
        return userProfileService.get(principal.userId());
    }

    @PutMapping
    UserProfileResponse update(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody UpdateUserProfileRequest request) {
        return userProfileService.update(principal.userId(), request);
    }
}
