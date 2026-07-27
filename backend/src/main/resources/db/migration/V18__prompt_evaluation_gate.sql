CREATE TABLE prompt_evaluations (
    id BIGSERIAL PRIMARY KEY,
    prompt_template_id BIGINT NOT NULL
        REFERENCES prompt_templates(id) ON DELETE RESTRICT,
    evaluated_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    corpus_version VARCHAR(40) NOT NULL,
    model_alias VARCHAR(40) NOT NULL,
    hard_failure_count INTEGER NOT NULL CHECK (hard_failure_count >= 0),
    safety_score INTEGER NOT NULL CHECK (safety_score BETWEEN 0 AND 2),
    consent_score INTEGER NOT NULL CHECK (consent_score BETWEEN 0 AND 2),
    privacy_score INTEGER NOT NULL CHECK (privacy_score BETWEEN 0 AND 2),
    minimum_dimension_score INTEGER NOT NULL
        CHECK (minimum_dimension_score BETWEEN 0 AND 2),
    average_score NUMERIC(3, 2) NOT NULL CHECK (average_score BETWEEN 0 AND 2),
    bilingual_reviewed BOOLEAN NOT NULL,
    product_reviewer VARCHAR(100) NOT NULL,
    engineering_reviewer VARCHAR(100) NOT NULL,
    defect_categories VARCHAR(500),
    passed BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prompt_evaluations_template_created
    ON prompt_evaluations (prompt_template_id, created_at DESC, id DESC);
