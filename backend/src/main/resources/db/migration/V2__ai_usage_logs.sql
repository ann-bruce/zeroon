CREATE TABLE ai_usage_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    conversation_id BIGINT REFERENCES conversations(id) ON DELETE SET NULL,
    provider VARCHAR(50) NOT NULL,
    model VARCHAR(100),
    operation VARCHAR(50) NOT NULL,
    outcome VARCHAR(30) NOT NULL,
    fallback_used BOOLEAN NOT NULL DEFAULT FALSE,
    duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
    prompt_template_code VARCHAR(100),
    prompt_template_version INTEGER,
    input_chars INTEGER NOT NULL DEFAULT 0 CHECK (input_chars >= 0),
    output_chars INTEGER NOT NULL DEFAULT 0 CHECK (output_chars >= 0),
    error_code VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (outcome IN ('SUCCESS', 'FALLBACK', 'REFUSAL', 'ERROR'))
);

CREATE INDEX idx_ai_usage_logs_user_time ON ai_usage_logs(user_id, created_at DESC);
CREATE INDEX idx_ai_usage_logs_conversation ON ai_usage_logs(conversation_id, created_at DESC);
