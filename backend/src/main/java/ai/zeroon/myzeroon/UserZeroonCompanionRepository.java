package ai.zeroon.myzeroon;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserZeroonCompanionRepository extends JpaRepository<UserZeroonCompanionEntity, Long> {

    Optional<UserZeroonCompanionEntity> findByUserId(Long userId);

    boolean existsByNameplateSerial(String nameplateSerial);
}
