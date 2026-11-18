
-- ============================================================
-- DAY 7 - SET 2: BANK LOAN PORTFOLIO
-- SQL Server 2025
-- File: advanced_reports.sql
-- ============================================================

-- 1. DATABASE CREATION
CREATE DATABASE BankLoanDB;
GO

USE BankLoanDB;
GO

-- ============================================================
-- 2. TABLE CREATION
-- ============================================================

CREATE TABLE Branches (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    BranchID INT,
    LoanAmount DECIMAL(12,2),
    InterestRate DECIMAL(5,2),
    LoanDate DATE,
    LoanStatus VARCHAR(30),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

CREATE TABLE LoanInstallments (
    InstallmentID INT PRIMARY KEY,
    LoanID INT,
    InstallmentNo INT,
    DueDate DATE,
    AmountDue DECIMAL(12,2),
    AmountPaid DECIMAL(12,2),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

CREATE TABLE Repayments (
    RepaymentID INT PRIMARY KEY,
    LoanID INT,
    RepaymentDate DATE,
    Amount DECIMAL(12,2),
    PaymentMode VARCHAR(30),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

CREATE TABLE LoanGuarantors (
    LoanID INT,
    GuarantorCustomerID INT,
    PRIMARY KEY (LoanID, GuarantorCustomerID),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID),
    FOREIGN KEY (GuarantorCustomerID) REFERENCES Customers(CustomerID)
);

-- ============================================================
-- 3. SAMPLE DATA INSERTION
-- ============================================================

INSERT INTO Branches VALUES
(1, 'Chennai Main Branch', 'Chennai'),
(2, 'Coimbatore Branch', 'Coimbatore'),
(3, 'Madurai Branch', 'Madurai'),
(4, 'Trichy Branch', 'Trichy'),
(5, 'Salem Branch', 'Salem');

INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'arun@gmail.com', 'Chennai'),
(2, 'Divya S', 'divya@gmail.com', 'Chennai'),
(3, 'Karthik Raj', 'karthik@gmail.com', 'Coimbatore'),
(4, 'Priya M', 'priya@gmail.com', 'Madurai'),
(5, 'Ravi Kumar', 'ravi@gmail.com', 'Trichy'),
(6, 'Meena S', 'meena@gmail.com', 'Salem');

INSERT INTO Loans VALUES
(101, 1, 1, 500000, 8.5, '2025-01-10', 'Active'),
(102, 2, 1, 800000, 9.0, '2025-02-15', 'Active'),
(103, 1, 2, 300000, 8.0, '2025-03-20', 'Active'),
(104, 3, 2, 600000, 9.5, '2025-04-12', 'Active'),
(105, 4, 3, 900000, 10.0, '2025-05-18', 'Active'),
(106, 5, 3, 200000, 7.5, '2025-06-22', 'Closed'),
(107, 2, 2, 400000, 8.5, '2025-07-10', 'Active');

INSERT INTO LoanInstallments VALUES
(1, 101, 1, '2026-01-05', 10000, 10000),
(2, 101, 2, '2026-02-05', 10000, 10000),
(3, 101, 3, '2026-03-05', 10000, 0),
(4, 101, 4, '2026-04-05', 10000, 0),
(5, 101, 5, '2026-05-05', 10000, 0),
(6, 101, 6, '2026-06-05', 10000, 0),
(7, 102, 1, '2026-10-05', 15000, 15000),
(8, 102, 2, '2026-11-05', 15000, 0),
(9, 103, 1, '2026-10-10', 8000, 8000),
(10, 104, 1, '2026-09-10', 12000, 12000),
(11, 105, 1, '2026-08-10', 18000, 0),
(12, 107, 1, '2026-10-15', 9000, 9000);

INSERT INTO Repayments VALUES
(1, 101, '2026-01-05', 10000, 'UPI'),
(2, 101, '2026-02-05', 10000, 'NEFT'),
(3, 102, '2026-10-05', 15000, 'UPI'),
(4, 103, '2026-10-10', 8000, 'NEFT'),
(5, 104, '2026-09-10', 12000, 'Cash'),
(6, 107, '2026-10-15', 9000, 'UPI');

INSERT INTO LoanGuarantors VALUES
(101, 2),
(102, 3),
(103, 4),
(104, 1),
(105, 2),
(107, 5);

-- ============================================================
-- 4. ADVANCED SQL REPORTS
-- ============================================================

-- QUERY 1: Display loans with customer and branch details.
-- Concept: Equi Join

SELECT
    L.LoanID,
    C.CustomerName,
    B.BranchName,
    L.LoanAmount,
    L.InterestRate,
    L.LoanStatus
FROM Loans L
INNER JOIN Customers C
    ON L.CustomerID = C.CustomerID
INNER JOIN Branches B
    ON L.BranchID = B.BranchID;

-- ============================================================

-- QUERY 2: Find loans overdue by more than three installments.
-- Concept: JOIN, GROUP BY and HAVING

SELECT
    L.LoanID,
    C.CustomerName,
    COUNT(I.InstallmentID) AS OverdueInstallments,
    SUM(I.AmountDue - I.AmountPaid) AS OutstandingAmount
FROM Loans L
INNER JOIN Customers C
    ON L.CustomerID = C.CustomerID
INNER JOIN LoanInstallments I
    ON L.LoanID = I.LoanID
WHERE I.DueDate < CAST(GETDATE() AS DATE)
  AND I.AmountPaid < I.AmountDue
GROUP BY L.LoanID, C.CustomerName
HAVING COUNT(I.InstallmentID) > 3;

-- ============================================================

-- QUERY 3: Find customers who have loans in more than one branch.
-- Concept: JOIN, GROUP BY and HAVING

SELECT
    C.CustomerID,
    C.CustomerName,
    COUNT(DISTINCT L.BranchID) AS NumberOfBranches
FROM Customers C
INNER JOIN Loans L
    ON C.CustomerID = L.CustomerID
GROUP BY C.CustomerID, C.CustomerName
HAVING COUNT(DISTINCT L.BranchID) > 1;

-- ============================================================

-- QUERY 4: Find guarantors who are also borrowers.
-- Concept: Self Join

SELECT DISTINCT
    G.CustomerID AS GuarantorID,
    G.CustomerName AS GuarantorName,
    B.CustomerID AS BorrowerID,
    B.CustomerName AS BorrowerName,
    L.LoanID
FROM LoanGuarantors LG
INNER JOIN Customers G
    ON LG.GuarantorCustomerID = G.CustomerID
INNER JOIN Loans L
    ON LG.LoanID = L.LoanID
INNER JOIN Customers B
    ON L.CustomerID = B.CustomerID
WHERE G.CustomerID = B.CustomerID;

-- ============================================================

-- QUERY 5: Find branches that do not have any loans.
-- Concept: LEFT JOIN and NOT EXISTS

SELECT
    B.BranchID,
    B.BranchName,
    B.City
FROM Branches B
LEFT JOIN Loans L
    ON B.BranchID = L.BranchID
WHERE L.LoanID IS NULL;

-- ============================================================

-- QUERY 6: Find customers whose total loan exposure
-- exceeds the average total loan exposure of all customers.
-- Concept: Uncorrelated Subquery

SELECT
    C.CustomerID,
    C.CustomerName,
    SUM(L.LoanAmount) AS TotalLoanExposure
FROM Customers C
INNER JOIN Loans L
    ON C.CustomerID = L.CustomerID
GROUP BY C.CustomerID, C.CustomerName
HAVING SUM(L.LoanAmount) >
(
    SELECT AVG(CustomerExposure)
    FROM
    (
        SELECT SUM(LoanAmount) AS CustomerExposure
        FROM Loans
        GROUP BY CustomerID
    ) AS CustomerTotals
);

-- ============================================================

-- QUERY 7: Find customers whose total loan exposure
-- exceeds their respective branch's average customer exposure.
-- Concept: Correlated Subquery

WITH CustomerExposure AS
(
    SELECT
        L.BranchID,
        L.CustomerID,
        SUM(L.LoanAmount) AS TotalExposure
    FROM Loans L
    GROUP BY L.BranchID, L.CustomerID
)
SELECT
    C.CustomerID,
    C.CustomerName,
    CE.BranchID,
    CE.TotalExposure
FROM CustomerExposure CE
INNER JOIN Customers C
    ON CE.CustomerID = C.CustomerID
WHERE CE.TotalExposure >
(
    SELECT AVG(CE2.TotalExposure)
    FROM CustomerExposure CE2
    WHERE CE2.BranchID = CE.BranchID
);

-- ============================================================

-- QUERY 8: Find customers who have a loan but no repayment
-- during the last 60 days.
-- Concept: EXISTS and NOT EXISTS

SELECT
    C.CustomerID,
    C.CustomerName
FROM Customers C
WHERE EXISTS
(
    SELECT 1
    FROM Loans L
    WHERE L.CustomerID = C.CustomerID
)
AND NOT EXISTS
(
    SELECT 1
    FROM Loans L
    INNER JOIN Repayments R
        ON L.LoanID = R.LoanID
    WHERE L.CustomerID = C.CustomerID
      AND R.RepaymentDate >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
      AND R.RepaymentDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
);

-- ============================================================

-- QUERY 9: Find branches whose highest loan amount is greater
-- than the bank-wide average of branch maximum loan amounts.
-- Concept: Nested Subquery

SELECT
    B.BranchID,
    B.BranchName,
    MAX(L.LoanAmount) AS HighestLoanAmount
FROM Branches B
INNER JOIN Loans L
    ON B.BranchID = L.BranchID
GROUP BY B.BranchID, B.BranchName
HAVING MAX(L.LoanAmount) >
(
    SELECT AVG(BranchMaximum)
    FROM
    (
        SELECT MAX(LoanAmount) AS BranchMaximum
        FROM Loans
        GROUP BY BranchID
    ) AS BranchMaximums
);

-- ============================================================

-- QUERY 10: Find loans whose loan amount is greater than
-- ANY loan amount in Branch 1 and loans whose amount is
-- greater than ALL loan amounts in Branch 1.
-- Concept: ANY and ALL

-- Greater than ANY
SELECT
    LoanID,
    LoanAmount,
    BranchID
FROM Loans
WHERE LoanAmount > ANY
(
    SELECT LoanAmount
    FROM Loans
    WHERE BranchID = 1
);

-- Greater than ALL
SELECT
    LoanID,
    LoanAmount,
    BranchID
FROM Loans
WHERE LoanAmount > ALL
(
    SELECT LoanAmount
    FROM Loans
    WHERE BranchID = 1
);

-- ============================================================
-- END OF DAY 7 - SET 2
-- ============================================================
