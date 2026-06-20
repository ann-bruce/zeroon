ALTER TABLE zero_records
    DROP CONSTRAINT IF EXISTS zero_records_check;

ALTER TABLE zero_records
    DROP COLUMN IF EXISTS mood;

ALTER TABLE zero_records
    ADD CONSTRAINT zero_records_goal_or_content_check
        CHECK (goal IS NOT NULL OR content IS NOT NULL);
