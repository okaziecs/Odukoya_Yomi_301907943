# Real-time Game Leaderboard — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| player_id | score_entry records (list) |
| --- | --- |
| 1 | [1001] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| score_entry.score_entry_id | score_entry.player_id | score_entry.game_id | player.player_id | player.handle | game.game_id | game.title |
| --- | --- | --- | --- | --- | --- | --- |
| 1001 | 1 | 101 | 1 | mira | 101 | Orbit Rally |

Key: score_entry_id.

## 2NF: depend on the whole key

The declared candidate keys do not introduce a partial dependency here, so the 1NF rows stay unchanged at this step.

## score_entry_example

| score_entry.score_entry_id | score_entry.player_id | score_entry.game_id | player.player_id | player.handle | game.game_id | game.title |
| --- | --- | --- | --- | --- | --- | --- |
| 1001 | 1 | 101 | 1 | mira | 101 | Orbit Rally |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## player

| player_id | handle | joined_at |
| --- | --- | --- |
| 1 | mira | 2024-01-15T09:30:00+00:00 |
| 2 | kai | 2024-02-20T16:45:00+00:00 |

## game

| game_id | title | release_date | is_active |
| --- | --- | --- | --- |
| 101 | Orbit Rally | 2023-09-12 | true |

## score_entry

| score_entry_id | player_id | game_id | score | achieved_at | is_current |
| --- | --- | --- | --- | --- | --- |
| 1001 | 1 | 101 | 840 | 2024-03-10T12:00:00+00:00 | true |

## Dependencies

- player: (player_id) → handle, joined_at
- game: (game_id) → title, release_date, is_active
- score_entry: (score_entry_id) → player_id, game_id, score, achieved_at, is_current

Joining the decomposed sample tables reproduces the original 1 example rows. The design assumes the declared keys describe the relevant business dependencies.
