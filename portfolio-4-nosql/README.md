# Portfolio 4: NoSQL and Advanced Data Models

## 1. Executive Summary
This module adapts the **Global Arcade Hub** system into a non-relational, event-sourced document database using **MongoDB**. While the transactional core (Portfolios 1–3) relies on PostgreSQL for strict relational integrity, high-throughput telemetry—such as live leaderboard updates, audit logs, and game events—benefits from a flexible NoSQL document structure.

---

## 2. Document Model Architecture

We designed an event-sourced document model (`leaderboard_events`) that captures real-time leaderboard activity. Each event document embeds snapshot metadata for the player and game involved, eliminating expensive multi-table joins during high-frequency queries.

### Document Structure Example (`score_submitted`)
```json
{
  "_id": "event_000001",
  "schemaVersion": 1,
  "simulation": true,
  "eventType": "score_submitted",
  "occurredAt": "2030-01-01T10:00:00Z",
  "source": {
    "entity": "score_entry",
    "key": { "score_entry_id": 1001 },
    "snapshot": {
      "score_entry_id": 1001,
      "player_id": 1,
      "game_id": 101,
      "score": 840,
      "achieved_at": "2024-03-10T12:00:00Z",
      "is_current": true
    }
  },
  "embedded": {
    "player": [{ "snapshot": { "player_id": 1, "handle": "mira" } }],
    "game": [{ "snapshot": { "game_id": 101, "title": "Orbit Rally" } }]
  },
  "details": { "channel": "web" }
}
