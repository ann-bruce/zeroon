package ai.zeroon.support;

import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SupportRequestRepository extends JpaRepository<SupportRequestEntity, Long> {

    Optional<SupportRequestEntity> findByUser_IdAndClientSubmissionId(Long userId, String clientSubmissionId);

    Optional<SupportRequestEntity> findByPublicReferenceAndUser_Id(String publicReference, Long userId);

    Optional<SupportRequestEntity> findByPublicReference(String publicReference);

    Page<SupportRequestEntity> findByUser_IdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    long countByUser_IdAndCreatedAtAfter(Long userId, Instant createdAfter);

    boolean existsByPublicReference(String publicReference);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select request from SupportRequestEntity request "
            + "where request.publicReference = :reference and request.user.id = :userId")
    Optional<SupportRequestEntity> findOwnedForUpdate(
            @Param("reference") String reference,
            @Param("userId") Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select request from SupportRequestEntity request "
            + "where request.publicReference = :reference")
    Optional<SupportRequestEntity> findAdminForUpdate(@Param("reference") String reference);

    @Query("select request from SupportRequestEntity request "
            + "where (:status is null or request.status = :status) "
            + "and (:category is null or request.category = :category) "
            + "and (:escalated is null or request.escalated = :escalated) "
            + "order by request.updatedAt desc")
    Page<SupportRequestEntity> findAdminQueue(
            @Param("status") SupportRequestStatus status,
            @Param("category") SupportCategory category,
            @Param("escalated") Boolean escalated,
            Pageable pageable);

    @Modifying
    @Query("delete from SupportRequestEntity request "
            + "where request.status = ai.zeroon.support.SupportRequestStatus.CLOSED "
            + "and request.closedAt is not null and request.closedAt < :cutoff")
    int deleteExpiredClosedRequests(@Param("cutoff") Instant cutoff);
}
