package ai.zeroon.prompt;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

@DataJpaTest
class PromptTemplateServiceTest {

    @Autowired
    private PromptTemplateRepository promptTemplateRepository;

    @Autowired
    private PromptActivationRepository promptActivationRepository;

    @Test
    void selectsOnlyTheExplicitlyActiveCompanionTemplate() {
        PromptTemplateEntity old = promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "old",
                "old prompt",
                true,
                1));
        promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "latest",
                "latest prompt",
                true,
                2));
        promptActivationRepository.save(new PromptActivationEntity(
                old,
                null,
                Instant.parse("2026-07-27T00:00:00Z")));
        var service = new PromptTemplateService(promptActivationRepository);

        PromptTemplateSelection selection = service.companionReflectionPrompt();

        assertThat(selection.content()).isEqualTo("old prompt");
        assertThat(selection.version()).isEqualTo(1);
        assertThat(selection.fallback()).isFalse();
    }

    @Test
    void fallsBackWhenTemplatesExistButNoneIsExplicitlyActive() {
        promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "unactivated",
                "must not run",
                true,
                1));
        var service = new PromptTemplateService(promptActivationRepository);

        PromptTemplateSelection selection = service.companionReflectionPrompt();

        assertThat(selection.content()).contains("long-term companion");
        assertThat(selection.content()).doesNotContain("must not run");
        assertThat(selection.version()).isNull();
        assertThat(selection.fallback()).isTrue();
    }
}
