-- Portfolio 3: Concurrency Control & Lost Update Resolution Test
-- Instructions: Run statements in numerical order across two concurrent psql connections.

-------------------------------------------------------------------------------
-- SETUP BASELINE STATE
-------------------------------------------------------------------------------
-- Ensure row 1001 exists with initial count = 1
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 1 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;

-------------------------------------------------------------------------------
-- TEST 1: THE ANOMALY (Lost Update without Row Locking)
-------------------------------------------------------------------------------

-- [Step 1 - Session A]: Read baseline count (returns 1)
-- SESSION A:
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;

-- [Step 2 - Session B]: Read baseline count before A writes (also reads stale 1)
-- SESSION B:
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;

-- [Step 3 - Session A]: Write update (Count = 1 + 1 = 2) and commit
-- SESSION A:
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 2 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");
COMMIT;

-- [Step 4 - Session B]: Write using its stale read (Overwrites A's work with 2, losing 1 increment)
-- SESSION B:
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 2 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");
COMMIT;

-- Verify Lost Update Anomaly (Result is 2 instead of expected 3)
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;


-------------------------------------------------------------------------------
-- TEST 2: THE RESOLUTION (Pessimistic Row Locking via FOR UPDATE)
-------------------------------------------------------------------------------

-- [Step 5]: Reset baseline count to 1 (Execute outside both transactions)
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 1 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");

-- [Step 6 - Session A]: Lock the target row exclusively before reading
-- SESSION A:
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
FOR UPDATE;

-- [Step 7 - Session B]: Request the same row lock (SESSION B BLOCKS / WAITS HERE)
-- SESSION B:
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
FOR UPDATE;

-- [Step 8 - Session A]: Update row count to 2 and release lock via COMMIT
-- SESSION A:
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 2 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");
COMMIT;

-- [Step 9 - Session B]: Session B unblocks! Receives updated count (2), increments to 3, and commits
-- SESSION B:
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = 3 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");
COMMIT;

-- Final Verification (Result is correctly 3, proving zero lost updates)
SELECT "score_entry_id", "p3_processed_count" 
FROM portfolio."score_entry" 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001;
