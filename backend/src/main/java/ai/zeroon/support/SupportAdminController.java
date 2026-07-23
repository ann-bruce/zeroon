package ai.zeroon.support;

import ai.zeroon.security.UserPrincipal;
import ai.zeroon.support.SupportAdminDtos.AdminSupportMessageRequest;
import ai.zeroon.support.SupportAdminDtos.AdminSupportRequestDetail;
import ai.zeroon.support.SupportAdminDtos.AdminSupportRequestPage;
import ai.zeroon.support.SupportAdminDtos.AdminSupportUpdateRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/support-requests")
public class SupportAdminController {

    private final SupportAdminService supportAdminService;

    public SupportAdminController(SupportAdminService supportAdminService) {
        this.supportAdminService = supportAdminService;
    }

    @GetMapping
    AdminSupportRequestPage list(
            @RequestParam(required = false) SupportRequestStatus status,
            @RequestParam(required = false) SupportCategory category,
            @RequestParam(required = false) Boolean escalated,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return supportAdminService.list(status, category, escalated, page, size);
    }

    @GetMapping("/{reference}")
    AdminSupportRequestDetail get(@PathVariable String reference) {
        return supportAdminService.get(reference);
    }

    @PatchMapping("/{reference}")
    AdminSupportRequestDetail update(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String reference,
            @Valid @RequestBody AdminSupportUpdateRequest request) {
        return supportAdminService.update(principal.userId(), reference, request);
    }

    @PostMapping("/{reference}/messages")
    ResponseEntity<AdminSupportRequestDetail> addMessage(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String reference,
            @Valid @RequestBody AdminSupportMessageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(supportAdminService.addMessage(principal.userId(), reference, request));
    }
}
