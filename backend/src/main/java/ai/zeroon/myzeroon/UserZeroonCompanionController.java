package ai.zeroon.myzeroon;

import ai.zeroon.myzeroon.ZeroonCompanionDtos.MeetZeroonCompanionRequest;
import ai.zeroon.myzeroon.ZeroonCompanionDtos.ZeroonCompanionResponse;
import ai.zeroon.security.UserPrincipal;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/zeroon-companion")
public class UserZeroonCompanionController {

    private final UserZeroonCompanionService companionService;

    public UserZeroonCompanionController(UserZeroonCompanionService companionService) {
        this.companionService = companionService;
    }

    @GetMapping
    ZeroonCompanionResponse get(@AuthenticationPrincipal UserPrincipal principal) {
        return companionService.get(principal.userId());
    }

    @PostMapping
    ZeroonCompanionResponse meet(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody MeetZeroonCompanionRequest request) {
        return companionService.meet(principal.userId(), request);
    }
}
