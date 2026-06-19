package ai.zeroon.auth;

import ai.zeroon.auth.AuthDtos.AuthResponse;
import ai.zeroon.auth.AuthDtos.CodeRequest;
import ai.zeroon.auth.AuthDtos.LoginRequest;
import ai.zeroon.auth.AuthDtos.RefreshRequest;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/codes")
    @ResponseStatus(HttpStatus.ACCEPTED)
    void requestCode(@Valid @RequestBody CodeRequest request) {
        authService.requestCode(request.mobile());
    }

    @PostMapping("/login")
    AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request.mobile(), request.code(), request.deviceId());
    }

    @PostMapping("/refresh")
    AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void logout(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody RefreshRequest request) {
        authService.logout(principal, request.refreshToken());
    }
}
