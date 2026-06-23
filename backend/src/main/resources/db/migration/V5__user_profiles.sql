CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    nickname VARCHAR(30),
    avatar_preset VARCHAR(30),
    age_range VARCHAR(20),
    occupation VARCHAR(40),
    self_description VARCHAR(120),
    ai_profile_context_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (avatar_preset IS NULL OR avatar_preset IN ('ZEROON_DEFAULT', 'MOON', 'MOUNTAIN', 'SEA', 'LIGHT', 'SEED')),
    CHECK (age_range IS NULL OR age_range IN ('UNDER_18', 'AGE_18_24', 'AGE_25_34', 'AGE_35_44', 'AGE_45_54', 'AGE_55_PLUS', 'PREFER_NOT_TO_SAY'))
);

CREATE INDEX idx_user_profiles_user ON user_profiles(user_id);
