# Portfolio 1: Database Design and Modelling

## 1. Case Study Overview
This relational database supports a **Real-time Game Leaderboard** system for **Global Arcade Hub**. It manages player accounts (`player`), game metadata (`game`), and historical/active leaderboard score entries (`score_entry`).

## 2. Entity-Relationship (ER) Diagram
![ER Diagram](./Odukoya_Yomi_301907943_ERDiagram.png)

## 3. Relational Schema & Tables
The database structure is defined in [`schema.sql`](./schema.sql) under the `portfolio` schema namespace:
* **`portfolio.player`**: Stores player user profiles (`player_id`, `handle`, `joined_at`).
* **`portfolio.game`**: Catalog of active and inactive games (`game_id`, `title`, `release_date`, `is_active`).
* **`portfolio.score_entry`**: Individual score entries per player per game (`score_entry_id`, `player_id`, `game_id`, `score`, `achieved_at`, `is_current`).

## 4. Keys and Business Constraints
* **Primary Keys**: `pk_player` on `player_id`, `pk_game` on `game_id`, `pk_score_entry` on `score_entry_id`.
* **Foreign Keys**: `fk_score_entry_0` referencing `player(player_id)` and `fk_score_entry_1` referencing `game(game_id)`.
* **Domain & Business Constraints**: 
  * `CHECK ("score" >= 0)` guarantees non-negative score values.
  * `UNIQUE ("handle")` ensures distinct user handles.
  * `one_current_score_per_game` (Partial Unique Index) enforces at most one active (`is_current IS NOT NULL`) leaderboard score per player per game.
* **Constraint Testing**: Comprehensive constraint validation tests and error state verifications are documented in [`ConstraintTests.sql`](./ConstraintTests.sql).

## 5. Normalisation Breakdown (1NF to 3NF)
A full step-by-step mathematical and table-level decomposition proving Third Normal Form (3NF) compliance is available in [`Normalisation.md`](./Normalisation.md).
* **1NF**: All columns hold atomic, non-repeating values.
* **2NF**: No partial dependencies; all non-key attributes depend on the complete primary keys.
* **3NF**: No transitive dependencies; non-key attributes depend solely on candidate keys.
