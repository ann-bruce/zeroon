package ai.zeroon.state;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StateSessionRepository extends JpaRepository<StateSessionEntity, Long> {

    Optional<StateSessionEntity> findFirstByUserIdAndEndedAtIsNull(Long userId);

    @Modifying
    @Query("""
            update StateSessionEntity session
            set session.endedByRecordId = null
            where session.user.id = :userId
              and session.endedByRecordId = :recordId
            """)
    int detachOwnedRecord(
            @Param("userId") Long userId,
            @Param("recordId") Long recordId);
}
