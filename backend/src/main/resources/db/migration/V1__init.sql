CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    uid VARCHAR(32) NOT NULL UNIQUE,
    mobile VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    nickname VARCHAR(50),
    avatar VARCHAR(500),
    current_state VARCHAR(20) NOT NULL DEFAULT 'CALM',
    continuous_days INTEGER NOT NULL DEFAULT 0 CHECK (continuous_days >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    deletion_requested_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('ACTIVE', 'SUSPENDED', 'DELETION_PENDING', 'DELETED')),
    CHECK (current_state IN ('CALM', 'FOCUS', 'CREATE', 'TIRED', 'OVERLOAD', 'CONFUSED')),
    CHECK (mobile IS NOT NULL OR email IS NOT NULL)
);

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('USER', 'ADMIN')),
    PRIMARY KEY (user_id, role)
);

CREATE TABLE refresh_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(128) NOT NULL UNIQUE,
    device_id VARCHAR(128) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE state_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    previous_state VARCHAR(20),
    current_state VARCHAR(20) NOT NULL,
    source VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (previous_state IS NULL OR previous_state IN ('CALM', 'FOCUS', 'CREATE', 'TIRED', 'OVERLOAD', 'CONFUSED')),
    CHECK (current_state IN ('CALM', 'FOCUS', 'CREATE', 'TIRED', 'OVERLOAD', 'CONFUSED')),
    CHECK (source IN ('MANUAL', 'RECORD', 'AI', 'SYSTEM'))
);

CREATE TABLE zero_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    state VARCHAR(20) NOT NULL,
    mood VARCHAR(200),
    goal TEXT,
    content TEXT,
    ai_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (state IN ('CALM', 'FOCUS', 'CREATE', 'TIRED', 'OVERLOAD', 'CONFUSED')),
    CHECK (mood IS NOT NULL OR goal IS NOT NULL OR content IS NOT NULL)
);

CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('USER', 'ASSISTANT', 'SYSTEM')),
    content TEXT NOT NULL,
    token_count INTEGER NOT NULL DEFAULT 0 CHECK (token_count >= 0),
    safety_label VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE memory_entries (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(30) NOT NULL CHECK (type IN ('ZERO_RECORD', 'STATE', 'CONVERSATION', 'GROWTH')),
    title VARCHAR(255),
    summary TEXT NOT NULL,
    importance SMALLINT NOT NULL DEFAULT 1 CHECK (importance BETWEEN 1 AND 10),
    source_type VARCHAR(30),
    source_id BIGINT,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE prompt_templates (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    version INTEGER NOT NULL CHECK (version > 0),
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (code, version)
);

CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    description TEXT,
    updated_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_events (
    id BIGSERIAL PRIMARY KEY,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id VARCHAR(100),
    trace_id VARCHAR(64),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_refresh_sessions_user ON refresh_sessions(user_id, expires_at);
CREATE INDEX idx_state_history_user_time ON state_history(user_id, created_at DESC);
CREATE INDEX idx_zero_records_user_time ON zero_records(user_id, created_at DESC);
CREATE INDEX idx_conversations_user_time ON conversations(user_id, created_at DESC);
CREATE INDEX idx_messages_conversation_time ON messages(conversation_id, created_at);
CREATE INDEX idx_memory_entries_user_time ON memory_entries(user_id, created_at DESC);
CREATE INDEX idx_audit_events_actor_time ON audit_events(actor_user_id, created_at DESC);

