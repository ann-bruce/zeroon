package ai.zeroon.prompt;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

@DataJpaTest
class PromptTemplateServiceTest {

    @Autowired
    private PromptTemplateRepository promptTemplateRepository;

    @Test
    void selectsLatestEnabledCompanionReflectionTemplate() {
        promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "old",
                "old prompt",
                true,
                1));
        promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "disabled",
                "disabled prompt",
                false,
                3));
        promptTemplateRepository.save(new PromptTemplateEntity(
                PromptTemplateService.COMPANION_REFLECTION_CODE,
                "latest",
                "latest prompt",
                true,
                2));

        var service = new PromptTemplateService(promptTemplateRepository);

        PromptTemplateSelection selection = service.companionReflectionPrompt();

        assertThat(selection.content()).isEqualTo("latest prompt");
        assertThat(selection.version()).isEqualTo(2);
        assertThat(selection.fallback()).isFalse();
    }

    @Test
    void fallsBackWhenNoTemplateExists() {
        var service = new PromptTemplateService(promptTemplateRepository);

        PromptTemplateSelection selection = service.companionReflectionPrompt();

        assertThat(selection.content()).contains("long-term companion");
        assertThat(selection.version()).isNull();
        assertThat(selection.fallback()).isTrue();
    }
}
