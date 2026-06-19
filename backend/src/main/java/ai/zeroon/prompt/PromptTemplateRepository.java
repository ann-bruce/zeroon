package ai.zeroon.prompt;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromptTemplateRepository extends JpaRepository<PromptTemplateEntity, Long> {

    Optional<PromptTemplateEntity> findFirstByCodeAndEnabledTrueOrderByVersionDesc(String code);

    List<PromptTemplateEntity> findAllByOrderByCodeAscVersionDesc();
}
