 
-- DAY 7 - SET 3
-- RETAIL RETURNS AND REFUNDS
-- SQL Server 2025

CREATE DATABASE RetailReturnsDB;
GO

USE RetailReturnsDB;
GO

-- =========================================
-- 1. TABLE CREATION
-- =========================================

CREATE TABLE Stores (
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    ManagerID INT NULL,
    StoreID INT NOT NULL,
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    City VARCHAR(50)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    StoreID INT NOT NULL,
    EmployeeID INT NOT NULL,
    SaleDate DATE NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY,
    SaleID INT NOT NULL,
    CustomerID INT NULL,
    ReturnDate DATE NOT NULL,
    ReturnQty INT NOT NULL,
    Reason VARCHAR(100),

    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY,
    ReturnID INT NOT NULL,
    RefundAmount DECIMAL(10,2) NOT NULL,
    RefundDate DATE,
    RefundStatus VARCHAR(30),

    FOREIGN KEY (ReturnID) REFERENCES Returns(ReturnID)
);

CREATE TABLE ReturnFeedback (
    FeedbackID INT PRIMARY KEY,
    ReturnID INT NOT NULL,
    Rating INT,
    Comments VARCHAR(250),
    FeedbackDate DATE,

    FOREIGN KEY (ReturnID) REFERENCES Returns(ReturnID)
);

-- =========================================
-- 2. SAMPLE DATA
-- =========================================

INSERT INTO Stores VALUES
(1, 'Chennai Central', 'South'),
(2, 'Coimbatore Store', 'South'),
(3, 'Bangalore Store', 'South');

INSERT INTO Employees VALUES
(101, 'Ravi Kumar', NULL, 1),
(102, 'Arun Kumar', 101, 1),
(103, 'Priya Sharma', 101, 2),
(104, 'Karthik Raj', 103, 3);

INSERT INTO Customers VALUES
(1, 'Divya', 'Chennai'),
(2, 'Arun', 'Coimbatore'),
(3, 'Karthik', 'Bangalore'),
(4, 'Meena', 'Chennai');

INSERT INTO Products VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Headphones', 'Electronics'),
(103, 'Smart Watch', 'Accessories'),
(104, 'Backpack', 'Accessories');

INSERT INTO Sales VALUES
(1001, 101, 1, 1, 102, '2026-01-05', 10, 50000),
(1002, 101, 2, 2, 103, '2026-01-06', 10, 50000),
(1003, 102, 1, 1, 102, '2026-01-07', 10, 2000),
(1004, 103, 3, 2, 103, '2026-01-08', 5, 8000),
(1005, 103, 4, 3, 104, '2026-01-09', 5, 8000),
(1006, 104, 2, 3, 104, '2026-01-10', 10, 1500),
(1007, 104, 3, 1, 102, '2026-01-11', 5, 1500);

INSERT INTO Returns VALUES
(5001, 1001, 1, '2026-01-12', 2, 'Damaged product'),
(5002, 1002, 2, '2026-01-13', 1, 'Wrong item'),
(5003, 1003, 1, '2026-01-14', 2, 'Not satisfied'),
(5004, 1005, 4, '2026-01-15', 1, 'Quality issue'),
(5005, 1007, NULL, '2026-01-16', 1, 'Legacy record');

INSERT INTO Refunds VALUES
(6001, 5001, 100000, '2026-01-13', 'Processed'),
(6002, 5002, 50000, '2026-01-14', 'Processed'),
(6003, 5003, 4000, '2026-01-15', 'Processed');

INSERT INTO ReturnFeedback VALUES
(7001, 5001, 2, 'Product was damaged', '2026-01-13'),
(7002, 5002, 3, 'Received wrong item', '2026-01-14'),
(7003, 5003, 2, 'Not satisfied with quality', '2026-01-15'),
(7004, 5004, 1, 'Poor product quality', '2026-01-16');

-- =========================================
-- 3. TEN REPORTING QUESTIONS
-- =========================================

-- QUERY 1:
-- Products with return rate above 10 percent

SELECT
    P.ProductID,
    P.ProductName,
    SUM(S.Quantity) AS TotalSold,
    COALESCE(SUM(R.ReturnQty), 0) AS TotalReturned,
    CAST(
        COALESCE(SUM(R.ReturnQty), 0) * 100.0 /
        NULLIF(SUM(S.Quantity), 0)
        AS DECIMAL(10,2)
    ) AS ReturnRate
FROM Products P
JOIN Sales S
    ON P.ProductID = S.ProductID
LEFT JOIN Returns R
    ON S.SaleID = R.SaleID
GROUP BY P.ProductID, P.ProductName
HAVING
    COALESCE(SUM(R.ReturnQty), 0) * 100.0 /
    NULLIF(SUM(S.Quantity), 0) > 10;


-- QUERY 2:
-- Customers who returned products but received no refund

SELECT DISTINCT
    C.CustomerID,
    C.CustomerName
FROM Customers C
JOIN Returns R
    ON C.CustomerID = R.CustomerID
WHERE NOT EXISTS (
    SELECT 1
    FROM Refunds RF
    WHERE RF.ReturnID = R.ReturnID
);


-- QUERY 3:
-- Store with the highest total refund value

SELECT TOP 1 WITH TIES
    ST.StoreID,
    ST.StoreName,
    SUM(RF.RefundAmount) AS TotalRefund
FROM Stores ST
JOIN Sales S
    ON ST.StoreID = S.StoreID
JOIN Returns R
    ON S.SaleID = R.SaleID
JOIN Refunds RF
    ON R.ReturnID = RF.ReturnID
GROUP BY ST.StoreID, ST.StoreName
ORDER BY SUM(RF.RefundAmount) DESC;


