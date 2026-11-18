# Day 6 – Set 1: Retail Sales Reporting

## Objective
To generate daily and monthly retail sales reports using SQL Server queries and MongoDB aggregation pipelines.

## Database
- Database Name: RetailDB
- Tables: customers, products, orders, order_items, payments

## Tasks Completed

### 1. SQL Server
- Top 5 products by revenue.
- Month-wise sales report.
- Customers with more than three orders using HAVING.
- Average basket value per city.
- Orders without payment using LEFT JOIN.
- Customers with no orders.
- Product category revenue share.
- Day with the highest sales.

### 2. SQL Functions
Implemented the following functions:
- UPPER()
- CONCAT()
- DATEDIFF()
- FORMAT()
- ROUND()

### 3. NULL Handling
Explained the behaviour of:
- COUNT(*)
- COUNT(column)
- AVG(column)

### 4. MongoDB
Created three aggregation pipelines for:
- Month-wise sales.
- Top 5 products by revenue.
- Average basket value per city.

MongoDB aggregation stages used:
- $lookup
- $unwind
- $group
- $sort
- $limit
- $project

## Deliverables
- schema.sql
- seed_data.sql
- reports.sql
- MongoDB aggregation pipelines and expected outputs documented in a Word document.

## Tools Used
- SQL Server Management Studio (SSMS)
- MongoDB
- MongoDB Compass / Mongosh
- Microsoft Word

## Status
Completed.
