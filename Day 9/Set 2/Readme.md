# Day 9 – Set 3: Telecom Low-Balance Follow-up

## Business Scenario
A telecom operator needs to identify prepaid subscribers whose account balance is below 50 currency units and notify them to recharge their accounts.

## Objectives
- Create SQL views to display prepaid subscriber details and recharge summaries.
- Implement row-level hiding of postpaid users.
- Develop a stored procedure to process recharges with proper validation and transaction handling.
- Create user-defined functions to calculate remaining validity days and retrieve recent recharge history.
- Generate low-balance notifications using both cursor-based and set-based approaches.
- Compare the execution time of both approaches.
- Create a MongoDB view to display unread notification counts per subscriber.

## Tasks Implemented

### 1. SQL Views (`views.sql`)
- Created `vw_prepaid_subscribers`.
- Created `vw_recharge_summary`.
- Applied a view to hide postpaid subscriber records.

### 2. Stored Procedure and Functions (`procedures.sql`)
- Created `usp_Recharge` with amount and plan validation.
- Used transactions to update subscriber balance and insert recharge history.
- Returned the updated balance using an OUTPUT parameter.
- Created `fn_ValidityDaysLeft`.
- Created a table-valued function to retrieve the last five recharges of a subscriber.

### 3. Cursor and Set-Based Processing (`cursor.sql`)
- Used a cursor to identify subscribers with balances below 50.
- Inserted notification records for eligible subscribers.
- Implemented the same operation using `INSERT...SELECT`.
- Measured and compared execution times.

### 4. MongoDB View (`mongo_view.js`)
- Created a MongoDB view on the notification-log collection.
- Displayed the unread notification count for each subscriber.

## Technologies Used
- Microsoft SQL Server
- T-SQL
- MongoDB
- MongoDB Aggregation Pipeline

## Deliverables
- `views.sql`
- `procedures.sql`
- `cursor.sql`
- `mongo_view.js`
- Timing comparison results

## Learning Outcomes
- Understanding SQL views and data filtering.
- Implementing stored procedures, transactions and OUTPUT parameters.
- Working with scalar and table-valued functions.
- Understanding cursor-based and set-based processing.
- Measuring SQL query execution performance.
- Creating MongoDB views using aggregation pipelines.

## Author
Divyasree T

Day 9 – Set 3 | Telecom Low-Balance Follow-up
