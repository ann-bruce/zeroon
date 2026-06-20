package ai.zeroon.growth;

import ai.zeroon.growth.GrowthDtos.GrowthSummary;
import ai.zeroon.growth.GrowthDtos.StatePatternSummary;
import ai.zeroon.security.UserPrincipal;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/growth")
public class GrowthController {

    private final GrowthService growthService;

    public GrowthController(GrowthService growthService) {
        this.growthService = growthService;
    }

    @GetMapping("/summary")
    public GrowthSummary summary(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam String timezone) {
        return growthService.summary(principal.userId(), timezone);
    }

    @GetMapping("/state-pattern")
    public StatePatternSummary statePattern(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam String timezone,
            @RequestParam(defaultValue = "14") int days) {
        return growthService.statePattern(principal.userId(), timezone, days);
    }
}
