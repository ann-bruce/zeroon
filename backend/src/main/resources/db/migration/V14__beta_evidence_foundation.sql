CREATE TABLE evidence_subjects (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    subject_uuid UUID NOT NULL UNIQUE,
    collection_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    accepted_notice_version VARCHAR(40) NOT NULL,
    choice_changed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_evidence_subjects_choice_changed
    ON evidence_subjects (choice_changed_at);

CREATE TABLE evidence_events (
    id BIGSERIAL PRIMARY KEY,
    subject_id BIGINT NOT NULL REFERENCES evidence_subjects(id) ON DELETE CASCADE,
    client_event_id UUID NOT NULL,
    event_name VARCHAR(40) NOT NULL,
    schema_version INTEGER NOT NULL,
    occurred_date DATE NOT NULL,
    event_fingerprint VARCHAR(64) NOT NULL,
    account_type VARCHAR(20),
    platform VARCHAR(20),
    app_version VARCHAR(40),
    entry_source VARCHAR(30),
    duration_bucket VARCHAR(30),
    retry_count_bucket VARCHAR(20),
    state VARCHAR(20),
    source VARCHAR(20),
    active_state_present BOOLEAN,
    has_goal BOOLEAN,
    has_content BOOLEAN,
    latency_bucket VARCHAR(30),
    error_class VARCHAR(30),
    retryable BOOLEAN,
    network_status VARCHAR(20),
    item_count_bucket VARCHAR(30),
    record_age_bucket VARCHAR(30),
    source_type VARCHAR(30),
    surface VARCHAR(30),
    context_class_mask INTEGER,
    outcome VARCHAR(20),
    prompt_version VARCHAR(40),
    model_alias VARCHAR(40),
    action VARCHAR(30),
    enabled BOOLEAN,
    reason_category VARCHAR(30),
    received_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_evidence_event_client UNIQUE (subject_id, client_event_id),
    CONSTRAINT chk_evidence_event_name CHECK (event_name IN (
        'AUTH_COMPLETED', 'ZEROON_ENCOUNTER_VIEWED',
        'ZEROON_ENCOUNTER_COMPLETED', 'STATE_STARTED', 'RESET_STARTED',
        'RECORD_SAVED', 'RECORD_SAVE_FAILED', 'ARCHIVE_VIEWED',
        'RECORD_DETAIL_VIEWED', 'REFLECTION_REQUESTED',
        'REFLECTION_COMPLETED', 'MEMORY_CONTROL_CHANGED',
        'PROFILE_AI_CONTEXT_CHANGED', 'DATA_EXPORT_REQUESTED',
        'ACCOUNT_DELETE_REQUESTED'
    )),
    CONSTRAINT chk_evidence_schema_version CHECK (schema_version = 1),
    CONSTRAINT chk_evidence_fingerprint CHECK (
        event_fingerprint ~ '^[0-9a-f]{64}$'
    ),
    CONSTRAINT chk_evidence_context_mask CHECK (
        context_class_mask IS NULL OR context_class_mask BETWEEN 0 AND 3
    )
);

CREATE INDEX idx_evidence_events_subject_date
    ON evidence_events (subject_id, occurred_date, received_at);
CREATE INDEX idx_evidence_events_received
    ON evidence_events (received_at);
CREATE INDEX idx_evidence_events_name_date
    ON evidence_events (event_name, occurred_date);
