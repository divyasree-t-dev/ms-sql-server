# Day 9 – Set 2: Insurance Premium Processing

## Business Scenario
An insurance company renews policies every month and requires consistent premium calculations, renewal validation, audit logging, and policy status management.

## Tasks Completed

### 1. SQL View – `vw_policy_due`
- Created a view to identify policies due for renewal within the next 30 days.
- Retrieved customer and agent details.
- Excluded sensitive customer information.

### 2. Stored Procedure – `usp_RenewPolicy`
- Validated policy status before renewal.
- Checked for pending claims.
- Recalculated the renewal premium.
- Inserted an audit record.
- Used transaction handling to maintain data consistency.

### 3. User-Defined Functions
- Created scalar function `fn_PremiumWithNoClaimDiscount`.
- Created a table-valued function to return renewal quotes for an agent.

### 4. Cursor and Set-Based Processing
- Used a cursor to identify policies with lapsed premiums.
- Updated policy status to `Lapsed`.
- Logged individual updates.
- Reimplemented the same operation using set-based SQL for comparison.

### 5. MongoDB View
- Created a MongoDB view for customer communications.
- Filtered unresolved complaints.

## Technologies Used
- Microsoft SQL Server
- T-SQL
- MongoDB
- MongoDB JavaScript Shell

## Deliverables
- `views.sql`
- `procedures.sql`
- `cursor.sql`
- `mongo_view.js`
- `comparison_note.md`

## Key Concepts Practiced
- SQL Views
- Stored Procedures
- Scalar and Table-Valued Functions
- Transactions and Error Handling
- Audit Logging
- Cursors
- Set-Based Operations
- MongoDB Views and Aggregation Pipelines
