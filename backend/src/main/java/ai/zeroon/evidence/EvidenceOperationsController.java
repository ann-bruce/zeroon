package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceOperationsDtos.EvidenceOperationsResponse;
import java.time.LocalDate;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/evidence/cohorts")
public class EvidenceOperationsController {

    private final EvidenceOperationsService operationsService;

    public EvidenceOperationsController(EvidenceOperationsService operationsService) {
        this.operationsService = operationsService;
    }

    @GetMapping
    public EvidenceOperationsResponse readCohort(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate cohortStart,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate cohortEnd,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOfDate) {
        return operationsService.read(cohortStart, cohortEnd, asOfDate);
    }
}
