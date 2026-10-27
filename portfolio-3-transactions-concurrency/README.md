# Portfolio 3: Transactions and Concurrency Control

## 1. Executive Summary
This module evaluates transaction handling and concurrency management for the **Global Arcade Hub** system. Using PostgreSQL's Multiversion Concurrency Control (MVCC) framework, we evaluate:
1. **ACID Compliance**: Demonstrating atomic multi-statement commits, explicit rollback mechanisms on constraint violations, and intermediate transaction state recovery.
2. **Isolation Levels**: Analyzing ANSI/ISO isolation guarantees (`READ COMMITTED` vs `SERIALIZABLE`).
3. **Concurrency Control**: Empirical testing of a **Lost Update Anomaly** and its resolution via pessimistic row-level locking (`SELECT ... FOR UPDATE`).

---

## 2. Transaction Management & Error Recovery (`transactions.sql`)

To test atomic state changes without altering primary business data, a helper column `p3_processed_count` with a domain check constraint `CHECK (p3_processed_count >= 0)` was added to `portfolio.score_entry`.

### 2.1 Successful Atomic Execution (`COMMIT`)
```sql
BEGIN ISOLATION LEVEL READ COMMITTED;
UPDATE portfolio."score_entry" 
SET "p3_processed_count" = "p3_processed_count" + 1 
WHERE "score_entry_id" IS NOT DISTINCT FROM 1001 
RETURNING json_build_object('processed_count', "p3_processed_count");
COMMIT;

ERROR: 23514: new row for relation "score_entry" violates check constraint "p3_count_nonnegative"
DETAIL: Failing row contains (1001, ..., -1).

ERROR: 25P02: current transaction is aborted, commands ignored until end of transaction block

### Experiment 2: Pessimistic Row Locking (`SELECT ... FOR UPDATE`)

By acquiring an exclusive row lock during initial read, concurrent edits are serialized:

| Step | Session A | Session B | Row Lock State |
| --- | --- | --- | --- |
| 1 | `BEGIN;` | - | Free |
| 2 | `SELECT ... FOR UPDATE;` (Reads 1) | - | **Locked by Session A** |
| 3 | Holding Lock | `BEGIN;` | Locked by Session A |
| 4 | Holding Lock | `SELECT ... FOR UPDATE;` | **BLOCKED (Waiting for Session A)** |
| 5 | `UPDATE ... SET count = 2; COMMIT;` | Waiting... | **Lock Released** |
| 6 | - | **Unblocks!** Reads updated `2` | Locked by Session B |
| 7 | - | `UPDATE ... SET count = 3; COMMIT;` | Free |

* **Outcome**: Final `p3_processed_count` equals `3`. Row locking eliminates stale reads and guarantees strict write consistency under high concurrency.
