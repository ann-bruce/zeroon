ALTER TABLE memory_entries
    ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN ai_context_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE memory_entries
    ADD CONSTRAINT chk_memory_entries_source_pair
        CHECK ((source_type IS NULL) = (source_id IS NULL));

CREATE UNIQUE INDEX uq_memory_entries_user_source
    ON memory_entries(user_id, source_type, source_id, type)
    WHERE source_type IS NOT NULL AND source_id IS NOT NULL;
