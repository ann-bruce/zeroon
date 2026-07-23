package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceDtos.EvidenceEventRequest;
import ai.zeroon.evidence.EvidenceDtos.EvidenceEventResponse;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceRequest;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceResponse;
import ai.zeroon.evidence.EvidenceService.IngestResult;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class EvidenceController {

    private final EvidenceService evidenceService;

    public EvidenceController(EvidenceService evidenceService) {
        this.evidenceService = evidenceService;
    }

    @GetMapping("/me/preferences/beta-evidence")
    EvidencePreferenceResponse preference(
            @AuthenticationPrincipal UserPrincipal principal) {
        return evidenceService.preference(principal.userId());
    }

    @PutMapping("/me/preferences/beta-evidence")
    EvidencePreferenceResponse updatePreference(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody EvidencePreferenceRequest request) {
        return evidenceService.updatePreference(principal.userId(), request);
    }

    @PostMapping("/evidence/events")
    ResponseEntity<EvidenceEventResponse> ingest(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody EvidenceEventRequest request) {
        IngestResult result = evidenceService.ingest(principal.userId(), request);
        return ResponseEntity.status(result.created() ? HttpStatus.CREATED : HttpStatus.OK)
                .body(result.response());
    }
}
