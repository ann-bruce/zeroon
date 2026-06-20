package ai.zeroon.memory;

import ai.zeroon.memory.MemoryDtos.MemoryEntry;
import ai.zeroon.memory.MemoryDtos.MemoryPage;
import ai.zeroon.security.UserPrincipal;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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
}
