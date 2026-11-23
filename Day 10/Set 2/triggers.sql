
-- =============================================
-- DAY 10 - SET 2
-- BANK ACCOUNT BALANCE GUARD
-- File: triggers.sql
-- SQL Server 2025
-- =============================================

-- 1. CREATE DATABASE
IF DB_ID('BankDB') IS NULL
    CREATE DATABASE BankDB;
GO

USE BankDB;
GO

-- =============================================
-- 2. DROP EXISTING OBJECTS
-- =============================================

DROP TRIGGER IF EXISTS dbo.trg_AccountTransaction_Audit;
DROP TRIGGER IF EXISTS dbo.trg_Audit_NestedDemo;
DROP TRIGGER IF EXISTS dbo.trg_AccountBalance_Guard;
DROP TRIGGER IF EXISTS dbo.trg_Recursive_Demo;
GO

DROP VIEW IF EXISTS dbo.vw_accounts;
GO

DROP TABLE IF EXISTS dbo.trigger_execution_log;
DROP TABLE IF EXISTS dbo.recursion_demo;
DROP TABLE IF EXISTS dbo.account_transaction_audit;
DROP TABLE IF EXISTS dbo.account_transaction;
DROP TABLE IF EXISTS dbo.accounts;
GO

-- =============================================
-- 3. CREATE ACCOUNTS TABLE
-- =============================================

CREATE TABLE dbo.accounts
(
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(12,2) NOT NULL,

    CONSTRAINT CK_Account_Type
        CHECK (account_type IN ('Savings', 'Current'))
);
GO

-- =============================================
-- 4. CREATE ACCOUNT TRANSACTION TABLE
-- =============================================

CREATE TABLE dbo.account_transaction
(
    transaction_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Transaction_Account
        FOREIGN KEY (account_id)
        REFERENCES dbo.accounts(account_id),

    CONSTRAINT CK_Transaction_Type
        CHECK (transaction_type IN ('Deposit', 'Withdrawal')),

    CONSTRAINT CK_Transaction_Amount
        CHECK (amount > 0)
);
GO

-- =============================================
-- 5. CREATE TRANSACTION AUDIT TABLE
-- =============================================

CREATE TABLE dbo.account_transaction_audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id INT NOT NULL,
    action_type VARCHAR(10) NOT NULL,
    old_account_id INT NULL,
    new_account_id INT NULL,
    old_amount DECIMAL(12,2) NULL,
    new_amount DECIMAL(12,2) NULL,
    old_transaction_type VARCHAR(20) NULL,
    new_transaction_type VARCHAR(20) NULL,
    changed_by SYSNAME NOT NULL,
    changed_at DATETIME2 NOT NULL
);
GO

-- =============================================
-- 6. NESTED TRIGGER EXECUTION LOG
-- =============================================

CREATE TABLE dbo.trigger_execution_log
(
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    message VARCHAR(200),
    logged_at DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- =============================================
-- 7. AFTER INSERT / UPDATE / DELETE TRIGGER
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_AccountTransaction_Audit
ON dbo.account_transaction
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.account_transaction_audit
    (
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
    )
    SELECT
        COALESCE(i.transaction_id, d.transaction_id),

        CASE
            WHEN d.transaction_id IS NULL THEN 'INSERT'
            WHEN i.transaction_id IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,

        d.account_id,
        i.account_id,
        d.amount,
        i.amount,
        d.transaction_type,
        i.transaction_type,
        SUSER_SNAME(),
        SYSDATETIME()

    FROM inserted i
    FULL OUTER JOIN deleted d
        ON i.transaction_id = d.transaction_id;
END;
GO

-- =============================================
-- 8. NESTED TRIGGER DEMONSTRATION
-- Audit insertion automatically executes
-- another trigger.
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_Audit_NestedDemo
ON dbo.account_transaction_audit
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.trigger_execution_log(message)
    SELECT
        CONCAT(
            'Nested trigger executed for transaction ',
            transaction_id,
            ' - ',
            action_type
        )
    FROM inserted;
END;
GO

-- =============================================
-- 9. CREATE ACCOUNTS VIEW
-- =============================================

CREATE VIEW dbo.vw_accounts
AS
SELECT
    account_id,
    account_holder,
    account_type,
    balance
FROM dbo.accounts;
GO

-- =============================================
-- 10. INSTEAD OF UPDATE TRIGGER
-- Prevents negative savings balance
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_AccountBalance_Guard
ON dbo.vw_accounts
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Reject the entire batch if any savings
    -- account would have a negative balance.

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE account_type = 'Savings'
          AND balance < 0
    )
    BEGIN
        THROW 51001,
            'Transaction rejected: Savings account balance cannot be negative.',
            1;
    END;

    -- Apply valid updates
    UPDATE a
    SET
        a.account_holder = i.account_holder,
        a.account_type = i.account_type,
        a.balance = i.balance
    FROM dbo.accounts a
    INNER JOIN inserted i
        ON a.account_id = i.account_id;

    PRINT 'Account balances updated successfully.';
END;
GO

-- =============================================
-- 11. RECURSIVE TRIGGER DEMONSTRATION TABLE
-- =============================================

CREATE TABLE dbo.recursion_demo
(
    demo_id INT IDENTITY(1,1) PRIMARY KEY,
    description VARCHAR(100)
);
GO

-- =============================================
-- 12. GUARDED RECURSIVE TRIGGER
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_Recursive_Demo
ON dbo.recursion_demo
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Stop recursion after one nested execution
    IF TRIGGER_NESTLEVEL() < 2
    BEGIN
        INSERT INTO dbo.recursion_demo(description)
        SELECT
            'Automatically inserted by recursive trigger'
            FROM inserted;
    END;
END;
GO

PRINT 'Set 2 database objects and triggers created successfully.';
GO
