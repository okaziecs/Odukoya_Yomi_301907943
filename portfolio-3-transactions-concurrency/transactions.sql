-- Portfolio 3: Transaction Management & Error Recovery Test

-------------------------------------------------------------------------------
-- 1. Setup Helper Column and Constraint for P3 Testing
-------------------------------------------------------------------------------
-- This helper counter exists only in the temporary transaction exercise.
-- Original case columns and constraints are preserved. It is not part of the P1 design.
ALTER TABLE portfolio."score_entry" 
  ADD COLUMN IF NOT EXISTS "p3_processed_count" integer NOT NULL DEFAULT 0;

ALTER TABLE portfolio."score_entry" 
  DROP CONSTRAINT IF EXISTS "p3_count_nonnegative",
  ADD CONSTRAINT "p3_count_nonnegative" CHECK ("p3_processed_count" >= 0);

-------------------------------------------------------------------------------
-- 2. Successful Atomic Transaction (COMMIT)
-------------------------------------------------------------------------------
BEGIN ISOLATION LEVEL READ COMMITTED;

UPDATE portfolio."score_entry" 
SET "p3_processed_count" = "p3_processed_count" + 1 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");

COMMIT;

-- Verify state post-commit
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;

-------------------------------------------------------------------------------
-- 3. Aborted Transaction & Error State Recovery (ROLLBACK)
-------------------------------------------------------------------------------
BEGIN ISOLATION LEVEL READ COMMITTED;

UPDATE portfolio."score_entry" 
SET "p3_processed_count" = "p3_processed_count" + 10 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");

-- A negative counter deliberately fails its CHECK constraint.
\set ON_ERROR_STOP off
\set VERBOSITY verbose

UPDATE portfolio."score_entry" 
SET "p3_processed_count" = -1 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");

-- A failed transaction rejects subsequent statements until ROLLBACK is issued
SELECT 1;

ROLLBACK;
\set ON_ERROR_STOP on

-- Verify state post-rollback (Value remains 1, proving intermediate +10 was rolled back)
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;
