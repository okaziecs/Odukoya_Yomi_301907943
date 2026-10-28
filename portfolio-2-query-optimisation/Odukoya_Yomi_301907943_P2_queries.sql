-- Portfolio 2: Query Processing and Optimisation Scripts

-------------------------------------------------------------------------------
-- QUERY 1: Aggregate Activity per Player (Unindexed Benchmark)
-------------------------------------------------------------------------------
SELECT "player_id", count(*) AS record_count
FROM portfolio."score_entry"
GROUP BY "player_id"
ORDER BY record_count DESC, "player_id" NULLS LAST
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "player_id", count(*) AS record_count
FROM portfolio."score_entry"
GROUP BY "player_id"
ORDER BY record_count DESC, "player_id" NULLS LAST
LIMIT 20;

-------------------------------------------------------------------------------
-- QUERY 2: Score Lookup by Game ID (Unindexed Benchmark)
-------------------------------------------------------------------------------
SELECT * FROM portfolio."score_entry"
WHERE "game_id" IS NOT DISTINCT FROM 101
ORDER BY "score_entry_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."score_entry"
WHERE "game_id" IS NOT DISTINCT FROM 101
ORDER BY "score_entry_id"
LIMIT 20;

-------------------------------------------------------------------------------
-- QUERY 3: Relational Join across Player, Game, and Score (Unindexed Benchmark)
-------------------------------------------------------------------------------
SELECT t0."score_entry_id" AS "score_entry_score_entry_id",
       t0."score" AS "score_entry_score",
       t1."player_id" AS "player_player_id",
       t1."handle" AS "player_handle",
       t2."game_id" AS "game_game_id",
       t2."title" AS "game_title"
FROM portfolio."score_entry" t0
JOIN portfolio."player" t1 ON t0."player_id" = t1."player_id"
JOIN portfolio."game" t2 ON t0."game_id" = t2."game_id"
ORDER BY t0."score_entry_id", t1."player_id", t2."game_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT t0."score_entry_id" AS "score_entry_score_entry_id",
       t0."score" AS "score_entry_score",
       t1."player_id" AS "player_player_id",
       t1."handle" AS "player_handle",
       t2."game_id" AS "game_game_id",
       t2."title" AS "game_title"
FROM portfolio."score_entry" t0
JOIN portfolio."player" t1 ON t0."player_id" = t1."player_id"
JOIN portfolio."game" t2 ON t0."game_id" = t2."game_id"
ORDER BY t0."score_entry_id", t1."player_id", t2."game_id"
LIMIT 20;

-------------------------------------------------------------------------------
-- OPTIMISATION: Create Indexes to Accelerate Query Filtering & Aggregation
-------------------------------------------------------------------------------
-- Index foreign key lookups and grouping on player_id
CREATE INDEX idx_score_entry_player_id ON portfolio."score_entry" ("player_id");

-- Index foreign key lookups and filtering on game_id
CREATE INDEX idx_score_entry_game_id ON portfolio."score_entry" ("game_id");

-------------------------------------------------------------------------------
-- QUERY 2 RE-TEST: Optimised Benchmark after Indexing
-------------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."score_entry"
WHERE "game_id" IS NOT DISTINCT FROM 101
ORDER BY "score_entry_id"
LIMIT 20;

-------------------------------------------------------------------------------
-- QUERY OPTIMISATION BENCHMARK (query_lab)
-------------------------------------------------------------------------------

-- 1. Unindexed Baseline Benchmark
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "game_id"
FROM query_lab."score_entry"
WHERE "game_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";

-- 2. Create B-Tree Index on Filtering Column
CREATE INDEX p2_filter_idx ON query_lab."score_entry" USING btree ("game_id");

-- 3. Optimised Post-Indexing Benchmark
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "game_id"
FROM query_lab."score_entry"
WHERE "game_id" = (42 % 1000)::bigint
ORDER BY "lab_row_id";
