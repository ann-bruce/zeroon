CREATE TABLE user_zeroon_companions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    companion_key VARCHAR(30) NOT NULL,
    display_name VARCHAR(30),
    met_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (companion_key IN ('ZEROON_DEFAULT'))
);

CREATE INDEX idx_user_zeroon_companions_user ON user_zeroon_companions(user_id);
