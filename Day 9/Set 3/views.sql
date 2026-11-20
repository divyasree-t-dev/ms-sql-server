
USE TelecomDB;
GO

-- ============================================
-- 1. PREPAID SUBSCRIBERS VIEW
-- ============================================

CREATE OR ALTER VIEW dbo.vw_prepaid_subscribers
AS
SELECT
    subscriber_id,
    subscriber_name,
    circle,
    plan_id,
    balance,
    validity_end_date
FROM dbo.subscribers
WHERE subscriber_type = 'Prepaid';
GO

-- ============================================
-- 2. RECHARGE SUMMARY VIEW
-- ============================================

CREATE OR ALTER VIEW dbo.vw_recharge_summary
AS
SELECT
    rh.recharge_id,
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name,
    rh.recharge_amount,
    rh.recharge_date,
    rh.validity_days
FROM dbo.RechargeHistory AS rh
INNER JOIN dbo.subscribers AS s
    ON rh.subscriber_id = s.subscriber_id
INNER JOIN dbo.plans AS p
    ON rh.plan_id = p.plan_id;
GO

-- ============================================
-- 3. VERIFY PREPAID SUBSCRIBERS
-- ============================================

SELECT *
FROM dbo.vw_prepaid_subscribers;
GO

-- ============================================
-- 4. VERIFY RECHARGE SUMMARY
-- ============================================

SELECT *
FROM dbo.vw_recharge_summary;
GO

-- ============================================
-- 5. TEST POSTPAID HIDING
-- ============================================

BEGIN TRANSACTION;

UPDATE dbo.subscribers
SET subscriber_type = 'Postpaid'
WHERE subscriber_id = 110;

SELECT *
FROM dbo.vw_prepaid_subscribers;

ROLLBACK TRANSACTION;
GO

-- ============================================
-- 6. FINAL VERIFICATION
-- ============================================

SELECT *
FROM dbo.vw_prepaid_subscribers;

PRINT 'Both views created and tested successfully.';
GO
