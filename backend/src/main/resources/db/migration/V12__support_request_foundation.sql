CREATE TABLE support_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    public_reference VARCHAR(32) NOT NULL UNIQUE,
    client_submission_id VARCHAR(36) NOT NULL,
    request_fingerprint VARCHAR(64) NOT NULL,
    category VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'RECEIVED',
    subject VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    reply_contact VARCHAR(200),
    diagnostic_app_version VARCHAR(40),
    diagnostic_build VARCHAR(40),
    diagnostic_platform VARCHAR(30),
    diagnostic_os_family VARCHAR(40),
    diagnostic_locale VARCHAR(10),
    diagnostic_error_code VARCHAR(80),
    diagnostic_timestamp TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_support_request_submission UNIQUE (user_id, client_submission_id),
    CONSTRAINT chk_support_request_category CHECK (category IN (
        'PRODUCT_PROBLEM', 'SUGGESTION', 'ACCOUNT_DATA_PRIVACY',
        'AI_RESPONSE_SAFETY', 'COMPLAINT_RIGHTS', 'OTHER'
    )),
    CONSTRAINT chk_support_request_status CHECK (status IN (
        'RECEIVED', 'IN_REVIEW', 'WAITING_FOR_USER', 'REPLIED', 'CLOSED'
    )),
    CONSTRAINT chk_support_request_locale CHECK (
        diagnostic_locale IS NULL OR diagnostic_locale IN ('zh-CN', 'en')
    )
);

CREATE INDEX idx_support_requests_user_created
    ON support_requests (user_id, created_at DESC);
CREATE INDEX idx_support_requests_status_updated
    ON support_requests (status, updated_at);

CREATE TABLE support_messages (
    id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL REFERENCES support_requests(id) ON DELETE CASCADE,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    actor_type VARCHAR(20) NOT NULL,
    visibility VARCHAR(20) NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_support_message_actor CHECK (actor_type IN ('SYSTEM', 'USER', 'ADMIN')),
    CONSTRAINT chk_support_message_visibility CHECK (visibility IN ('USER_VISIBLE', 'INTERNAL'))
);

CREATE INDEX idx_support_messages_request_created
    ON support_messages (request_id, created_at);

CREATE TABLE support_status_history (
    id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL REFERENCES support_requests(id) ON DELETE CASCADE,
    from_status VARCHAR(30),
    to_status VARCHAR(30) NOT NULL,
    actor_type VARCHAR(20) NOT NULL,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    reason_code VARCHAR(40) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_support_history_from_status CHECK (
        from_status IS NULL OR from_status IN (
            'RECEIVED', 'IN_REVIEW', 'WAITING_FOR_USER', 'REPLIED', 'CLOSED'
        )
    ),
    CONSTRAINT chk_support_history_to_status CHECK (to_status IN (
        'RECEIVED', 'IN_REVIEW', 'WAITING_FOR_USER', 'REPLIED', 'CLOSED'
    )),
    CONSTRAINT chk_support_history_actor CHECK (actor_type IN ('SYSTEM', 'USER', 'ADMIN'))
);

CREATE INDEX idx_support_status_history_request_created
    ON support_status_history (request_id, created_at);
