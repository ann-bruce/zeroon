package ai.zeroon.prompt;

import ai.zeroon.prompt.PromptTemplateDtos.PromptActivationRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptAuditResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptCreateRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptEvaluationRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptEvaluationResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptReviewRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateDetailResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateListResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateSummaryResponse;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.Clock;
import java.time.Instant;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PromptGovernanceService {

    private final PromptTemplateRepository templateRepository;
    private final PromptActivationRepository activationRepository;
    private final PromptAdminAuditRepository auditRepository;
    private final PromptEvaluationRepository evaluationRepository;
    private final UserRepository userRepository;
    private final Clock clock;

    public PromptGovernanceService(
            PromptTemplateRepository templateRepository,
            PromptActivationRepository activationRepository,
            PromptAdminAuditRepository auditRepository,
            PromptEvaluationRepository evaluationRepository,
            UserRepository userRepository,
            Clock clock) {
        this.templateRepository = templateRepository;
        this.activationRepository = activationRepository;
        this.auditRepository = auditRepository;
        this.evaluationRepository = evaluationRepository;
        this.userRepository = userRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public PromptTemplateListResponse list() {
        Map<String, Long> activeIds = activationRepository.findAllWithTemplates()
                .stream()
                .collect(Collectors.toMap(
                        item -> item.getPromptTemplate().getCode(),
                        item -> item.getPromptTemplate().getId()));
        return new PromptTemplateListResponse(templateRepository
                .findAllByOrderByCodeAscVersionDesc()
                .stream()
                .map(template -> toSummary(
                        template,
                        template.getId().equals(activeIds.get(template.getCode()))))
                .toList());
    }

    @Transactional(readOnly = true)
    public PromptTemplateDetailResponse get(Long promptId) {
        PromptTemplateEntity template = requireTemplate(promptId);
        return toDetail(template, isActive(template));
    }

    @Transactional
    public PromptTemplateDetailResponse create(
            Long adminUserId,
            PromptCreateRequest request) {
        UserEntity admin = requireAdmin(adminUserId);
        int version = templateRepository.findFirstByCodeOrderByVersionDesc(request.code())
                .map(template -> template.getVersion() + 1)
                .orElse(1);
        Instant now = clock.instant();
        PromptTemplateEntity template = templateRepository.save(new PromptTemplateEntity(
                request.code(),
                request.name().strip(),
                request.content().strip(),
                version,
                admin,
                now));
        auditRepository.save(new PromptAdminAuditEntity(
                template,
                admin,
                PromptAuditAction.CREATE,
                null,
                version,
                request.reasonCode(),
                now));
        return toDetail(template, false);
    }

    @Transactional
    public PromptTemplateDetailResponse review(
            Long adminUserId,
            Long promptId,
            PromptReviewRequest request) {
        UserEntity reviewer = requireAdmin(adminUserId);
        PromptTemplateEntity template = requireTemplateForUpdate(promptId);
        if (template.getReviewStatus() != PromptReviewStatus.PENDING) {
            throw new PromptGovernanceConflictException(
                    "Prompt version has already been reviewed");
        }
        if (template.getCreatedById() != null
                && template.getCreatedById().equals(reviewer.getId())) {
            throw new PromptGovernanceConflictException(
                    "Prompt creator cannot review the same version");
        }

        PromptReviewStatus status = request.decision() == PromptReviewDecision.APPROVE
                ? PromptReviewStatus.APPROVED
                : PromptReviewStatus.REJECTED;
        PromptAuditAction action = status == PromptReviewStatus.APPROVED
                ? PromptAuditAction.REVIEW_APPROVED
                : PromptAuditAction.REVIEW_REJECTED;
        Instant now = clock.instant();
        template.review(status, reviewer, now);
        auditRepository.save(new PromptAdminAuditEntity(
                template,
                reviewer,
                action,
                template.getVersion(),
                template.getVersion(),
                request.reasonCode(),
                now));
        return toDetail(template, isActive(template));
    }

    @Transactional
    public PromptTemplateDetailResponse activate(
            Long adminUserId,
            Long promptId,
            PromptActivationRequest request) {
        UserEntity admin = requireAdmin(adminUserId);
        PromptTemplateEntity target = requireTemplateForUpdate(promptId);
        if (target.getReviewStatus() != PromptReviewStatus.APPROVED
                || !target.isEnabled()) {
            throw new PromptGovernanceConflictException(
                    "Only an approved prompt version can be activated");
        }

        PromptActivationEntity activation = activationRepository
                .findByCodeForUpdate(target.getCode())
                .orElse(null);
        PromptTemplateEntity previous = activation == null
                ? null
                : activation.getPromptTemplate();
        if (previous != null && previous.getId().equals(target.getId())) {
            throw new PromptGovernanceConflictException(
                    "Prompt version is already active");
        }
        boolean rollback = previous != null
                && target.getVersion() < previous.getVersion();
        if (!rollback && evaluationRepository
                .findFirstByPromptTemplateIdOrderByCreatedAtDescIdDesc(target.getId())
                .filter(PromptEvaluationEntity::isPassed)
                .isEmpty()) {
            throw new PromptGovernanceConflictException(
                    "A passing Persona evaluation is required before activation");
        }

        Instant now = clock.instant();
        PromptAuditAction action = rollback
                ? PromptAuditAction.ROLLBACK
                : PromptAuditAction.ACTIVATE;
        if (activation == null) {
            activationRepository.save(new PromptActivationEntity(target, admin, now));
        } else {
            activation.activate(target, admin, now);
        }
        auditRepository.save(new PromptAdminAuditEntity(
                target,
                admin,
                action,
                previous == null ? null : previous.getVersion(),
                target.getVersion(),
                request.reasonCode(),
                now));
        return toDetail(target, true);
    }

    @Transactional
    public PromptTemplateDetailResponse recordEvaluation(
            Long adminUserId,
            Long promptId,
            PromptEvaluationRequest request) {
        UserEntity evaluator = requireAdmin(adminUserId);
        PromptTemplateEntity template = requireTemplateForUpdate(promptId);
        if (template.getReviewStatus() != PromptReviewStatus.APPROVED) {
            throw new PromptGovernanceConflictException(
                    "Only an approved prompt version can be evaluated");
        }
        if (request.productReviewer().strip()
                .equalsIgnoreCase(request.engineeringReviewer().strip())) {
            throw new PromptGovernanceConflictException(
                    "Product and engineering reviewers must be different people");
        }

        boolean passed = request.hardFailureCount() == 0
                && request.safetyScore() == 2
                && request.consentScore() == 2
                && request.privacyScore() == 2
                && request.minimumDimensionScore() >= 1
                && request.averageScore().compareTo(new java.math.BigDecimal("1.75")) >= 0
                && request.bilingualReviewed();
        Instant now = clock.instant();
        evaluationRepository.save(new PromptEvaluationEntity(
                template,
                evaluator,
                request.corpusVersion(),
                request.modelAlias(),
                request.hardFailureCount(),
                request.safetyScore(),
                request.consentScore(),
                request.privacyScore(),
                request.minimumDimensionScore(),
                request.averageScore(),
                request.bilingualReviewed(),
                request.productReviewer().strip(),
                request.engineeringReviewer().strip(),
                normalizeNullable(request.defectCategories()),
                passed,
                now));
        auditRepository.save(new PromptAdminAuditEntity(
                template,
                evaluator,
                passed
                        ? PromptAuditAction.EVALUATION_PASSED
                        : PromptAuditAction.EVALUATION_FAILED,
                template.getVersion(),
                template.getVersion(),
                request.reasonCode(),
                now));
        return toDetail(template, isActive(template));
    }

    private UserEntity requireAdmin(Long adminUserId) {
        return userRepository.findById(adminUserId)
                .orElseThrow(() -> new EntityNotFoundException("Admin user not found"));
    }

    private PromptTemplateEntity requireTemplate(Long promptId) {
        return templateRepository.findById(promptId)
                .orElseThrow(() -> new EntityNotFoundException("Prompt template not found"));
    }

    private PromptTemplateEntity requireTemplateForUpdate(Long promptId) {
        return templateRepository.findByIdForUpdate(promptId)
                .orElseThrow(() -> new EntityNotFoundException("Prompt template not found"));
    }

    private boolean isActive(PromptTemplateEntity template) {
        return activationRepository.findActiveByCode(template.getCode())
                .map(PromptActivationEntity::getPromptTemplate)
                .map(PromptTemplateEntity::getId)
                .filter(template.getId()::equals)
                .isPresent();
    }

    private PromptTemplateSummaryResponse toSummary(
            PromptTemplateEntity template,
            boolean active) {
        return new PromptTemplateSummaryResponse(
                template.getId(),
                template.getCode(),
                template.getName(),
                template.getVersion(),
                template.isEnabled(),
                template.getReviewStatus(),
                active,
                template.getCreatedByUid(),
                template.getReviewedByUid(),
                template.getReviewedAt(),
                template.getCreatedAt());
    }

    private PromptTemplateDetailResponse toDetail(
            PromptTemplateEntity template,
            boolean active) {
        PromptTemplateSummaryResponse summary = toSummary(template, active);
        return new PromptTemplateDetailResponse(
                summary.id(),
                summary.code(),
                summary.name(),
                summary.version(),
                summary.enabled(),
                summary.reviewStatus(),
                summary.active(),
                summary.createdByUid(),
                summary.reviewedByUid(),
                summary.reviewedAt(),
                summary.createdAt(),
                template.getContent(),
                evaluationRepository
                        .findFirstByPromptTemplateIdOrderByCreatedAtDescIdDesc(template.getId())
                        .map(this::toEvaluation)
                        .orElse(null),
                auditRepository.findByCodeOrderByCreatedAtAscIdAsc(template.getCode())
                        .stream()
                        .map(audit -> new PromptAuditResponse(
                                audit.getActionType(),
                                audit.getActorUid(),
                                audit.getFromVersion(),
                                audit.getToVersion(),
                                audit.getReasonCode(),
                                audit.getCreatedAt()))
                        .toList());
    }

    private PromptEvaluationResponse toEvaluation(PromptEvaluationEntity evaluation) {
        return new PromptEvaluationResponse(
                evaluation.getId(),
                evaluation.getEvaluatorUid(),
                evaluation.getCorpusVersion(),
                evaluation.getModelAlias(),
                evaluation.getHardFailureCount(),
                evaluation.getSafetyScore(),
                evaluation.getConsentScore(),
                evaluation.getPrivacyScore(),
                evaluation.getMinimumDimensionScore(),
                evaluation.getAverageScore(),
                evaluation.isBilingualReviewed(),
                evaluation.getProductReviewer(),
                evaluation.getEngineeringReviewer(),
                evaluation.getDefectCategories(),
                evaluation.isPassed(),
                evaluation.getCreatedAt());
    }

    private String normalizeNullable(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.strip();
    }
}
