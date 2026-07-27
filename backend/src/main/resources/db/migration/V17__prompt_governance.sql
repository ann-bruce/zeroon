ALTER TABLE prompt_templates
    ADD COLUMN review_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN reviewed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    ADD COLUMN reviewed_at TIMESTAMPTZ;

UPDATE prompt_templates
SET review_status = CASE
    WHEN enabled THEN 'APPROVED'
    ELSE 'PENDING'
END;

CREATE TABLE prompt_activations (
    code VARCHAR(100) PRIMARY KEY,
    prompt_template_id BIGINT NOT NULL UNIQUE
        REFERENCES prompt_templates(id) ON DELETE RESTRICT,
    activated_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    activated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO prompt_activations (
    code,
    prompt_template_id,
    activated_by,
    activated_at
)
SELECT template.code, template.id, NULL, CURRENT_TIMESTAMP
FROM prompt_templates template
WHERE template.enabled = TRUE
  AND template.version = (
      SELECT MAX(candidate.version)
      FROM prompt_templates candidate
      WHERE candidate.code = template.code
        AND candidate.enabled = TRUE
  );

CREATE TABLE prompt_admin_audit (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL,
    prompt_template_id BIGINT NOT NULL
        REFERENCES prompt_templates(id) ON DELETE RESTRICT,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(30) NOT NULL,
    from_version INTEGER,
    to_version INTEGER,
    reason_code VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prompt_admin_audit_code_created
    ON prompt_admin_audit (code, created_at, id);
