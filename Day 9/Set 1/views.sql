
USE RetailDB;
GO

/* =====================================================
   PART 1: DATABASE SCHEMA INSPECTION
   ===================================================== */

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'customers',
    'products',
    'orders',
    'order_items',
    'payments'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO


/* =====================================================
   PART 2: PREPARE TABLES FOR DAY 9 ASSIGNMENT
   ===================================================== */

-- Add cost price
IF COL_LENGTH('dbo.products', 'cost_price') IS NULL
BEGIN
    ALTER TABLE dbo.products
    ADD cost_price DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_products_cost_price DEFAULT 0;
END;
GO

-- Add supplier name
IF COL_LENGTH('dbo.products', 'supplier_name') IS NULL
BEGIN
    ALTER TABLE dbo.products
    ADD supplier_name VARCHAR(100) NULL;
END;
GO

-- Add stock quantity
IF COL_LENGTH('dbo.products', 'stock_quantity') IS NULL
BEGIN
    ALTER TABLE dbo.products
    ADD stock_quantity INT NOT NULL
        CONSTRAINT DF_products_stock_quantity DEFAULT 100;
END;
GO

-- Add order status
IF COL_LENGTH('dbo.orders', 'order_status') IS NULL
BEGIN
    ALTER TABLE dbo.orders
    ADD order_status VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_order_status DEFAULT 'Pending';
END;
GO

-- Verify table changes
SELECT * FROM dbo.products;
SELECT * FROM dbo.orders;
GO


/* =====================================================
   PART 3: CHECK IDENTITY PROPERTIES
   ===================================================== */

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    COLUMNPROPERTY(
        OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME),
        COLUMN_NAME,
        'IsIdentity'
    ) AS IsIdentity
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    (TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_id')
    OR
    (TABLE_NAME = 'order_items' AND COLUMN_NAME = 'item_id');
GO


/* =====================================================
   PART 4: VIEW 1 - ORDER SUMMARY
   Hides cost price and supplier information
   ===================================================== */

CREATE OR ALTER VIEW dbo.vw_order_summary
AS
SELECT
    o.order_id,
    c.customer_id,
    c.customer_name,
    o.order_date,
    o.payment_status,
    o.order_status,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM dbo.orders o
INNER JOIN dbo.customers c
    ON o.customer_id = c.customer_id
INNER JOIN dbo.order_items oi
    ON o.order_id = oi.order_id
INNER JOIN dbo.products p
    ON oi.product_id = p.product_id;
GO

-- Verify order summary view
SELECT *
FROM dbo.vw_order_summary;
GO


/* =====================================================
   PART 5: VIEW 2 - LOW STOCK PRODUCTS
   Displays products with stock quantity <= 10
   ===================================================== */

CREATE OR ALTER VIEW dbo.vw_low_stock
AS
SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM dbo.products
WHERE stock_quantity <= 10;
GO

-- Verify low stock view
SELECT *
FROM dbo.vw_low_stock;
GO


/* =====================================================
   PART 6: VIEW 3 - UPDATABLE VIEW
   WITH CHECK OPTION
   ===================================================== */

CREATE OR ALTER VIEW dbo.vw_available_products
AS
SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM dbo.products
WHERE stock_quantity > 0
WITH CHECK OPTION;
GO

-- Verify available products view
SELECT *
FROM dbo.vw_available_products;
GO


/* =====================================================
   PART 7: UPDATABLE VIEW TEST
   Already executed successfully.
   Uncomment only when testing again.
   ===================================================== */

-- UPDATE dbo.vw_available_products
-- SET price = price + 10
-- WHERE product_id = 2;
-- GO

-- SELECT *
-- FROM dbo.vw_available_products
-- WHERE product_id = 2;
-- GO


/* =====================================================
   PART 8: WITH CHECK OPTION VALIDATION
   Expected to fail because stock_quantity = 0
   ===================================================== */

-- UPDATE dbo.vw_available_products
-- SET stock_quantity = 0
-- WHERE product_id = 2;
-- GO
