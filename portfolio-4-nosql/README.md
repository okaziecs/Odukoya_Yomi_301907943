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






# Execution Output Evidence

acknowledged: true,
  insertedIds: {
    '0': 'event_000001',
    '1': 'event_000002'
  }
}
[
  {
    _id: 'event_000001',
    schemaVersion: 1,
    simulation: true,
    eventType: 'score_submitted',
    occurredAt: ISODate('2030-01-01T10:00:00.000Z'),
    source: {
      entity: 'score_entry',
      key: {
        score_entry_id: 1001
      },
      snapshot: {
        score_entry_id: 1001,
        player_id: 1,
        game_id: 101,
        score: 840,
        achieved_at: '2024-03-10T12:00:00Z',
        is_current: true
      }
    },
    embedded: {
      player: [
        {
          key: {
            player_id: 1
          },
          snapshot: {
            player_id: 1,
            handle: 'mira',
            joined_at: '2024-01-15T09:30:00Z'
          },
          via: [
            'score_entry.player_id → player'
          ]
        }
      ],
      game: [
        {
          key: {
            game_id: 101
          },
          snapshot: {
            game_id: 101,
            title: 'Orbit Rally',
            release_date: '2023-09-12',
            is_active: true
          },
          via: [
            'score_entry.game_id → game'
          ]
        }
      ]
    },
    references: {},
    details: {
      channel: 'web'
    }
  }
]
[
  {
    _id: 'event_000001',
    schemaVersion: 1,
    simulation: true,
    eventType: 'score_submitted',
    occurredAt: ISODate('2030-01-01T10:00:00.000Z'),
    source: {
      entity: 'score_entry',
      key: {
        score_entry_id: 1001
      },
      snapshot: {
        score_entry_id: 1001,
        player_id: 1,
        game_id: 101,
        score: 840,
        achieved_at: '2024-03-10T12:00:00Z',
        is_current: true
      }
    },
    embedded: {
      player: [
        {
          key: {
            player_id: 1
          },
          snapshot: {
            player_id: 1,
            handle: 'mira',
            joined_at: '2024-01-15T09:30:00Z'
          },
          via: [
            'score_entry.player_id → player'
          ]
        }
      ],
      game: [
        {
          key: {
            game_id: 101
          },
          snapshot: {
            game_id: 101,
            title: 'Orbit Rally',
            release_date: '2023-09-12',
            is_active: true
          },
          via: [
            'score_entry.game_id → game'
          ]
        }
      ]
    },
    references: {},
    details: {
      channel: 'web'
    }
  },
  {
    _id: 'event_000002',
    schemaVersion: 1,
    simulation: true,
    eventType: 'score_accepted',
    occurredAt: ISODate('2030-01-01T10:01:00.000Z'),
    source: {
      entity: 'score_entry',
      key: {
        score_entry_id: 1001
      },
      snapshot: {
        score_entry_id: 1001,
        player_id: 1,
        game_id: 101,
        score: 840,
        achieved_at: '2024-03-10T12:00:00Z',
        is_current: true
      }
    },
    embedded: {
      player: [
        {
          key: {
            player_id: 1
          },
          snapshot: {
            player_id: 1,
            handle: 'mira',
            joined_at: '2024-01-15T09:30:00Z'
          },
          via: [
            'score_entry.player_id → player'
          ]
        }
      ],
      game: [
        {
          key: {
            game_id: 101
          },
          snapshot: {
            game_id: 101,
            title: 'Orbit Rally',
            release_date: '2023-09-12',
            is_active: true
          },
          via: [
            'score_entry.game_id → game'
          ]
        }
      ]
    },
    references: {},
    details: {
      channel: 'mobile',
      note: 'Illustrative event-specific metadata',
      examples: {
        event_payload: 'illustrative event_payload',
        client_metadata: 'illustrative client_metadata'
      }
    }
  }
]
[
  {
    _id: 'event_000001',
    schemaVersion: 1,
    simulation: true,
    eventType: 'score_submitted',
    occurredAt: ISODate('2030-01-01T10:00:00.000Z'),
    source: {
      entity: 'score_entry',
      key: {
        score_entry_id: 1001
      },
      snapshot: {
        score_entry_id: 1001,
        player_id: 1,
        game_id: 101,
        score: 840,
        achieved_at: '2024-03-10T12:00:00Z',
        is_current: true
      }
    },
    embedded: {
      player: [
        {
          key: {
            player_id: 1
          },
          snapshot: {
            player_id: 1,
            handle: 'mira',
            joined_at: '2024-01-15T09:30:00Z'
          },
          via: [
            'score_entry.player_id → player'
          ]
        }
      ],
      game: [
        {
          key: {
            game_id: 101
          },
          snapshot: {
            game_id: 101,
            title: 'Orbit Rally',
            release_date: '2023-09-12',
            is_active: true
          },
          via: [
            'score_entry.game_id → game'
          ]
        }
      ]
    },
    references: {},
    details: {
      channel: 'web'
    }
  },
  {
    _id: 'event_000002',
    schemaVersion: 1,
    simulation: true,
    eventType: 'score_accepted',
    occurredAt: ISODate('2030-01-01T10:01:00.000Z'),
    source: {
      entity: 'score_entry',
      key: {
        score_entry_id: 1001
      },
      snapshot: {
        score_entry_id: 1001,
        player_id: 1,
        game_id: 101,
        score: 840,
        achieved_at: '2024-03-10T12:00:00Z',
        is_current: true
      }
    },
    embedded: {
      player: [
        {
          key: {
            player_id: 1
          },
          snapshot: {
            player_id: 1,
            handle: 'mira',
            joined_at: '2024-01-15T09:30:00Z'
          },
          via: [
            'score_entry.player_id → player'
          ]
        }
      ],
      game: [
        {
          key: {
            game_id: 101
          },
          snapshot: {
            game_id: 101,
            title: 'Orbit Rally',
            release_date: '2023-09-12',
            is_active: true
          },
          via: [
            'score_entry.game_id → game'
          ]
        }
      ]
    },
    references: {},
    details: {
      channel: 'mobile',
      note: 'Illustrative event-specific metadata',
      examples: {
        event_payload: 'illustrative event_payload',
        client_metadata: 'illustrative client_metadata'
      }
    }
  }
]
[
  {
    _id: 'score_accepted',
    documentCount: 1
  },
  {
    _id: 'score_submitted',
    documentCount: 1
  }
]
Invalid date error caught successfully: 121
Duplicate ID error caught successfully: 11000
Final Document Count: 2

Atlas atlas-9ugtfk-shard-0 [primary] portfolio_nosql>
