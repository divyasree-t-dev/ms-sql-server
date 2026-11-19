
# Day 8 - Set 1: Transaction Isolation Levels

## 1. READ COMMITTED

READ COMMITTED is the default isolation level in SQL Server.

- Prevents dirty reads.
- A transaction can only read committed data.
- Other committed changes may become visible during the same transaction.
- Non-repeatable reads are possible.

### Two-Session Example

Session A:

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN;

SELECT Balance
FROM BankAccounts
WHERE AccountID = 101;

WAITFOR DELAY '00:00:10';

SELECT Balance
FROM BankAccounts
WHERE AccountID = 101;

COMMIT TRAN;
```

Session B (execute during Session A's delay):

```sql
BEGIN TRAN;

UPDATE BankAccounts
SET Balance = Balance + 500
WHERE AccountID = 101;

COMMIT TRAN;
```

Observation:

Session A may see different balances in its two SELECT statements because Session B committed an update between them.

## 2. SNAPSHOT ISOLATION

SNAPSHOT isolation provides a transaction-level consistent view of committed data.

- Prevents dirty reads.
- Prevents non-repeatable reads within the transaction.
- Uses row versions instead of ordinary shared read locks.
- Requires ALLOW_SNAPSHOT_ISOLATION to be enabled.
- Can consume additional tempdb version-store space.

### Enable Snapshot Isolation

```sql
ALTER DATABASE BankDB
SET ALLOW_SNAPSHOT_ISOLATION ON;
```

### Two-Session Example

Session A:

```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN;

SELECT Balance
FROM BankAccounts
WHERE AccountID = 101;

WAITFOR DELAY '00:00:10';

SELECT Balance
FROM BankAccounts
WHERE AccountID = 101;

COMMIT TRAN;
```

Session B:

```sql
BEGIN TRAN;

UPDATE BankAccounts
SET Balance = Balance + 500
WHERE AccountID = 101;

COMMIT TRAN;
```

Observation:

Session A sees the same transaction-level snapshot in both SELECT statements, even after Session B commits its update.

## 3. READ COMMITTED vs SNAPSHOT

| Feature | READ COMMITTED | SNAPSHOT |
|---|---|---|
| Dirty Reads | Prevented | Prevented |
| Non-repeatable Reads | Possible | Prevented |
| Read Consistency | Statement-level | Transaction-level |
| Row Versioning | Optional (RCSI) | Required |
| Resource Usage | Generally lower | Additional version storage |

## 4. MongoDB Multi-Document Transactions

MongoDB supports multi-document transactions using sessions.

Example operations:

1. Start a session.
2. Begin a transaction.
3. Debit the source account.
4. Credit the destination account.
5. Insert the transaction record.
6. Commit all operations together.
7. Abort the transaction if any operation fails.

### Cost of MongoDB Transactions

- Higher latency than individual document writes.
- Additional memory and resource consumption.
- Transaction coordination overhead.
- Increased contention under concurrent updates.
- Requires replica set or sharded cluster support.

## 5. Conclusion

Transactions maintain data consistency during financial operations.

SQL Server uses BEGIN TRAN, COMMIT, ROLLBACK, SAVEPOINT and isolation levels to manage transactions.

MongoDB uses sessions and multi-document transactions to ensure atomic updates across multiple documents.

Both databases help prevent partial bank transfers and maintain reliable financial records.
