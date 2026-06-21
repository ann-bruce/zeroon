CREATE TABLE state_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    state VARCHAR(20) NOT NULL,
    source VARCHAR(20) NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    ended_by_record_id BIGINT REFERENCES zero_records(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (state IN ('CALM', 'FOCUS', 'CREATE', 'TIRED', 'OVERLOAD', 'CONFUSED')),
    CHECK (source IN ('MANUAL', 'RECORD', 'AI', 'SYSTEM')),
    CHECK (ended_at IS NULL OR ended_at > started_at)
);

ALTER TABLE zero_records
    ADD COLUMN state_session_id BIGINT REFERENCES state_sessions(id) ON DELETE SET NULL;

CREATE UNIQUE INDEX idx_state_sessions_active_user
    ON state_sessions(user_id)
    WHERE ended_at IS NULL;

CREATE INDEX idx_state_sessions_user_started
    ON state_sessions(user_id, started_at DESC);
