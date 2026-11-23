
# Day 10 - Set 1: Retail Price Change Audit

## Trigger Risks

### 1. Hidden Logic
Triggers execute automatically whenever a database operation occurs.

Developers may not know that additional operations are happening in the background. This makes debugging and maintenance difficult.

### 2. Cascading Triggers
One trigger may execute another trigger through additional database operations.

This can cause unexpected execution chains, performance problems and unintended data modifications.

## Application Code vs Triggers

Application code is better when business rules require complex validation, user interaction or detailed error messages.

For example, an e-commerce application may need to display a message explaining why a product price was rejected before submitting the update.

## AFTER UPDATE Trigger

- Executes after a successful update.
- Uses inserted and deleted tables.
- Records old and new prices.
- Supports multi-row updates using set-based SQL.

## INSTEAD OF UPDATE Trigger

- Executes instead of the original update.
- Validates the proposed selling price.
- Rejects prices below cost.
- Logs rejected attempts.
- Allows valid rows to be updated.

## MongoDB Change Streams

MongoDB Change Streams monitor database changes in real time.

Requirements:
- MongoDB replica set or sharded cluster.
- MongoDB 8.0.
- MongoDB Node.js driver.

### Trigger vs Change Stream

| SQL Server Trigger | MongoDB Change Stream |
|---|---|
| Executes database logic automatically | Notifies applications about changes |
| Runs inside the database transaction | Application processes change events |
| Can modify or reject operations | Observes changes; cannot directly reject the original operation |
| Uses inserted and deleted tables | Uses change event documents |

## Conclusion

SQL Server triggers are useful for automatic auditing and enforcing database-level rules.

MongoDB Change Streams are useful for monitoring real-time changes and notifying external applications.
