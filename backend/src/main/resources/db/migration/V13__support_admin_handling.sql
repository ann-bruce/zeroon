ALTER TABLE support_requests
    ADD COLUMN assigned_admin_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    ADD COLUMN escalated BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN escalation_code VARCHAR(40);

ALTER TABLE support_requests
    ADD CONSTRAINT chk_support_request_escalation CHECK (
        (escalated = FALSE AND escalation_code IS NULL)
        OR
        (escalated = TRUE AND escalation_code IN (
            'ENGINEERING', 'PRODUCT', 'PRIVACY', 'SAFETY',
            'COMPLAINT', 'PROFESSIONAL_REVIEW'
        ))
    );

CREATE INDEX idx_support_requests_admin_queue
    ON support_requests (status, escalated, updated_at DESC);

CREATE TABLE support_admin_audit (
    id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL REFERENCES support_requests(id) ON DELETE CASCADE,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(30) NOT NULL,
    from_value VARCHAR(100),
    to_value VARCHAR(100),
    message_id BIGINT REFERENCES support_messages(id) ON DELETE SET NULL,
    reason_code VARCHAR(40) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_support_admin_audit_action CHECK (action_type IN (
        'CATEGORY_CHANGE', 'ASSIGNMENT_CHANGE', 'ESCALATION_CHANGE',
        'STATUS_CHANGE', 'USER_VISIBLE_REPLY', 'INTERNAL_NOTE'
    ))
);

CREATE INDEX idx_support_admin_audit_request_created
    ON support_admin_audit (request_id, created_at);