-- QUERY 4:
-- Employees and their managers
-- SELF JOIN

SELECT
    E.EmployeeID,
    E.EmployeeName AS Employee,
    M.EmployeeName AS Manager
FROM Employees E
LEFT JOIN Employees M
    ON E.ManagerID = M.EmployeeID;


-- QUERY 5:
-- Detailed return information using EQUI JOINS

SELECT
    R.ReturnID,
    C.CustomerName,
    P.ProductName,
    ST.StoreName,
    R.ReturnQty,
    R.Reason
FROM Returns R
JOIN Sales S
    ON R.SaleID = S.SaleID
JOIN Customers C
    ON S.CustomerID = C.CustomerID
JOIN Products P
    ON S.ProductID = P.ProductID
JOIN Stores ST
    ON S.StoreID = ST.StoreID;


-- QUERY 6:
-- Products that have at least one return
-- Using IN

SELECT
    ProductID,
    ProductName
FROM Products
WHERE ProductID IN (
    SELECT S.ProductID
    FROM Sales S
    JOIN Returns R
        ON S.SaleID = R.SaleID
);


-- QUERY 7:
-- NOT IN NULL PITFALL DEMONSTRATION

-- This query returns no rows because the
-- subquery contains a NULL CustomerID.

SELECT
    CustomerID,
    CustomerName
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID
    FROM Returns
);

-- CORRECT METHOD: NOT EXISTS

SELECT
    C.CustomerID,
    C.CustomerName
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Returns R
    WHERE R.CustomerID = C.CustomerID
);


-- QUERY 8:
-- Compare store refunds with other stores
-- in the same region using ANY and ALL

-- ANY:
-- Stores whose refund amount is greater
-- than at least one other store in their region.

SELECT
    ST.StoreID,
    ST.StoreName,
    ST.Region,
    COALESCE(SUM(RF.RefundAmount), 0) AS TotalRefund
FROM Stores ST
LEFT JOIN Sales S
    ON ST.StoreID = S.StoreID
LEFT JOIN Returns R
    ON S.SaleID = R.SaleID
LEFT JOIN Refunds RF
    ON R.ReturnID = RF.ReturnID
GROUP BY ST.StoreID, ST.StoreName, ST.Region
HAVING
    COALESCE(SUM(RF.RefundAmount), 0) > ANY (
        SELECT
            COALESCE(SUM(RF2.RefundAmount), 0)
        FROM Stores ST2
        LEFT JOIN Sales S2
            ON ST2.StoreID = S2.StoreID
        LEFT JOIN Returns R2
            ON S2.SaleID = R2.SaleID
        LEFT JOIN Refunds RF2
            ON R2.ReturnID = RF2.ReturnID
        WHERE ST2.Region = ST.Region
          AND ST2.StoreID <> ST.StoreID
        GROUP BY ST2.StoreID
    );


-- ALL:
-- Stores whose refund amount is greater
-- than every other store in their region.

SELECT
    ST.StoreID,
    ST.StoreName,
    ST.Region,
    COALESCE(SUM(RF.RefundAmount), 0) AS TotalRefund
FROM Stores ST
LEFT JOIN Sales S
    ON ST.StoreID = S.StoreID
LEFT JOIN Returns R
    ON S.SaleID = R.SaleID
LEFT JOIN Refunds RF
    ON R.ReturnID = RF.ReturnID
GROUP BY ST.StoreID, ST.StoreName, ST.Region
HAVING
    COALESCE(SUM(RF.RefundAmount), 0) > ALL (
        SELECT
            COALESCE(SUM(RF2.RefundAmount), 0)
        FROM Stores ST2
        LEFT JOIN Sales S2
            ON ST2.StoreID = S2.StoreID
        LEFT JOIN Returns R2
            ON S2.SaleID = R2.SaleID
        LEFT JOIN Refunds RF2
            ON R2.ReturnID = RF2.ReturnID
        WHERE ST2.Region = ST.Region
          AND ST2.StoreID <> ST.StoreID
        GROUP BY ST2.StoreID
    );


-- QUERY 9:
-- Nested subquery:
-- Products whose return quantity is greater
-- than the average return quantity.

SELECT
    ProductID,
    ProductName
FROM Products
WHERE ProductID IN (
    SELECT S.ProductID
    FROM Sales S
    JOIN Returns R
        ON S.SaleID = R.SaleID
    GROUP BY S.ProductID
    HAVING SUM(R.ReturnQty) > (
        SELECT AVG(ProductReturnQty)
        FROM (
            SELECT SUM(R2.ReturnQty) AS ProductReturnQty
            FROM Sales S2
            JOIN Returns R2
                ON S2.SaleID = R2.SaleID
            GROUP BY S2.ProductID
        ) AS ReturnSummary
    )
);


-- QUERY 10:
-- Nested subquery:
-- Customers whose total refund amount
-- is greater than the average refund
-- amount per customer.

SELECT
    C.CustomerID,
    C.CustomerName,
    SUM(RF.RefundAmount) AS TotalRefund
FROM Customers C
JOIN Returns R
    ON C.CustomerID = R.CustomerID
JOIN Refunds RF
    ON R.ReturnID = RF.ReturnID
GROUP BY C.CustomerID, C.CustomerName
HAVING SUM(RF.RefundAmount) > (
    SELECT AVG(CustomerRefund)
    FROM (
        SELECT
            SUM(RF2.RefundAmount) AS CustomerRefund
        FROM Returns R2
        JOIN Refunds RF2
            ON R2.ReturnID = RF2.ReturnID
        WHERE R2.CustomerID IS NOT NULL
        GROUP BY R2.CustomerID
    ) AS CustomerRefundSummary
);

-- END OF SCRIPT
