


-- Day 8 - Set 3: Retail Inventory Reservation
-- Database: SQL Server 2025

-- Create and select database

IF DB_ID('RetailInventoryDB') IS NULL
BEGIN
    CREATE DATABASE RetailInventoryDB;
END;
GO

USE RetailInventoryDB;
GO

-- 1. Create required tables

IF OBJECT_ID('OrderItems', 'U') IS NOT NULL DROP TABLE OrderItems;
IF OBJECT_ID('Orders', 'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Stock INT NOT NULL CHECK (Stock >= 0),
    Price DECIMAL(10,2),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(12,2)
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 2. Insert sample data

INSERT INTO Categories VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Home Appliances');

INSERT INTO Products VALUES
(101, 'Laptop', 1, 20, 55000),
(102, 'Mouse', 1, 50, 500),
(103, 'Keyboard', 1, 30, 1200),
(104, 'T-Shirt', 2, 40, 700),
(105, 'Jeans', 2, 15, 1500),
(106, 'Jacket', 2, 5, 2500),
(107, 'Mixer', 3, 10, 3500),
(108, 'Fan', 3, 25, 2200);

-- 3. Successful inventory reservation transaction

DECLARE @RequestedItems TABLE (
    ProductID INT,
    Quantity INT
);

INSERT INTO @RequestedItems VALUES
(101, 2),
(102, 3);

BEGIN TRY
    BEGIN TRANSACTION;

    -- Check whether sufficient stock is available
    IF EXISTS (
        SELECT 1
        FROM @RequestedItems R
        LEFT JOIN Products P
            ON P.ProductID = R.ProductID
        WHERE P.ProductID IS NULL
           OR P.Stock < R.Quantity
    )
    BEGIN
        THROW 50001, 'Insufficient stock. Order cancelled.', 1;
    END;

    -- Decrement stock
    UPDATE P
    SET P.Stock = P.Stock - R.Quantity
    FROM Products P
    INNER JOIN @RequestedItems R
        ON P.ProductID = R.ProductID;

    -- Insert order
    INSERT INTO Orders (CustomerID, TotalAmount)
    SELECT
        1001,
        SUM(P.Price * R.Quantity)
    FROM @RequestedItems R
    INNER JOIN Products P
        ON P.ProductID = R.ProductID;

    DECLARE @NewOrderID INT = SCOPE_IDENTITY();

    -- Insert order lines
    INSERT INTO OrderItems
        (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        @NewOrderID,
        R.ProductID,
        R.Quantity,
        P.Price
    FROM @RequestedItems R
    INNER JOIN Products P
        ON P.ProductID = R.ProductID;

    COMMIT TRANSACTION;

    PRINT 'Order placed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;

-- 4. Demonstrate rollback due to insufficient stock

DECLARE @FailedItems TABLE (
    ProductID INT,
    Quantity INT
);

-- Product 106 has only 5 units in stock
INSERT INTO @FailedItems VALUES
(106, 3),
(101, 100);

DECLARE @OrdersBefore INT =
    (SELECT COUNT(*) FROM Orders);

DECLARE @StockBefore INT =
    (SELECT Stock FROM Products WHERE ProductID = 106);

BEGIN TRY
    BEGIN TRANSACTION;

    -- Check all requested quantities
    IF EXISTS (
        SELECT 1
        FROM @FailedItems R
        LEFT JOIN Products P
            ON P.ProductID = R.ProductID
        WHERE P.ProductID IS NULL
           OR P.Stock < R.Quantity
    )
    BEGIN
        THROW 50002, 'Insufficient stock. Rolling back order.', 1;
    END;

    UPDATE P
    SET P.Stock = P.Stock - R.Quantity
    FROM Products P
    INNER JOIN @FailedItems R
        ON P.ProductID = R.ProductID;

    INSERT INTO Orders (CustomerID, TotalAmount)
    VALUES (1002, 10000);

    DECLARE @FailedOrderID INT = SCOPE_IDENTITY();

    INSERT INTO OrderItems
        (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        @FailedOrderID,
        R.ProductID,
        R.Quantity,
        P.Price
    FROM @FailedItems R
    INNER JOIN Products P
        ON P.ProductID = R.ProductID;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Expected failure: ' + ERROR_MESSAGE();
    PRINT 'Transaction rolled back successfully.';
END CATCH;

-- 5. Verify rollback

SELECT
    @OrdersBefore AS OrdersBefore,
    COUNT(*) AS OrdersAfter
FROM Orders;

SELECT
    @StockBefore AS StockBefore,
    Stock AS StockAfter
FROM Products
WHERE ProductID = 106;

-- The order count and product 106 stock should remain unchanged.
-- No order should be created for the failed transaction.
