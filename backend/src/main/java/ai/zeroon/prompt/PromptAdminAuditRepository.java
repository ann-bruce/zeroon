package ai.zeroon.prompt;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromptAdminAuditRepository
        extends JpaRepository<PromptAdminAuditEntity, Long> {

    List<PromptAdminAuditEntity> findByCodeOrderByCreatedAtAscIdAsc(String code);
}
