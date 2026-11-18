# Day 7 – Set 3: Retail Returns and Refunds

## Overview
This assignment focuses on analysing retail product returns, customer refunds, store performance, employee relationships and customer feedback using SQL Server 2025 and MongoDB 8.0.

## Technologies Used
- SQL Server 2025
- MongoDB 8.0
- SQL Joins and Subqueries
- MongoDB Aggregation Framework

## Files Included

| File Name | Description |
|---|---|
| `advanced_reports.sql` | SQL queries covering joins, self joins, subqueries, NULL handling, ANY, ALL and nested subqueries. |
| `reports.js` | Three MongoDB aggregation pipelines using `$lookup` to retrieve related information from multiple collections. |
| `Expected_Results_and_Explanation.docx` | Expected query results, join and subquery explanations, MongoDB pipeline descriptions and SQL–MongoDB comparison. |

## Tasks Covered

1. Identified products with a return rate above 10%.
2. Retrieved customers who returned products without receiving refunds.
3. Identified stores with the highest refund value.
4. Displayed employees and their respective managers using SELF JOIN.
5. Retrieved detailed return information using EQUI JOIN.
6. Demonstrated IN and NOT IN subqueries.
7. Explained the NULL pitfall in NOT IN and corrected it using NOT EXISTS.
8. Compared store refund values using ANY and ALL.
9. Implemented nested subqueries for above-average product return quantities.
10. Identified customers with above-average refund amounts.

## MongoDB Implementation

Three aggregation pipelines were developed:

- Return details with customer, product and feedback information.
- Store-wise refund analysis with feedback counts.
- Customers who returned products without receiving refunds.

## Execution

**SQL Server:**
1. Open SQL Server Management Studio.
2. Execute `advanced_reports.sql`.
3. Review the query outputs.

**MongoDB:**
1. Connect to MongoDB using MongoDB Shell.
2. Execute `reports.js`.
3. Review the aggregation pipeline results.

## Conclusion

This assignment demonstrates the practical application of SQL joins, subqueries, NULL handling and MongoDB `$lookup` operations for retail returns and refund analysis. It also compares relational database queries with MongoDB aggregation pipelines.
