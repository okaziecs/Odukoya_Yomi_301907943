// Run once in mongosh against a fresh exercise database.
// Portfolio 4: NoSQL Event-Sourced Leaderboard Model
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("leaderboard_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // 1. Create collection with strict JSON Schema Validation
  await db.createCollection("leaderboard_events", {
    validator: {
      "$jsonSchema": {
        "bsonType": "object",
        "required": [
          "_id", "schemaVersion", "simulation", "eventType", 
          "occurredAt", "source", "embedded", "references", "details"
        ],
        "properties": {
          "_id": { "bsonType": "string", "minLength": 1 },
          "schemaVersion": { "enum": [1] },
          "simulation": { "enum": [true] },
          "eventType": { "bsonType": "string", "enum": ["score_submitted", "score_accepted"] },
          "occurredAt": { "bsonType": "date" },
          "source": {
            "bsonType": "object",
            "required": ["entity", "key", "snapshot"],
            "properties": {
              "entity": { "enum": ["score_entry"] },
              "key": {
                "bsonType": "object",
                "required": ["score_entry_id"]
              },
              "snapshot": { "bsonType": "object" }
            }
          },
          "embedded": { "bsonType": "object" },
          "references": { "bsonType": "object" },
          "details": { "bsonType": "object" }
        }
      }
    },
    validationLevel: 'strict', 
    validationAction: 'error'
  });

  // 2. Insert sample event documents
  printjson(await db.getCollection("leaderboard_events").insertMany([
    {
      "_id": "event_000001",
      "schemaVersion": 1,
      "simulation": true,
      "eventType": "score_submitted",
      "occurredAt": ISODate("2030-01-01T10:00:00Z"),
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
        "player": [{
          "key": { "player_id": 1 },
          "snapshot": { "player_id": 1, "handle": "mira", "joined_at": "2024-01-15T09:30:00Z" },
          "via": ["score_entry.player_id → player"]
        }],
        "game": [{
          "key": { "game_id": 101 },
          "snapshot": { "game_id": 101, "title": "Orbit Rally", "release_date": "2023-09-12", "is_active": true },
          "via": ["score_entry.game_id → game"]
        }]
      },
      "references": {},
      "details": { "channel": "web" }
    },
    {
      "_id": "event_000002",
      "schemaVersion": 1,
      "simulation": true,
      "eventType": "score_accepted",
      "occurredAt": ISODate("2030-01-01T10:01:00Z"),
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
        "player": [{
          "key": { "player_id": 1 },
          "snapshot": { "player_id": 1, "handle": "mira", "joined_at": "2024-01-15T09:30:00Z" },
          "via": ["score_entry.player_id → player"]
        }],
        "game": [{
          "key": { "game_id": 101 },
          "snapshot": { "game_id": 101, "title": "Orbit Rally", "release_date": "2023-09-12", "is_active": true },
          "via": ["score_entry.game_id → game"]
        }]
      },
      "references": {},
      "details": {
        "channel": "mobile",
        "note": "Illustrative event-specific metadata",
        "examples": {
          "event_payload": "illustrative event_payload",
          "client_metadata": "illustrative client_metadata"
        }
      }
    }
  ]));

  // 3. Create Compound Index for Fast Event Filtering
  await db.getCollection("leaderboard_events").createIndex(
    { eventType: 1, occurredAt: -1 }, 
    { name: 'event_type_time' }
  );

  // 4. Sample Query Operations
  printjson(await db.getCollection("leaderboard_events").find({"eventType":"score_submitted"}).sort({_id:1}).limit(5).toArray());
  printjson(await db.getCollection("leaderboard_events").find({"source.key.score_entry_id":1001}).sort({_id:1}).limit(5).toArray());
  printjson(await db.getCollection("leaderboard_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());
  
  // 5. Aggregation Pipeline
  printjson(await db.getCollection("leaderboard_events").aggregate([
    { "$group": { "_id": "$eventType", "documentCount": { "$sum": 1 } } }, 
    { "$sort": { "_id": 1 } }
  ]).toArray());

  // 6. Schema Error Handling Verification (Invalid Date Format)
  try {
    await db.getCollection("leaderboard_events").insertOne({
      "_id": "invalid_date_example",
      "schemaVersion": 1,
      "simulation": true,
      "eventType": "score_submitted",
      "occurredAt": "not-a-date", // Triggers Validator Error
      "source": { "entity": "score_entry", "key": { "score_entry_id": 1001 }, "snapshot": {} },
      "embedded": {},
      "references": {},
      "details": {}
    });
  } catch (error) { print('Invalid date error caught successfully: ' + error.code); }

  // 7. Duplicate Key Verification
  try { 
    await db.getCollection("leaderboard_events").insertOne({
      "_id": "event_000001", // Duplicate ID
      "schemaVersion": 1,
      "simulation": true,
      "eventType": "score_submitted",
      "occurredAt": ISODate("2030-01-01T10:00:00Z"),
      "source": { "entity": "score_entry", "key": { "score_entry_id": 1001 }, "snapshot": {} },
      "embedded": {},
      "references": {},
      "details": {}
    }); 
  } catch (error) { print('Duplicate ID error caught successfully: ' + error.code); }

  print('Final Document Count: ' + await db.getCollection("leaderboard_events").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
