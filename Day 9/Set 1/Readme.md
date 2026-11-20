# Day 9 – Set 1: Retail Order Fulfilment

## Business Scenario

A retail company manages customer orders, product inventory, payments, and order fulfilment. The system requires views for reporting, stored procedures for order processing, functions for calculating order totals, and cursor-based processing for pending order follow-ups.

## Objectives

- Create SQL Server views for order summaries and low-stock products.
- Implement an updatable view using `WITH CHECK OPTION`.
- Develop stored procedures with input and output parameters.
- Use transactions and error handling for order placement.
- Create scalar and inline table-valued functions.
- Process pending orders using cursors.
- Compare cursor-based and set-based processing.
- Create a MongoDB view to summarize order statuses.

## Technologies Used

- Microsoft SQL Server
- T-SQL
- MongoDB
- JavaScript
- SQL Server Management Studio
- MongoDB Shell

## Project Files

| File | Description |
|---|---|
| `views.sql` | Creates order summary, low-stock, and updatable views. |
| `procedures.sql` | Implements order placement, transaction handling, and SQL functions. |
| `cursor.sql` | Implements cursor-based and set-based pending order follow-ups. |
| `mongo_view.js` | Creates a MongoDB view for order status summaries. |
| `cursor_vs_setbased.txt` | Explains the differences between cursor and set-based processing. |

## Key Implementations

### 1. SQL Server Views
- `vw_order_summary`
- `vw_low_stock`
- `vw_available_products`

### 2. Stored Procedure
- `usp_PlaceOrder`
- Uses input parameters and an OUTPUT parameter.
- Validates product availability and stock.
- Inserts orders and order items within a transaction.
- Updates product stock.
- Handles errors using TRY...CATCH.

### 3. SQL Functions
- `fn_OrderTotalWithTax` – Calculates order total including 18% tax.
- `fn_CustomerOrders` – Returns order details for a customer.

### 4. Cursor and Set-Based Processing
- `usp_ProcessPendingOrders_Cursor`
- `usp_ProcessPendingOrders_SetBased`
- Identifies pending orders older than three days and creates follow-up records.

### 5. MongoDB View
- `order_status_counts`
- Groups orders by status.
- Calculates total orders and total order amount.

## Execution Results

- SQL views created and tested successfully.
- Stored procedure and functions executed successfully.
- Cursor processing created 12 follow-up records.
- Set-based procedure executed successfully and avoided duplicate follow-ups.

## Learning Outcomes

- Understanding SQL Server views and their limitations.
- Implementing stored procedures and user-defined functions.
- Managing transactions and handling SQL errors.
- Working with cursors and set-based operations.
- Creating and querying MongoDB views.

---

**Assignment:** Hexaware Training – Day 9, Set 1  
**Domain:** Retail Order Fulfilment
