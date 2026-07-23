package ai.zeroon.user;

import ai.zeroon.security.UserPrincipal;
import ai.zeroon.user.UserDataDtos.CurrentUserResponse;
import ai.zeroon.user.UserDataDtos.UserDataExportResponse;
import ai.zeroon.user.UserPreferenceDtos.LanguagePreferenceRequest;
import ai.zeroon.user.UserPreferenceDtos.LanguagePreferenceResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
public class UserDataControlController {

    private final UserDataControlService userDataControlService;

    public UserDataControlController(UserDataControlService userDataControlService) {
        this.userDataControlService = userDataControlService;
    }

    @GetMapping
    CurrentUserResponse currentUser(@AuthenticationPrincipal UserPrincipal principal) {
        return userDataControlService.currentUser(principal.userId());
    }

    @GetMapping("/preferences/language")
    LanguagePreferenceResponse languagePreference(
            @AuthenticationPrincipal UserPrincipal principal) {
        return userDataControlService.languagePreference(principal.userId());
    }

    @PutMapping("/preferences/language")
    LanguagePreferenceResponse updateLanguagePreference(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody LanguagePreferenceRequest request) {
        return userDataControlService.updateLanguagePreference(
                principal.userId(), request.languagePreference());
    }

    @GetMapping("/export")
    ResponseEntity<UserDataExportResponse> export(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=zeroon-data-export.json")
                .body(userDataControlService.export(principal.userId()));
    }

    @DeleteMapping("/deletion")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deleteAccount(@AuthenticationPrincipal UserPrincipal principal) {
        userDataControlService.deleteAccount(principal.userId());
    }
}
