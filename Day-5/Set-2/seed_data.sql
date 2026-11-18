USE BankBranchDB;
GO

INSERT INTO Customer (CustomerName, Phone, Email, Address)
VALUES
('Arun Kumar', '9876543210', 'arun@gmail.com', 'Chennai'),
('Priya Sharma', '9876543211', 'priya@gmail.com', 'Coimbatore'),
('Karthik Raj', '9876543212', 'karthik@gmail.com', 'Madurai'),
('Divya S', '9876543213', 'divya@gmail.com', 'Chengalpattu'),
('Rahul M', '9876543214', 'rahul@gmail.com', 'Salem'),
('Sneha R', '9876543215', 'sneha@gmail.com', 'Trichy'),
('Vijay K', '9876543216', 'vijay@gmail.com', 'Vellore'),
('Meena P', '9876543217', 'meena@gmail.com', 'Erode');
GO

INSERT INTO Branch (BranchName, BranchCode, Location)
VALUES
('Chennai Main Branch', 'CHN001', 'Chennai'),
('Coimbatore Branch', 'CBE001', 'Coimbatore'),
('Madurai Branch', 'MDU001', 'Madurai');
GO

INSERT INTO AccountType (AccountTypeName)
VALUES
('Savings'),
('Current'),
('Salary');
GO

INSERT INTO AccountType (AccountTypeName)
VALUES
('Savings'),
('Current'),
('Salary');
GO

INSERT INTO RelationshipManager
(ManagerName, EmployeeCode, BranchID)
VALUES
('Ramesh Kumar', 'EMP001', 1),
('Anitha Devi', 'EMP002', 1),
('Suresh Babu', 'EMP003', 2),
('Lakshmi N', 'EMP004', 3);
GO

INSERT INTO Account
(AccountNumber, CustomerID, AccountTypeID,
 BranchID, ManagerID, Balance, OpenDate)
VALUES
('ACC1001', 1, 1, 1, 1, 50000, '2026-09-15'),
('ACC1002', 2, 2, 2, 3, 75000, '2026-10-05'),
('ACC1003', 3, 1, 3, 4, 30000, '2026-08-20'),
('ACC1004', 4, 1, 1, 2, 90000, '2026-10-18'),
('ACC1005', 5, 2, 2, 3, 120000, '2026-07-10'),
('ACC1006', 6, 3, 1, 1, 45000, '2026-11-01'),
('ACC1007', 7, 1, 3, 4, 65000, '2026-09-25'),
('ACC1008', 8, 2, 2, 3, 80000, '2026-11-05');
GO

INSERT INTO Transactions
(AccountID, TransactionReference, TransactionDate,
 Description, Amount)
VALUES
(1, 'TXN001', '2026-09-16', 'ATM Withdrawal', -2000),
(1, 'TXN002', '2026-09-18', 'Salary Credit', 30000),
(2, 'TXN003', '2026-10-06', 'Online Transfer', -5000),
(3, 'TXN004', '2026-08-21', 'Cash Deposit', 10000),
(4, 'TXN005', '2026-10-19', 'UPI Payment', -1500),
(5, 'TXN006', '2026-07-11', 'Cheque Deposit', 20000),
(6, 'TXN007', '2026-11-02', 'Salary Credit', 25000),
(7, 'TXN008', '2026-09-26', 'ATM Withdrawal', -3000),
(8, 'TXN009', '2026-11-06', 'Online Transfer', -4000);
GO

SELECT * FROM Customer;
SELECT * FROM Branch;
SELECT * FROM AccountType;
SELECT * FROM RelationshipManager;
SELECT * FROM Account;
SELECT * FROM Transactions;
GO

USE BankBranchDB;
GO

UPDATE Account
SET Balance = 60000
WHERE AccountNumber = 'ACC1001';
GO

SELECT * FROM Account
WHERE AccountNumber = 'ACC1001';
GO


DELETE FROM Transactions
WHERE TransactionReference = 'TXN009';
GO

SELECT * FROM Transactions
WHERE TransactionReference = 'TXN009';
GO


SELECT *
FROM Account
WHERE BranchID = 1
AND Balance > 50000;
GO


SELECT *
FROM Account
WHERE AccountTypeID = 1
OR AccountTypeID = 2;
GO


SELECT *
FROM Account
WHERE BranchID IN (1, 2, 3);
GO


SELECT *
FROM Account
WHERE Balance BETWEEN 50000 AND 100000;
GO


SELECT
    AccountNumber,
    CustomerID,
    Balance,
    OpenDate
FROM Account
WHERE OpenDate >= '2026-07-01'
AND OpenDate < '2026-10-01'
AND Balance > 50000;
GO

USE BankBranchDB;
GO

CREATE TABLE TestIdentity (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);
GO


INSERT INTO TestIdentity (Name)
VALUES
('Arun'),
('Priya'),
('Karthik');
GO

SELECT * FROM TestIdentity;
GO


DELETE FROM TestIdentity;
GO

SELECT * FROM TestIdentity;
GO


INSERT INTO TestIdentity (Name)
VALUES ('Divya');
GO

SELECT * FROM TestIdentity;
GO


TRUNCATE TABLE TestIdentity;
GO

SELECT * FROM TestIdentity;
GO


INSERT INTO TestIdentity (Name)
VALUES ('Meena');
GO

SELECT * FROM TestIdentity;
GO


BEGIN TRANSACTION;

TRUNCATE TABLE TestIdentity;

SELECT * FROM TestIdentity;

ROLLBACK TRANSACTION;

SELECT * FROM TestIdentity;
GO


BEGIN TRANSACTION;

DROP TABLE TestIdentity;

ROLLBACK TRANSACTION;
GO


SELECT * FROM TestIdentity;
GO


BEGIN TRANSACTION;

DELETE FROM TestIdentity;

SELECT * FROM TestIdentity;

ROLLBACK TRANSACTION;

SELECT * FROM TestIdentity;
GO

DROP TABLE TestIdentity;
GO



USE BankBranchDB;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO


SELECT COUNT(*) AS TotalCustomers FROM Customer;
SELECT COUNT(*) AS TotalBranches FROM Branch;
SELECT COUNT(*) AS TotalManagers FROM RelationshipManager;
SELECT COUNT(*) AS TotalAccountTypes FROM AccountType;
SELECT COUNT(*) AS TotalAccounts FROM Account;
SELECT COUNT(*) AS TotalTransactions FROM Transactions;
GO