
-- =============================================
-- DAY 10 - SET 2
-- TEST EVIDENCE
-- File: test_evidence.sql
-- =============================================

USE BankDB;
GO

-- =============================================
-- 1. INSERT FIVE ACCOUNTS
-- =============================================

DELETE FROM dbo.trigger_execution_log;
DELETE FROM dbo.account_transaction_audit;
DELETE FROM dbo.account_transaction;

DELETE FROM dbo.accounts;
GO

INSERT INTO dbo.accounts
(
    account_id,
    account_holder,
    account_type,
    balance
)
VALUES
(201, 'Arun',   'Savings', 1000.00),
(202, 'Bala',   'Savings', 2000.00),
(203, 'Charan', 'Savings', 3000.00),
(204, 'Divya',  'Current', 4000.00),
(205, 'Ezhil',  'Savings', 5000.00);
GO

PRINT 'Five bank accounts inserted.';
GO

SELECT * FROM dbo.accounts;
GO

-- =============================================
-- 2. TEST INSERT TRANSACTION
-- =============================================

INSERT INTO dbo.account_transaction
(
    transaction_id,
    account_id,
    transaction_type,
    amount
)
VALUES
(1001, 201, 'Deposit', 500.00),
(1002, 202, 'Withdrawal', 200.00),
(1003, 203, 'Deposit', 750.00);
GO

PRINT 'Transaction INSERT test completed.';
GO

-- =============================================
-- 3. TEST UPDATE TRANSACTION
-- =============================================

UPDATE dbo.account_transaction
SET amount = 600.00
WHERE transaction_id = 1001;
GO

PRINT 'Transaction UPDATE test completed.';
GO

-- =============================================
-- 4. TEST DELETE TRANSACTION
-- =============================================

DELETE FROM dbo.account_transaction
WHERE transaction_id = 1002;
GO

PRINT 'Transaction DELETE test completed.';
GO

-- =============================================
-- 5. VERIFY TRANSACTION AUDIT
-- =============================================

SELECT
    audit_id,
    transaction_id,
    action_type,
    old_account_id,
    new_account_id,
    old_amount,
    new_amount,
    old_transaction_type,
    new_transaction_type,
    changed_by,
    changed_at
FROM dbo.account_transaction_audit
ORDER BY audit_id;
GO

-- =============================================
-- 6. VERIFY NESTED TRIGGER EXECUTION
-- =============================================

SELECT *
FROM dbo.trigger_execution_log
ORDER BY log_id;
GO

-- =============================================
-- 7. TEST BATCH UPDATE OF FIVE ACCOUNTS
-- One savings account will become negative.
-- Entire batch must be rejected.
-- =============================================

BEGIN TRY

    UPDATE dbo.vw_accounts
    SET balance =
        CASE
            WHEN account_id = 201 THEN 1500.00
            WHEN account_id = 202 THEN 2500.00
            WHEN account_id = 203 THEN -100.00
            WHEN account_id = 204 THEN 4500.00
            WHEN account_id = 205 THEN 5500.00
        END
    WHERE account_id IN (201, 202, 203, 204, 205);

    PRINT 'Batch update completed.';

END TRY
BEGIN CATCH

    PRINT 'BATCH UPDATE REJECTED';
    PRINT ERROR_MESSAGE();

END CATCH;
GO

-- =============================================
-- 8. VERIFY BATCH UPDATE RESULT
-- All five accounts should retain old balances.
-- =============================================

SELECT
    account_id,
    account_holder,
    account_type,
    balance
FROM dbo.accounts
ORDER BY account_id;
GO

-- =============================================
-- 9. TEST VALID BATCH UPDATE
-- All five updates should succeed.
-- =============================================

UPDATE dbo.vw_accounts
SET balance =
    CASE
        WHEN account_id = 201 THEN 1500.00
        WHEN account_id = 202 THEN 2500.00
        WHEN account_id = 203 THEN 3500.00
        WHEN account_id = 204 THEN 4500.00
        WHEN account_id = 205 THEN 5500.00
    END
WHERE account_id IN (201, 202, 203, 204, 205);
GO

SELECT *
FROM dbo.accounts
ORDER BY account_id;
GO

-- =============================================
-- 10. TEST RECURSIVE TRIGGER
-- Enable recursive triggers temporarily.
-- =============================================

ALTER DATABASE BankDB
SET RECURSIVE_TRIGGERS ON;
GO

INSERT INTO dbo.recursion_demo(description)
VALUES ('Initial insertion');
GO

-- The guarded trigger should create exactly
-- one additional row.

SELECT *
FROM dbo.recursion_demo
ORDER BY demo_id;
GO

-- Disable recursive triggers after testing.
ALTER DATABASE BankDB
SET RECURSIVE_TRIGGERS OFF;
GO

PRINT 'Recursive trigger test completed.';
GO

-- =============================================
-- 11. FINAL VERIFICATION
-- =============================================

PRINT 'FINAL ACCOUNT TRANSACTION AUDIT';
SELECT * FROM dbo.account_transaction_audit;

PRINT 'FINAL NESTED TRIGGER LOG';
SELECT * FROM dbo.trigger_execution_log;

PRINT 'FINAL ACCOUNT BALANCES';
SELECT * FROM dbo.accounts;

PRINT 'ALL SET 2 TESTS COMPLETED.';
GO
