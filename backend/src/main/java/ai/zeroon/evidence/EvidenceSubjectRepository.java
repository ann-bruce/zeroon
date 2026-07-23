package ai.zeroon.evidence;

import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EvidenceSubjectRepository extends JpaRepository<EvidenceSubjectEntity, Long> {

    Optional<EvidenceSubjectEntity> findByUser_Id(Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select subject from EvidenceSubjectEntity subject where subject.user.id = :userId")
    Optional<EvidenceSubjectEntity> findByUserIdForUpdate(@Param("userId") Long userId);

    @Modifying
    @Query("delete from EvidenceSubjectEntity subject "
            + "where subject.choiceChangedAt < :cutoff "
            + "and not exists (select event.id from EvidenceEventEntity event "
            + "where event.subject = subject)")
    int deleteStaleWithoutEvents(@Param("cutoff") Instant cutoff);
}
