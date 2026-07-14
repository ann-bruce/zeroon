package ai.zeroon.memory;

import ai.zeroon.memory.MemoryDtos.MemoryEntry;
import ai.zeroon.memory.MemoryDtos.MemoryPage;
import ai.zeroon.memory.MemoryDtos.UpdateMemoryControlsRequest;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/memory")
public class MemoryController {

    private final MemoryService memoryService;

    public MemoryController(MemoryService memoryService) {
        this.memoryService = memoryService;
    }

    @GetMapping
    public MemoryPage list(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return memoryService.list(principal.userId(), page, size);
    }

    @GetMapping("/{memoryId}")
    public MemoryEntry get(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long memoryId) {
        return memoryService.get(principal.userId(), memoryId);
    }

    @PatchMapping("/{memoryId}")
    public MemoryEntry updateControls(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long memoryId,
            @Valid @RequestBody UpdateMemoryControlsRequest request) {
        return memoryService.updateControls(principal.userId(), memoryId, request);
    }

    @DeleteMapping("/{memoryId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long memoryId) {
        memoryService.delete(principal.userId(), memoryId);
    }
}
