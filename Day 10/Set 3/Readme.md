
# Day 10 - Set 3: Hospital Bed Capacity Control

## 1. Trigger-Based Admission Validation

The INSTEAD OF INSERT trigger prevents admissions when a ward has insufficient bed capacity.

It:
- Checks the number of requested admissions per ward.
- Compares requested beds with available capacity.
- Uses THROW to reject invalid admissions.
- Inserts records only when sufficient beds are available.
- Updates occupied bed counts.

If one admission in a multi-row batch exceeds capacity, the entire batch is rejected.

## 2. Admission Audit Trigger

The AFTER INSERT, UPDATE and DELETE trigger maintains an admission history.

It records:
- Admission ID.
- Operation type.
- Old and new patient names.
- Old and new ward IDs.
- User who performed the operation.
- Date and time of the change.

It also maintains occupied bed counts when admissions are updated or deleted.

## 3. Multi-Row Insert Behaviour

Suppose a general ward has:
- Capacity: 3 beds.
- Occupied beds: 3.

A batch attempts to admit three patients:
- One patient into the full general ward.
- Two patients into the ICU ward.

The trigger detects insufficient capacity in the general ward.

Using THROW rejects the entire INSERT statement.

Therefore:
- No new admissions are inserted.
- ICU occupancy remains unchanged.
- General ward occupancy remains unchanged.

This ensures batch consistency.

## 4. Constraint vs Trigger vs Stored Procedure

### When a Constraint Is Better

A CHECK constraint is better for simple rules involving individual rows.

Example:
- Ward capacity must be greater than zero.
- Occupied beds cannot be negative.
- Occupied beds cannot exceed capacity.

Constraints are simple, efficient and automatically enforced.

### When a Stored Procedure Is Better

A stored procedure is better for complex admission workflows.

For example:
- Checking bed availability.
- Assigning a ward.
- Registering patient details.
- Updating occupied bed counts.
- Returning meaningful status messages.

It makes the workflow explicit and easier to maintain.

A transaction with appropriate locking can ensure concurrent admissions do not exceed capacity.

### When a Trigger Is Better

A trigger is useful when the rule must apply automatically to direct database INSERT, UPDATE or DELETE operations, regardless of which application performs them.

## 5. MongoDB Change Streams

The watch_wards.js script monitors the ward_alerts collection.

It:
- Listens for INSERT events.
- Filters alerts with severity = critical.
- Prints the ward name and alert time.

Requirements:
- MongoDB 8.0.
- Replica set or sharded cluster.
- MongoDB Node.js driver.

## Conclusion

SQL Server triggers help enforce hospital admission rules and maintain audit history.

Constraints are suitable for simple validation, stored procedures are suitable for controlled business workflows, and triggers are useful for automatic database-level enforcement.

MongoDB Change Streams provide real-time monitoring of critical ward alerts.
