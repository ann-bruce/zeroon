package ai.zeroon.prompt;

import java.util.List;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PromptTemplateRepository extends JpaRepository<PromptTemplateEntity, Long> {

    List<PromptTemplateEntity> findAllByOrderByCodeAscVersionDesc();

    Optional<PromptTemplateEntity> findFirstByCodeOrderByVersionDesc(String code);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select template from PromptTemplateEntity template where template.id = :id")
    Optional<PromptTemplateEntity> findByIdForUpdate(@Param("id") Long id);
}
