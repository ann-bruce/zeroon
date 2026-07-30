package ai.zeroon.record;

import ai.zeroon.user.UserState;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ZeroRecordRepository extends JpaRepository<ZeroRecordEntity, Long> {

    Page<ZeroRecordEntity> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    List<ZeroRecordEntity> findByUserIdOrderByCreatedAtDesc(Long userId);

    long countByUserId(Long userId);

    Optional<ZeroRecordEntity> findFirstByUserIdOrderByCreatedAtAsc(Long userId);

    long countByUserIdAndCreatedAtLessThanEqual(
            Long userId,
            Instant latestCreatedAt);

    Page<ZeroRecordEntity> findByUserIdAndCreatedAtLessThanEqualOrderByCreatedAtAscIdAsc(
            Long userId,
            Instant latestCreatedAt,
            Pageable pageable);

    Optional<ZeroRecordEntity> findByIdAndUserId(Long id, Long userId);

    Optional<ZeroRecordEntity> findFirstByUserIdAndStateAndGoalAndContentOrderByCreatedAtDesc(
            Long userId,
            UserState state,
            String goal,
            String content);
}
