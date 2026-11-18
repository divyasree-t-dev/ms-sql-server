# Set 1 – Logistics Shipment Analysis

## Overview
This assignment focuses on analyzing logistics shipment data using SQL Server and MongoDB. It demonstrates joins, subqueries, self joins, and MongoDB `$lookup` operations to generate useful shipment reports.

## Technologies Used
- SQL Server 2025
- MongoDB 8.0
- MongoDB Compass
- JavaScript

## Files Included

| File Name | Description |
|---|---|
| `advanced_reports.sql` | SQL queries using joins, subqueries, and nested subqueries. |
| `reports.js` | MongoDB aggregation pipelines using `$lookup` to generate shipment reports. |
| `Join_Type_Explanation.docx` | Explanation of the join types selected for the SQL queries. |

## MongoDB Reports

1. **Shipments with Delivery Events** – Displays shipment details along with their related delivery events.
2. **Customers with Their Shipments** – Displays customer information and their shipment details with total shipment counts.
3. **Carrier Delivery Statistics** – Calculates delivered shipment counts and minimum, maximum, and average delivery duration for each carrier.

## Concepts Covered
- INNER JOIN
- LEFT JOIN
- FULL OUTER JOIN
- SELF JOIN
- Subqueries using IN, EXISTS, ANY, and ALL
- Nested Subqueries
- Subquery-to-JOIN Rewriting
- MongoDB `$lookup`, `$unwind`, `$group`, and `$project`

## Conclusion
The assignment demonstrates how SQL Server joins and subqueries, along with MongoDB aggregation pipelines, can be used to retrieve, combine, and analyze logistics shipment data efficiently.
