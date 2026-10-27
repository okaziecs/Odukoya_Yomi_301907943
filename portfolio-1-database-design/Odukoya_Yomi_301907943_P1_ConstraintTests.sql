-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. duplicate player pk. Expected: pk_player, SQLSTATE 23505.
INSERT INTO portfolio."player" ("player_id", "handle", "joined_at")
VALUES (1, 'sol', '2024-04-01T10:00:00Z');

-- 2. duplicate player handle. Expected: uq_player_0, SQLSTATE 23505.
INSERT INTO portfolio."player" ("player_id", "handle", "joined_at")
VALUES (910001, 'mira', '2024-04-02T10:00:00Z');

-- 3. null player id. Expected: player_id, SQLSTATE 23502.
INSERT INTO portfolio."player" ("player_id", "handle", "joined_at")
VALUES (NULL, 'nora', '2024-04-03T10:00:00Z');

-- 4. null player handle. Expected: handle, SQLSTATE 23502.
INSERT INTO portfolio."player" ("player_id", "handle", "joined_at")
VALUES (910002, NULL, '2024-04-04T10:00:00Z');

-- 5. null player joined at. Expected: joined_at, SQLSTATE 23502.
INSERT INTO portfolio."player" ("player_id", "handle", "joined_at")
VALUES (910003, 'tavi', NULL);

-- 6. duplicate game pk. Expected: pk_game, SQLSTATE 23505.
INSERT INTO portfolio."game" ("game_id", "title", "release_date", "is_active")
VALUES (101, 'Nova Sprint', '2024-04-05', TRUE);

-- 7. null game id. Expected: game_id, SQLSTATE 23502.
INSERT INTO portfolio."game" ("game_id", "title", "release_date", "is_active")
VALUES (NULL, 'Comet Run', '2024-04-06', TRUE);

-- 8. null game title. Expected: title, SQLSTATE 23502.
INSERT INTO portfolio."game" ("game_id", "title", "release_date", "is_active")
VALUES (910004, NULL, '2024-04-07', TRUE);

-- 9. null game release date. Expected: release_date, SQLSTATE 23502.
INSERT INTO portfolio."game" ("game_id", "title", "release_date", "is_active")
VALUES (910005, 'Lunar Dash', NULL, TRUE);

-- 10. null game is active. Expected: is_active, SQLSTATE 23502.
INSERT INTO portfolio."game" ("game_id", "title", "release_date", "is_active")
VALUES (910006, 'Solar Circuit', '2024-04-08', NULL);

-- 11. duplicate score entry pk. Expected: pk_score_entry, SQLSTATE 23505.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (1001, 2, 101, 500, '2024-04-09T10:00:00Z', FALSE);

-- 12. missing score player. Expected: fk_score_entry_0, SQLSTATE 23503.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910007, 910008, 101, 500, '2024-04-10T10:00:00Z', FALSE);

-- 13. missing score game. Expected: fk_score_entry_1, SQLSTATE 23503.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910009, 2, 910010, 500, '2024-04-11T10:00:00Z', FALSE);

-- 14. null score entry id. Expected: score_entry_id, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (NULL, 2, 101, 500, '2024-04-12T10:00:00Z', FALSE);

-- 15. null score player id. Expected: player_id, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910011, NULL, 101, 500, '2024-04-13T10:00:00Z', FALSE);

-- 16. null score game id. Expected: game_id, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910012, 2, NULL, 500, '2024-04-14T10:00:00Z', FALSE);

-- 17. null score value. Expected: score, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910013, 2, 101, NULL, '2024-04-15T10:00:00Z', FALSE);

-- 18. null score achieved at. Expected: achieved_at, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910014, 2, 101, 500, NULL, FALSE);

-- 19. null score is current. Expected: is_current, SQLSTATE 23502.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910015, 2, 101, 500, '2024-04-16T10:00:00Z', NULL);

-- 20. negative score. Expected: nonnegative_score, SQLSTATE 23514.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910016, 2, 101, -1, '2024-04-17T10:00:00Z', FALSE);

-- 21. duplicate current score. Expected: one_current_score_per_game, SQLSTATE 23505.
INSERT INTO portfolio."score_entry" ("score_entry_id", "player_id", "game_id", "score", "achieved_at", "is_current")
VALUES (910017, 1, 101, 850, '2024-04-18T10:00:00Z', TRUE);
