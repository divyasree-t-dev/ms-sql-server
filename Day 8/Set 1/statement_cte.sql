
-- DAY 8 - SET 1: MONTHLY BANK STATEMENT
-- CTE, ROW_NUMBER AND LAG

IF OBJECT_ID('dbo.BankTransactions', 'U') IS NOT NULL
    DROP TABLE dbo.BankTransactions;
GO

CREATE TABLE dbo.BankTransactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionDate DATETIME,
    TransactionType VARCHAR(20),
    Amount DECIMAL(12,2),
    BalanceAfter DECIMAL(12,2)
);
GO

INSERT INTO dbo.BankTransactions
VALUES
(1, 101, '2026-11-01 09:00', 'DEPOSIT', 5000, 15000),
(2, 101, '2026-11-05 10:30', 'WITHDRAWAL', 2000, 13000),
(3, 101, '2026-11-10 12:00', 'DEPOSIT', 3000, 16000),
(4, 101, '2026-11-15 14:00', 'WITHDRAWAL', 1000, 15000),
(5, 101, '2026-11-20 16:00', 'DEPOSIT', 2500, 17500),
(6, 102, '2026-11-03 09:30', 'DEPOSIT', 4000, 9000),
(7, 102, '2026-11-08 11:00', 'WITHDRAWAL', 1500, 7500),
(8, 102, '2026-11-18 13:00', 'DEPOSIT', 2000, 9500);
GO

-- MONTHLY STATEMENT USING CTE

DECLARE @AccountID INT = 101;
DECLARE @MonthStart DATE = '2026-11-01';

WITH MonthlyStatement AS
(
    SELECT
        TransactionID,
        AccountID,
        TransactionDate,
        TransactionType,
        Amount,
        BalanceAfter
    FROM dbo.BankTransactions
    WHERE AccountID = @AccountID
      AND TransactionDate >= @MonthStart
      AND TransactionDate < DATEADD(MONTH, 1, @MonthStart)
)
SELECT
    ROW_NUMBER() OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS TransactionNumber,

    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,

    LAG(BalanceAfter, 1, NULL) OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS PreviousBalance,

    BalanceAfter AS CurrentBalance

FROM MonthlyStatement
ORDER BY TransactionDate, TransactionID;
GO

-- STATEMENT FOR ALL ACCOUNTS

WITH MonthlyStatement AS
(
    SELECT *
    FROM dbo.BankTransactions
    WHERE TransactionDate >= '2026-11-01'
      AND TransactionDate < '2026-12-01'
)
SELECT
    ROW_NUMBER() OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS TransactionNumber,

    AccountID,
    TransactionDate,
    TransactionType,
    Amount,

    LAG(BalanceAfter) OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS PreviousBalance,

    BalanceAfter AS CurrentBalance

FROM MonthlyStatement
ORDER BY AccountID, TransactionDate;
GO
