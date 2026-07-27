package ai.zeroon.prompt;

import ai.zeroon.user.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "prompt_evaluations")
public class PromptEvaluationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "prompt_template_id", nullable = false)
    private PromptTemplateEntity promptTemplate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "evaluated_by")
    private UserEntity evaluatedBy;

    @Column(name = "corpus_version", nullable = false, length = 40)
    private String corpusVersion;

    @Column(name = "model_alias", nullable = false, length = 40)
    private String modelAlias;

    @Column(name = "hard_failure_count", nullable = false)
    private int hardFailureCount;

    @Column(name = "safety_score", nullable = false)
    private int safetyScore;

    @Column(name = "consent_score", nullable = false)
    private int consentScore;

    @Column(name = "privacy_score", nullable = false)
    private int privacyScore;

    @Column(name = "minimum_dimension_score", nullable = false)
    private int minimumDimensionScore;

    @Column(name = "average_score", nullable = false, precision = 3, scale = 2)
    private BigDecimal averageScore;

    @Column(name = "bilingual_reviewed", nullable = false)
    private boolean bilingualReviewed;

    @Column(name = "product_reviewer", nullable = false, length = 100)
    private String productReviewer;

    @Column(name = "engineering_reviewer", nullable = false, length = 100)
    private String engineeringReviewer;

    @Column(name = "defect_categories", length = 500)
    private String defectCategories;

    @Column(nullable = false)
    private boolean passed;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected PromptEvaluationEntity() {
    }

    public PromptEvaluationEntity(
            PromptTemplateEntity promptTemplate,
            UserEntity evaluatedBy,
            String corpusVersion,
            String modelAlias,
            int hardFailureCount,
            int safetyScore,
            int consentScore,
            int privacyScore,
            int minimumDimensionScore,
            BigDecimal averageScore,
            boolean bilingualReviewed,
            String productReviewer,
            String engineeringReviewer,
            String defectCategories,
            boolean passed,
            Instant createdAt) {
        this.promptTemplate = promptTemplate;
        this.evaluatedBy = evaluatedBy;
        this.corpusVersion = corpusVersion;
        this.modelAlias = modelAlias;
        this.hardFailureCount = hardFailureCount;
        this.safetyScore = safetyScore;
        this.consentScore = consentScore;
        this.privacyScore = privacyScore;
        this.minimumDimensionScore = minimumDimensionScore;
        this.averageScore = averageScore;
        this.bilingualReviewed = bilingualReviewed;
        this.productReviewer = productReviewer;
        this.engineeringReviewer = engineeringReviewer;
        this.defectCategories = defectCategories;
        this.passed = passed;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public String getEvaluatorUid() {
        return evaluatedBy == null ? null : evaluatedBy.getUid();
    }

    public String getCorpusVersion() {
        return corpusVersion;
    }

    public String getModelAlias() {
        return modelAlias;
    }

    public int getHardFailureCount() {
        return hardFailureCount;
    }

    public int getSafetyScore() {
        return safetyScore;
    }

    public int getConsentScore() {
        return consentScore;
    }

    public int getPrivacyScore() {
        return privacyScore;
    }

    public int getMinimumDimensionScore() {
        return minimumDimensionScore;
    }

    public BigDecimal getAverageScore() {
        return averageScore;
    }

    public boolean isBilingualReviewed() {
        return bilingualReviewed;
    }

    public String getProductReviewer() {
        return productReviewer;
    }

    public String getEngineeringReviewer() {
        return engineeringReviewer;
    }

    public String getDefectCategories() {
        return defectCategories;
    }

    public boolean isPassed() {
        return passed;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
