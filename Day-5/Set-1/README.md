# Set 1 – Retail Inventory and Product Reviews

## Project Overview
This project focuses on managing retail inventory and product review data using SQL Server and MongoDB.

## Technologies Used
- Microsoft SQL Server
- MongoDB
- MongoDB Compass
- SQL
- JavaScript (MongoDB Shell)

## Tasks Completed

### 1. Database Normalization
- Normalized the retail inventory spreadsheet into 3NF.
- Identified insertion, update, and deletion anomalies.
- Designed relational tables with appropriate relationships.

### 2. SQL Server Operations
- Created the `RetailInventoryDB` database.
- Created tables: Category, Supplier, Warehouse, Product, and Inventory.
- Implemented Primary Keys, Foreign Keys, UNIQUE, CHECK, and DEFAULT constraints.
- Inserted sample records into all tables.
- Tested constraint violations using invalid INSERT statements.
- Performed UPDATE and DELETE operations with WHERE conditions.

### 3. MongoDB Operations
- Created a `reviews` collection.
- Implemented JSON Schema validation.
- Performed `insertMany()`, `find()`, `updateOne()`, and `deleteOne()` operations.
- Added explanations for using MongoDB for product reviews and search activity logs.

## Project Files

| File | Description |
|---|---|
| `schema.sql` | Database and table creation |
| `seed_data.sql` | Sample data insertion and constraint testing |
| `update_delete.sql` | UPDATE and DELETE operations |
| `Set1_MongoDB_Operations.docx` | MongoDB commands and explanations |

## Learning Outcomes
- Understanding database normalization and 3NF.
- Implementing relational database constraints.
- Performing SQL CRUD operations.
- Understanding MongoDB collections and document validation.
- Working with SQL Server and MongoDB.
