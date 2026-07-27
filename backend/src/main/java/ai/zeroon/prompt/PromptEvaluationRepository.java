package ai.zeroon.prompt;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromptEvaluationRepository extends JpaRepository<PromptEvaluationEntity, Long> {

    Optional<PromptEvaluationEntity> findFirstByPromptTemplateIdOrderByCreatedAtDescIdDesc(
            Long promptTemplateId);
}
