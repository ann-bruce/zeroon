package ai.zeroon.prompt;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PromptActivationRepository
        extends JpaRepository<PromptActivationEntity, String> {

    @Query("""
            select activation
            from PromptActivationEntity activation
            join fetch activation.promptTemplate
            where activation.code = :code
            """)
    Optional<PromptActivationEntity> findActiveByCode(@Param("code") String code);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select activation
            from PromptActivationEntity activation
            join fetch activation.promptTemplate
            where activation.code = :code
            """)
    Optional<PromptActivationEntity> findByCodeForUpdate(@Param("code") String code);

    @Query("select activation from PromptActivationEntity activation join fetch activation.promptTemplate")
    List<PromptActivationEntity> findAllWithTemplates();
}
