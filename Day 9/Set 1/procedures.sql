
USE RetailDB;
GO

/* =====================================================
   PART 1: CREATE SEQUENCES FOR MANUAL ID GENERATION
   order_id and item_id are NOT IDENTITY columns.
   ===================================================== */

IF OBJECT_ID('dbo.OrderIDSequence', 'SO') IS NULL
BEGIN
    DECLARE @NextOrderID INT;

    SELECT @NextOrderID = ISNULL(MAX(order_id), 0) + 1
    FROM dbo.orders;

    DECLARE @OrderSQL NVARCHAR(MAX) =
        N'CREATE SEQUENCE dbo.OrderIDSequence
          AS INT START WITH ' +
          CAST(@NextOrderID AS NVARCHAR(20)) +
          N' INCREMENT BY 1;';

    EXEC sp_executesql @OrderSQL;
END;
GO

IF OBJECT_ID('dbo.OrderItemIDSequence', 'SO') IS NULL
BEGIN
    DECLARE @NextItemID INT;

    SELECT @NextItemID = ISNULL(MAX(item_id), 0) + 1
    FROM dbo.order_items;

    DECLARE @ItemSQL NVARCHAR(MAX) =
        N'CREATE SEQUENCE dbo.OrderItemIDSequence
          AS INT START WITH ' +
          CAST(@NextItemID AS NVARCHAR(20)) +
          N' INCREMENT BY 1;';

    EXEC sp_executesql @ItemSQL;
END;
GO


/* =====================================================
   PART 2: CREATE TABLE TYPE FOR ORDER ITEMS
   ===================================================== */

IF TYPE_ID('dbo.OrderLineType') IS NULL
BEGIN
    EXEC sp_executesql N'
        CREATE TYPE dbo.OrderLineType AS TABLE
        (
            product_id INT PRIMARY KEY,
            quantity INT NOT NULL
        );';
END;
GO


/* =====================================================
   PART 3: STORED PROCEDURE - PLACE ORDER
   Features:
   - Input parameters
   - OUTPUT order number
   - Stock validation
   - Transaction
   - TRY...CATCH error handling
   ===================================================== */

CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
    @CustomerID INT,
    @OrderLines dbo.OrderLineType READONLY,
    @OrderNumber INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @OrderNumber = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate customer
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.customers
            WHERE customer_id = @CustomerID
        )
        BEGIN
            THROW 50001, 'Invalid customer ID.', 1;
        END;

        -- Validate order lines
        IF NOT EXISTS (SELECT 1 FROM @OrderLines)
        BEGIN
            THROW 50002, 'Order must contain at least one item.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @OrderLines
            WHERE quantity <= 0
        )
        BEGIN
            THROW 50003, 'Quantity must be greater than zero.', 1;
        END;

        -- Validate product IDs and stock availability
        IF EXISTS
        (
            SELECT 1
            FROM @OrderLines ol
            LEFT JOIN dbo.products p WITH (UPDLOCK, HOLDLOCK)
                ON ol.product_id = p.product_id
            WHERE p.product_id IS NULL
               OR p.stock_quantity < ol.quantity
        )
        BEGIN
            THROW 50004, 'Invalid product or insufficient stock.', 1;
        END;

        -- Generate order ID
        SET @OrderNumber =
            NEXT VALUE FOR dbo.OrderIDSequence;

        -- Insert order
        INSERT INTO dbo.orders
        (
            order_id,
            customer_id,
            order_date,
            payment_status,
            order_status
        )
        VALUES
        (
            @OrderNumber,
            @CustomerID,
            CAST(GETDATE() AS DATE),
            'Pending',
            'Pending'
        );

        -- Insert order items
        INSERT INTO dbo.order_items
        (
            item_id,
            order_id,
            product_id,
            quantity,
            unit_price
        )
        SELECT
            NEXT VALUE FOR dbo.OrderItemIDSequence,
            @OrderNumber,
            ol.product_id,
            ol.quantity,
            p.price
        FROM @OrderLines ol
        INNER JOIN dbo.products p
            ON ol.product_id = p.product_id;

        -- Reduce product stock
        UPDATE p
        SET p.stock_quantity = p.stock_quantity - ol.quantity
        FROM dbo.products p
        INNER JOIN @OrderLines ol
            ON p.product_id = ol.product_id;

        COMMIT TRANSACTION;

        PRINT 'Order placed successfully.';
        SELECT @OrderNumber AS OrderNumber;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @OrderNumber = NULL;

        THROW;
    END CATCH;
END;
GO


/* =====================================================
   PART 4: SCALAR FUNCTION - ORDER TOTAL WITH TAX
   Tax rate: 18%
   ===================================================== */

CREATE OR ALTER FUNCTION dbo.fn_OrderTotalWithTax
(
    @OrderID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT
        @Total = ISNULL(SUM(quantity * unit_price), 0) * 1.18
    FROM dbo.order_items
    WHERE order_id = @OrderID;

    RETURN @Total;
END;
GO


/* =====================================================
   PART 5: INLINE TABLE-VALUED FUNCTION
   Returns orders for a selected customer.
   ===================================================== */

CREATE OR ALTER FUNCTION dbo.fn_CustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.payment_status,
        o.order_status,
        SUM(oi.quantity * oi.unit_price) AS OrderTotal,
        SUM(oi.quantity * oi.unit_price) * 0.18 AS TaxAmount,
        SUM(oi.quantity * oi.unit_price) * 1.18 AS TotalWithTax
    FROM dbo.orders o
    INNER JOIN dbo.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date,
        o.payment_status,
        o.order_status
);
GO


/* =====================================================
   PART 6: VERIFICATION QUERIES
   ===================================================== */

-- Check stored procedure
SELECT name
FROM sys.procedures
WHERE name = 'usp_PlaceOrder';
GO

-- Check scalar function
SELECT dbo.fn_OrderTotalWithTax(
    (SELECT MAX(order_id) FROM dbo.orders)
) AS LatestOrderTotalWithTax;
GO

-- Check inline table-valued function
SELECT *
FROM dbo.fn_CustomerOrders(1);
GO

-- Compare procedure result with function result
SELECT
    order_id,
    OrderTotal,
    TaxAmount,
    TotalWithTax
FROM dbo.fn_CustomerOrders(1);
GO


/* =====================================================
   PART 7: STORED PROCEDURE TEST
   Already tested earlier.
   Uncomment only when you intentionally want
   to create a NEW order and reduce stock.
   ===================================================== */

-- DECLARE @OrderLines dbo.OrderLineType;
-- DECLARE @NewOrderNumber INT;

-- INSERT INTO @OrderLines (product_id, quantity)
-- VALUES
--     (1, 2),
--     (2, 1);

-- EXEC dbo.usp_PlaceOrder
--     @CustomerID = 1,
--     @OrderLines = @OrderLines,ss
--     @OrderNumber = @NewOrderNumber OUTPUT;

-- SELECT @NewOrderNumber AS GeneratedOrderNumber;
-- GO
