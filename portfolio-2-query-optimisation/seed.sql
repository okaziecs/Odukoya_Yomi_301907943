-- Seed script for Portfolio 2: Performance Benchmarking Lab
CREATE SCHEMA IF NOT EXISTS query_lab;

-- Copy table structure for performance testing
CREATE TABLE IF NOT EXISTS query_lab."score_entry" AS
SELECT "game_id", 0::bigint AS "lab_row_id" 
FROM portfolio."score_entry" 
WITH NO DATA;

-- Generate 20,000 test rows to simulate a large leaderboard database
INSERT INTO query_lab."score_entry" ("game_id", "lab_row_id")
SELECT (g % 1000)::bigint, g 
FROM generate_series(1, 20000) AS g;

-- Update query planner statistics
ANALYZE query_lab."score_entry";
