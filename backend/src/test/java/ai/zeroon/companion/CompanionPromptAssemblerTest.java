package ai.zeroon.companion;

import static org.assertj.core.api.Assertions.assertThat;

import ai.zeroon.prompt.PromptTemplateSelection;
import org.junit.jupiter.api.Test;

class CompanionPromptAssemblerTest {

    private final CompanionPromptAssembler assembler = new CompanionPromptAssembler();
    private final PromptTemplateSelection persona = new PromptTemplateSelection(
            "COMPANION_REFLECTION",
            "PERSONA LAYER",
            2,
            false);

    @Test
    void assemblesFixedLayerOrder() {
        String prompt = assembler.assemble(
                persona,
                CompanionPurpose.ARCHIVE_OBSERVATION,
                CompanionLanguage.ENGLISH);

        assertThat(prompt)
                .containsSubsequence(
                        "SAFETY AND PRIVACY",
                        "PERSONA LAYER",
                        "PRODUCT SURFACE TASK: ARCHIVE OBSERVATION",
                        "Respond in English")
                .contains("untrusted reference data")
                .contains("Do not reconstruct raw Records");
    }

    @Test
    void eachPurposeHasASeparateServerOwnedTaskContract() {
        for (CompanionPurpose purpose : CompanionPurpose.values()) {
            String prompt = assembler.assemble(
                    persona,
                    purpose,
                    CompanionLanguage.SIMPLIFIED_CHINESE);
            assertThat(prompt)
                    .contains(purpose.providerInstruction().strip())
                    .contains("Respond in Simplified Chinese");
        }
    }
}
