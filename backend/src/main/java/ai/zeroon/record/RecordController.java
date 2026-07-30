package ai.zeroon.record;

import ai.zeroon.record.RecordDtos.CreateRecordRequest;
import ai.zeroon.record.RecordDtos.ContinuityCueResponse;
import ai.zeroon.record.RecordDtos.RecordPage;
import ai.zeroon.record.RecordDtos.ZeroRecord;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import java.time.DateTimeException;
import java.time.ZoneId;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/records")
public class RecordController {

    private final RecordService recordService;
    private final ContinuityCueService continuityCueService;

    public RecordController(RecordService recordService, ContinuityCueService continuityCueService) {
        this.recordService = recordService;
        this.continuityCueService = continuityCueService;
    }

    @GetMapping
    RecordPage list(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return recordService.list(principal.userId(), page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ZeroRecord create(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateRecordRequest request) {
        return recordService.create(principal.userId(), request);
    }

    @GetMapping("/{recordId}")
    ZeroRecord get(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId) {
        return recordService.get(principal.userId(), recordId);
    }

    @GetMapping("/continuity-cue")
    ContinuityCueResponse continuityCue(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "Asia/Shanghai") String timezone) {
        try {
            return continuityCueService.findFor(principal.userId(), ZoneId.of(timezone));
        } catch (DateTimeException exception) {
            throw new org.springframework.web.server.ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "timezone must be a valid IANA time-zone or UTC-offset id",
                    exception);
        }
    }
}
