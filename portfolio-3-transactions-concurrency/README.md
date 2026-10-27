### Transaction Abort & State Recovery Evidence

When an update violates `p3_count_nonnegative` (`p3_processed_count = -1`), PostgreSQL marks the transaction block as aborted:

```text
ERROR: 23514: new row for relation "score_entry" violates check constraint "p3_count_nonnegative"
ERROR: 25P02: current transaction is aborted, commands ignored until end of transaction block
