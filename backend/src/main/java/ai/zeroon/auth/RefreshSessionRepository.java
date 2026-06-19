package ai.zeroon.auth;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshSessionRepository extends JpaRepository<RefreshSessionEntity, Long> {

    Optional<RefreshSessionEntity> findByTokenHash(String tokenHash);
}
