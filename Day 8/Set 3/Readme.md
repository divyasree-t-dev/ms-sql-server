# Day 8 – Set 3: Retail Inventory Reservation

## Business Scenario
An online retailer must reserve product stock when an order is placed and release the reserved stock if payment fails.

## Objectives
- Implement inventory reservation using SQL transactions.
- Demonstrate COMMIT and ROLLBACK.
- Identify products with below-average category stock using correlated subqueries.
- Rank products by sales within each category using CTEs and ROW_NUMBER().
- Analyze month-on-month sales using LEAD() and LAG().
- Demonstrate MongoDB atomic stock updates using `$inc`.

## Deliverables

| File Name | Description |
|---|---|
| reservation.sql | Inventory reservation transaction, order insertion and rollback demonstration |
| rank_report.sql | Correlated subquery, CTE-based ranking and monthly sales analysis |
| stock_update.js | MongoDB atomic stock decrement and release using `$inc` |
| Explanation_Note.docx | Explanation of SQL transactions and MongoDB atomic updates |
| README.md | Project overview and execution details |

## Technologies Used
- Microsoft SQL Server 2025
- SQL
- MongoDB
- JavaScript
- MongoDB Shell

## Execution Steps

1. Execute `reservation.sql` in SQL Server Management Studio.
2. Verify successful inventory reservation and rollback behavior.
3. Execute `rank_report.sql` to generate inventory and sales reports.
4. Run `stock_update.js` using MongoDB Shell.
5. Verify stock decrement and stock release operations.
6. Refer to `Explanation_Note.docx` for conceptual explanations.

## Key Concepts
- Database Transactions
- ACID Properties
- COMMIT and ROLLBACK
- Correlated Subqueries
- Common Table Expressions (CTEs)
- ROW_NUMBER()
- PARTITION BY
- LEAD() and LAG()
- MongoDB Atomic Updates
- `$inc` Operator

## Expected Outcome
A retail inventory reservation workflow that maintains stock consistency, handles insufficient inventory through rollback, and supports product sales analysis using SQL and MongoDB.

## Author
Divyasree T
