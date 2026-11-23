
# Day 10 - Set 2: Bank Account Balance Guard

## 1. Trigger Limitations

### A. Nested Triggers

A nested trigger occurs when one trigger performs an operation that activates another trigger.

Example:
- An INSERT occurs in account_transaction.
- The AFTER trigger inserts a record into account_transaction_audit.
- The audit table's AFTER INSERT trigger executes.
- The second trigger inserts a message into trigger_execution_log.

This creates a trigger execution chain.

**Risk:** Too many nested triggers can affect performance and make debugging difficult.

### B. Recursive Triggers

A recursive trigger occurs when a trigger causes the same trigger to execute again.

Example:
- An INSERT activates trg_Recursive_Demo.
- The trigger inserts another row into recursion_demo.
- The same trigger executes again.

**Risk:** Uncontrolled recursion can cause excessive execution and eventually reach SQL Server's nesting limit.

## 2. How to Prevent Trigger Loops

1. Use TRIGGER_NESTLEVEL() to check the current trigger nesting level.
2. Avoid unnecessary updates inside triggers.
3. Use RECURSIVE_TRIGGERS OFF when direct recursive triggers are not required.
4. Keep trigger logic simple.
5. Avoid circular dependencies between tables and triggers.

## 3. INSTEAD OF UPDATE Trigger

The trigger is created on vw_accounts.

- Checks whether a savings account balance becomes negative.
- Uses THROW to raise a meaningful error.
- Rejects the entire batch if any row violates the rule.
- Updates accounts only when all rows pass validation.

## 4. AFTER INSERT / UPDATE / DELETE Trigger

The transaction audit trigger records:
- INSERT operations.
- UPDATE operations.
- DELETE operations.
- Old and new account IDs.
- Old and new transaction amounts.
- User and timestamp.

The inserted and deleted tables are combined using FULL OUTER JOIN to support all three operations and multi-row changes.

## 5. MongoDB Change Streams

The watch_alerts.js script monitors the fraud_alerts collection.

Requirements:
- MongoDB 8.0.
- MongoDB replica set or sharded cluster.
- MongoDB Node.js driver.

The script listens for INSERT events and prints every new fraud alert.

## 6. Trigger vs Change Stream

| SQL Server Trigger | MongoDB Change Stream |
|---|---|
| Executes database logic | Notifies applications about changes |
| Can reject an operation | Observes committed changes |
| Executes within the database transaction | Events are consumed by applications |
| Supports INSERT, UPDATE and DELETE | Supports multiple change event types |

## 7. Important Audit Limitation

An audit table is not automatically immutable just because a trigger writes to it.

To improve audit protection:
- Restrict UPDATE and DELETE permissions.
- Give applications INSERT-only access where appropriate.
- Consider SQL Server Ledger or other tamper-evident audit mechanisms.

## Conclusion

SQL Server triggers help maintain transaction history and enforce balance rules.

MongoDB Change Streams help applications react to real-time database events.

Triggers should be designed carefully to avoid recursion, hidden logic and performance problems.
