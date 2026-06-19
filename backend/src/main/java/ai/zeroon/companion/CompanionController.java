package ai.zeroon.companion;

import ai.zeroon.companion.CompanionDtos.ChatRequest;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/companion")
public class CompanionController {

    private final CompanionService companionService;

    public CompanionController(CompanionService companionService) {
        this.companionService = companionService;
    }

    @PostMapping("/messages")
    ChatResponse sendMessage(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody ChatRequest request) {
        return companionService.sendMessage(principal.userId(), request.conversationId(), request.message());
    }
}
