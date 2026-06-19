package ai.zeroon.companion;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SafetyBoundaryServiceTest {

    private final SafetyBoundaryService safetyBoundaryService = new SafetyBoundaryService();

    @Test
    void blocksMedicalLegalFinancialAndPsychologicalDiagnosisRequests() {
        assertThat(safetyBoundaryService.evaluate("Can you diagnose my illness?").label())
                .isEqualTo("MEDICAL");
        assertThat(safetyBoundaryService.evaluate("我要不要起诉他？").label())
                .isEqualTo("LEGAL");
        assertThat(safetyBoundaryService.evaluate("Should I buy bitcoin?").label())
                .isEqualTo("FINANCIAL");
        assertThat(safetyBoundaryService.evaluate("我是不是抑郁症？").label())
                .isEqualTo("PSYCHOLOGICAL_DIAGNOSIS");
    }

    @Test
    void allowsOrdinaryReflectionRequests() {
        assertThat(safetyBoundaryService.evaluate("Help me reflect on today's small progress").blocked())
                .isFalse();
    }
}
