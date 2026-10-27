# Portfolio 3: Transactions and Concurrency Control

## 1. Executive Summary
This module evaluates transaction handling and concurrency management for the **Global Arcade Hub** system. Using PostgreSQL's Multiversion Concurrency Control (MVCC) framework, we evaluate:

1. **ACID Compliance**: Demonstrating atomic multi-statement commits, explicit rollback mechanisms on constraint violations, and intermediate transaction state recovery.
2. **Isolation Levels**: Analyzing ANSI/ISO isolation guarantees (`READ COMMITTED` vs `SERIALIZABLE`).
3. **Concurrency Control**: Empirical testing of a Lost Update Anomaly and its resolution via pessimistic row-level locking (`SELECT ... FOR UPDATE`).

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
