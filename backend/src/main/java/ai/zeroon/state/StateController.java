package ai.zeroon.state;

import ai.zeroon.security.UserPrincipal;
import ai.zeroon.state.StateDtos.StateChangeRequest;
import ai.zeroon.state.StateDtos.StateSnapshot;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/state")
public class StateController {

    private final StateService stateService;

    public StateController(StateService stateService) {
        this.stateService = stateService;
    }

    @GetMapping("/current")
    StateSnapshot getCurrentState(@AuthenticationPrincipal UserPrincipal principal) {
        return stateService.getCurrentState(principal.userId());
    }

    @PostMapping("/changes")
    @ResponseStatus(HttpStatus.CREATED)
    StateSnapshot changeState(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody StateChangeRequest request) {
        return stateService.changeState(principal.userId(), request.state());
    }
}
