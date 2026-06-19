package ai.zeroon.common;

import java.time.Instant;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/system")
public class SystemController {

    @GetMapping("/health")
    Map<String, Object> health() {
        return Map.of(
                "status", "UP",
                "service", "zeroon-backend",
                "timestamp", Instant.now().toString());
    }
}

