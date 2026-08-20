ALTER TABLE zero_records
    ADD COLUMN idempotency_key VARCHAR(64),
    ADD COLUMN idempotency_fingerprint VARCHAR(64);

ALTER TABLE zero_records
    ADD CONSTRAINT chk_zero_records_idempotency_pair
        CHECK ((idempotency_key IS NULL) = (idempotency_fingerprint IS NULL));

CREATE UNIQUE INDEX uq_zero_records_user_idempotency
    ON zero_records(user_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;
