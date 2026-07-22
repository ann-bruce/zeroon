ALTER TABLE ai_usage_logs
    ADD COLUMN input_tokens INTEGER,
    ADD COLUMN output_tokens INTEGER,
    ADD CONSTRAINT chk_ai_usage_input_tokens_non_negative
        CHECK (input_tokens IS NULL OR input_tokens >= 0),
    ADD CONSTRAINT chk_ai_usage_output_tokens_non_negative
        CHECK (output_tokens IS NULL OR output_tokens >= 0);
