package ai.zeroon.support;

import ai.zeroon.security.UserPrincipal;
import ai.zeroon.support.SupportDtos.AddSupportMessageRequest;
import ai.zeroon.support.SupportDtos.CreateResult;
import ai.zeroon.support.SupportDtos.CreateSupportRequest;
import ai.zeroon.support.SupportDtos.SupportMessageResponse;
import ai.zeroon.support.SupportDtos.SupportRequestDetail;
import ai.zeroon.support.SupportDtos.SupportRequestPage;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class SupportRequestController {

    private final SupportRequestService supportRequestService;

    public SupportRequestController(SupportRequestService supportRequestService) {
        this.supportRequestService = supportRequestService;
    }

    @PostMapping("/support/requests")
    ResponseEntity<SupportRequestDetail> create(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateSupportRequest request) {
        CreateResult result = supportRequestService.create(principal.userId(), request);
        return ResponseEntity.status(result.created() ? HttpStatus.CREATED : HttpStatus.OK)
                .body(result.detail());
    }

    @GetMapping("/me/support-requests")
    SupportRequestPage list(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return supportRequestService.list(principal.userId(), page, size);
    }

    @GetMapping("/me/support-requests/{reference}")
    SupportRequestDetail get(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String reference) {
        return supportRequestService.get(principal.userId(), reference);
    }

    @PostMapping("/me/support-requests/{reference}/messages")
    ResponseEntity<SupportMessageResponse> addMessage(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable String reference,
            @Valid @RequestBody AddSupportMessageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(supportRequestService.addMessage(principal.userId(), reference, request));
    }
}
