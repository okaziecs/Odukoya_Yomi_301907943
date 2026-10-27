-- Real-time Game Leaderboard: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."player" (
  "player_id" bigint NOT NULL,
  "handle" text NOT NULL,
  "joined_at" timestamptz NOT NULL,
  CONSTRAINT "pk_player" PRIMARY KEY ("player_id"),
  CONSTRAINT "uq_player_0" UNIQUE ("handle")
);
CREATE TABLE portfolio."game" (
  "game_id" bigint NOT NULL,
  "title" text NOT NULL,
  "release_date" date NOT NULL,
  "is_active" boolean NOT NULL,
  CONSTRAINT "pk_game" PRIMARY KEY ("game_id")
);
CREATE TABLE portfolio."score_entry" (
  "score_entry_id" bigint NOT NULL,
  "player_id" bigint NOT NULL,
  "game_id" bigint NOT NULL,
  "score" bigint NOT NULL,
  "achieved_at" timestamptz NOT NULL,
  "is_current" boolean NOT NULL,
  CONSTRAINT "pk_score_entry" PRIMARY KEY ("score_entry_id")
);
ALTER TABLE portfolio."score_entry" ADD CONSTRAINT "fk_score_entry_0" FOREIGN KEY ("player_id") REFERENCES portfolio."player" ("player_id");
ALTER TABLE portfolio."score_entry" ADD CONSTRAINT "fk_score_entry_1" FOREIGN KEY ("game_id") REFERENCES portfolio."game" ("game_id");
ALTER TABLE portfolio."score_entry" ADD CONSTRAINT "nonnegative_score" CHECK ("score" >= 0);
CREATE UNIQUE INDEX "one_current_score_per_game" ON portfolio."score_entry" ("player_id", "game_id") WHERE ("is_current" IS NOT NULL);
COMMIT;
