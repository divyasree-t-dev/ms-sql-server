
-- =============================================
-- DAY 10 - SET 1
-- TEST EVIDENCE
-- File: test_evidence.sql
-- =============================================

USE RetailDB;
GO

-- =============================================
-- 1. INSERT SAMPLE PRODUCTS
-- =============================================

DELETE FROM dbo.price_audit;
DELETE FROM dbo.rejected_price_attempts;
DELETE FROM dbo.product_price;
GO

INSERT INTO dbo.product_price
(
    product_id,
    product_name,
    cost_price,
    selling_price
)
VALUES
(101, 'Keyboard',  50.00,  70.00),
(102, 'Mouse',    100.00, 130.00),
(103, 'Monitor',   20.00,  30.00),
(104, 'Laptop',   200.00, 250.00),
(105, 'Headphones',80.00, 100.00);
GO

PRINT 'Initial products inserted.';
GO

SELECT * FROM dbo.product_price;
GO

-- =============================================
-- 2. SINGLE-ROW UPDATE
-- Valid price change
-- =============================================

UPDATE dbo.product_price
SET selling_price = 75.00
WHERE product_id = 101;
GO

PRINT 'Single-row update completed.';
GO

SELECT *
FROM dbo.product_price
WHERE product_id = 101;
GO

-- Check audit
SELECT *
FROM dbo.price_audit;
GO

-- =============================================
-- 3. MULTI-ROW UPDATE
-- Two valid prices and one invalid price
-- =============================================

UPDATE dbo.product_price
SET selling_price =
    CASE
        WHEN product_id = 101 THEN 80.00
        WHEN product_id = 102 THEN 90.00
        WHEN product_id = 103 THEN 35.00
    END
WHERE product_id IN (101, 102, 103);
GO

PRINT 'Multi-row update completed.';
GO

-- =============================================
-- 4. VERIFY FINAL PRODUCT PRICES
-- =============================================

SELECT
    product_id,
    product_name,
    cost_price,
    selling_price
FROM dbo.product_price
ORDER BY product_id;
GO

-- =============================================
-- 5. VERIFY SUCCESSFUL PRICE AUDIT
-- =============================================

SELECT
    audit_id,
    product_id,
    old_price,
    new_price,
    changed_by,
    changed_at
FROM dbo.price_audit
ORDER BY audit_id;
GO

-- =============================================
-- 6. VERIFY REJECTED PRICE ATTEMPTS
-- =============================================

SELECT
    rejection_id,
    product_id,
    old_price,
    attempted_price,
    cost_price,
    rejected_by,
    rejected_at,
    rejection_reason
FROM dbo.rejected_price_attempts
ORDER BY rejection_id;
GO

PRINT 'All Set 1 tests completed successfully.';
GO
