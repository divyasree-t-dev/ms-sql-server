
-- =============================================
-- DAY 10 - SET 1
-- RETAIL PRICE CHANGE AUDIT
-- File: triggers.sql
-- SQL Server 2025
-- =============================================

-- Create Database
IF DB_ID('RetailDB') IS NULL
    CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

-- =============================================
-- 1. DROP EXISTING OBJECTS
-- =============================================

DROP TRIGGER IF EXISTS dbo.trg_ProductPrice_Audit;
DROP TRIGGER IF EXISTS dbo.trg_ProductPrice_Validation;
GO

DROP TABLE IF EXISTS dbo.price_audit;
DROP TABLE IF EXISTS dbo.rejected_price_attempts;
DROP TABLE IF EXISTS dbo.product_price;
GO

-- =============================================
-- 2. CREATE PRODUCT PRICE TABLE
-- =============================================

CREATE TABLE dbo.product_price
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,

    CONSTRAINT CK_Product_Cost
        CHECK (cost_price >= 0)
);
GO

-- =============================================
-- 3. CREATE PRICE AUDIT TABLE
-- =============================================

CREATE TABLE dbo.price_audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_by SYSNAME NOT NULL,
    changed_at DATETIME2 NOT NULL
);
GO

-- =============================================
-- 4. CREATE REJECTED ATTEMPTS TABLE
-- =============================================

CREATE TABLE dbo.rejected_price_attempts
(
    rejection_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10,2),
    attempted_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    rejected_by SYSNAME NOT NULL,
    rejected_at DATETIME2 NOT NULL,
    rejection_reason VARCHAR(200)
);
GO

-- =============================================
-- 5. AFTER UPDATE TRIGGER
-- Records successful price changes
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_ProductPrice_Audit
ON dbo.product_price
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.price_audit
    (
        product_id,
        old_price,
        new_price,
        changed_by,
        changed_at
    )
    SELECT
        d.product_id,
        d.selling_price,
        i.selling_price,
        SUSER_SNAME(),
        SYSDATETIME()
    FROM inserted i
    INNER JOIN deleted d
        ON i.product_id = d.product_id
    WHERE i.selling_price <> d.selling_price;
END;
GO

-- =============================================
-- 6. INSTEAD OF UPDATE TRIGGER
-- Rejects prices below cost
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_ProductPrice_Validation
ON dbo.product_price
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Log rejected price attempts
    INSERT INTO dbo.rejected_price_attempts
    (
        product_id,
        old_price,
        attempted_price,
        cost_price,
        rejected_by,
        rejected_at,
        rejection_reason
    )
    SELECT
        i.product_id,
        d.selling_price,
        i.selling_price,
        i.cost_price,
        SUSER_SNAME(),
        SYSDATETIME(),
        'Selling price cannot be below cost price'
    FROM inserted i
    INNER JOIN deleted d
        ON i.product_id = d.product_id
    WHERE i.selling_price < i.cost_price;

    -- Apply only valid updates
    UPDATE p
    SET
        p.product_name = i.product_name,
        p.cost_price = i.cost_price,
        p.selling_price = i.selling_price
    FROM dbo.product_price p
    INNER JOIN inserted i
        ON p.product_id = i.product_id
    WHERE i.selling_price >= i.cost_price;

END;
GO

PRINT 'Set 1 triggers created successfully.';
GO
