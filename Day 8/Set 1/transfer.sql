CREATE DATABASE BankDB;
GO

USE BankDB;
GO

SELECT DB_NAME() AS CurrentDatabase;


-- DAY 8 - SET 1: BANK FUNDS TRANSFER
-- SQL Server 2025

-- 1. CREATE AND PREPARE TABLES

IF OBJECT_ID('dbo.BankAccounts', 'U') IS NOT NULL
    DROP TABLE dbo.BankAccounts;
GO

CREATE TABLE dbo.BankAccounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(100),
    Balance DECIMAL(12,2),
    AccountStatus VARCHAR(20)
);
GO

INSERT INTO dbo.BankAccounts
VALUES
(101, 'Arun', 10000.00, 'ACTIVE'),
(102, 'Priya', 5000.00, 'ACTIVE'),
(103, 'Kumar', 2000.00, 'INACTIVE');
GO

-- 2. SUCCESSFUL FUNDS TRANSFER

DECLARE @FromAccount INT = 101;
DECLARE @ToAccount INT = 102;
DECLARE @Amount DECIMAL(12,2) = 1000.00;

BEGIN TRY
    BEGIN TRAN;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.BankAccounts
        WHERE AccountID = @FromAccount
          AND AccountStatus = 'ACTIVE'
    )
        THROW 50001, 'Source account is inactive or invalid.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.BankAccounts
        WHERE AccountID = @ToAccount
          AND AccountStatus = 'ACTIVE'
    )
        THROW 50002, 'Destination account is inactive or invalid.', 1;

    IF @Amount <= 0
        THROW 50003, 'Transfer amount must be positive.', 1;

    IF (SELECT Balance FROM dbo.BankAccounts
        WHERE AccountID = @FromAccount) < @Amount
        THROW 50004, 'Insufficient balance.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccount;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccount;

    COMMIT TRAN;

    PRINT 'Transfer completed successfully.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Transfer failed: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

SELECT * FROM dbo.BankAccounts;
GO

-- 3. DELIBERATE FAILURE AFTER DEBIT
-- Rollback must restore the original balances.

SELECT AccountID, Balance AS BalanceBeforeFailure
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);

BEGIN TRY
    BEGIN TRAN;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 500
    WHERE AccountID = 101;

    PRINT 'Debit completed.';

    -- Deliberate error after debit
    THROW 50010, 'Simulated failure after debit.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 500
    WHERE AccountID = 102;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Rollback executed: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT AccountID, Balance AS BalanceAfterRollback
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);
GO

-- 4. SAVEPOINT: ROLLBACK ONLY THE FEE POSTING

IF OBJECT_ID('dbo.BankFees', 'U') IS NOT NULL
    DROP TABLE dbo.BankFees;
GO

CREATE TABLE dbo.BankFees (
    FeeID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT,
    FeeAmount DECIMAL(10,2)
);
GO

BEGIN TRY
    BEGIN TRAN;

    -- Transfer
    UPDATE dbo.BankAccounts
    SET Balance = Balance - 1000
    WHERE AccountID = 101;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 1000
    WHERE AccountID = 102;

    SAVE TRANSACTION FeeSavepoint;

    BEGIN TRY
        -- Fee posting
        INSERT INTO dbo.BankFees (AccountID, FeeAmount)
        VALUES (101, 50.00);

        -- Simulate fee posting failure
        THROW 50020, 'Fee posting failed.', 1;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() = 1
            ROLLBACK TRANSACTION FeeSavepoint;

        PRINT 'Fee posting rolled back.';
        PRINT ERROR_MESSAGE();
    END CATCH;

    -- Retain the successful transfer
    COMMIT TRAN;

    PRINT 'Transfer committed successfully. Fee was rolled back.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Transfer failed: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- 5. FINAL VERIFICATION

SELECT * FROM dbo.BankAccounts;
SELECT * FROM dbo.BankFees;
GO
