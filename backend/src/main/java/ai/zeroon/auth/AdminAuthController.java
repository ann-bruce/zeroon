package ai.zeroon.auth;

import ai.zeroon.auth.AdminAuthDtos.AdminAuthResponse;
import ai.zeroon.auth.AdminAuthDtos.AdminEmailCodeRequest;
import ai.zeroon.auth.AdminAuthDtos.AdminEmailLoginRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/auth")
public class AdminAuthController {

    private final AdminAuthService adminAuthService;

    public AdminAuthController(AdminAuthService adminAuthService) {
        this.adminAuthService = adminAuthService;
    }

    @PostMapping("/email/codes")
    @ResponseStatus(HttpStatus.ACCEPTED)
    void requestCode(
            @Valid @RequestBody AdminEmailCodeRequest request,
            HttpServletRequest httpRequest) {
        adminAuthService.requestCode(request.email(), httpRequest.getRemoteAddr());
    }

    @PostMapping("/email/login")
    AdminAuthResponse login(
            @Valid @RequestBody AdminEmailLoginRequest request,
            HttpServletRequest httpRequest) {
        return adminAuthService.login(
                request.email(),
                request.code(),
                request.deviceId(),
                httpRequest.getRemoteAddr());
    }
}
