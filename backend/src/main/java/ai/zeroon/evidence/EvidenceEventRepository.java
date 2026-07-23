package ai.zeroon.evidence;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EvidenceEventRepository extends JpaRepository<EvidenceEventEntity, Long> {

    Optional<EvidenceEventEntity> findBySubject_IdAndClientEventId(Long subjectId, UUID clientEventId);

    List<EvidenceEventEntity> findBySubject_IdOrderByOccurredDateAscReceivedAtAsc(Long subjectId);

    long countBySubject_IdAndReceivedAtAfter(Long subjectId, Instant receivedAfter);

    @Modifying
    @Query("delete from EvidenceEventEntity event where event.receivedAt < :cutoff")
    int deleteReceivedBefore(@Param("cutoff") Instant cutoff);
}
