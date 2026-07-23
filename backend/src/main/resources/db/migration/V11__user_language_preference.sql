ALTER TABLE users
    ADD COLUMN language_preference VARCHAR(20) NOT NULL DEFAULT 'FOLLOW_SYSTEM';

ALTER TABLE users
    ADD CONSTRAINT chk_users_language_preference
    CHECK (language_preference IN ('FOLLOW_SYSTEM', 'ZH_CN', 'EN'));
