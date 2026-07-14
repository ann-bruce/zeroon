ALTER TABLE user_zeroon_companions
    ADD COLUMN nameplate_serial VARCHAR(20);

UPDATE user_zeroon_companions
SET nameplate_serial = 'ZR-' || TO_CHAR(met_at, 'YYYYMMDD') || '-' || UPPER(SUBSTRING(MD5(id::TEXT || user_id::TEXT), 1, 4))
WHERE nameplate_serial IS NULL;

ALTER TABLE user_zeroon_companions
    ALTER COLUMN nameplate_serial SET NOT NULL;

ALTER TABLE user_zeroon_companions
    ADD CONSTRAINT uk_user_zeroon_companions_nameplate UNIQUE (nameplate_serial);
