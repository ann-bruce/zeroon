package ai.zeroon.support;

import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupportMessageRepository extends JpaRepository<SupportMessageEntity, Long> {

    List<SupportMessageEntity> findByRequest_IdAndVisibilityOrderByCreatedAt(
            Long requestId, SupportMessageVisibility visibility);

    List<SupportMessageEntity> findByRequest_IdOrderByCreatedAt(Long requestId);

    long countByRequest_User_IdAndActorTypeAndCreatedAtAfter(
            Long userId, SupportActorType actorType, Instant createdAfter);
}
