CREATE DATABASE BankBranchDB;
GO

USE BankBranchDB;
GO

USE BankBranchDB;
GO

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(250)
);
GO

CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    BranchCode VARCHAR(20) NOT NULL UNIQUE,
    Location VARCHAR(100) NOT NULL
);
GO

CREATE TABLE RelationshipManager (
    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
    ManagerName VARCHAR(100) NOT NULL,
    EmployeeCode VARCHAR(20) NOT NULL UNIQUE,
    BranchID INT NOT NULL,

    CONSTRAINT FK_Manager_Branch
    FOREIGN KEY (BranchID)
    REFERENCES Branch(BranchID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);
GO

CREATE TABLE AccountType (
    AccountTypeID INT IDENTITY(1,1) PRIMARY KEY,
    AccountTypeName VARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    AccountTypeID INT NOT NULL,
    BranchID INT NOT NULL,
    ManagerID INT NOT NULL,
    Balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    OpenDate DATE NOT NULL,

    CONSTRAINT FK_Account_Customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customer(CustomerID)
    ON DELETE NO ACTION,

    CONSTRAINT FK_Account_AccountType
    FOREIGN KEY (AccountTypeID)
    REFERENCES AccountType(AccountTypeID)
    ON DELETE NO ACTION,

    CONSTRAINT FK_Account_Branch
    FOREIGN KEY (BranchID)
    REFERENCES Branch(BranchID)
    ON DELETE NO ACTION,

    CONSTRAINT FK_Account_Manager
    FOREIGN KEY (ManagerID)
    REFERENCES RelationshipManager(ManagerID)
    ON DELETE NO ACTION,

    CONSTRAINT CK_Savings_Balance
    CHECK (
        Balance >= 0 OR AccountTypeID <> 1
    )
);
GO

CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionReference VARCHAR(30) NOT NULL,
    TransactionDate DATETIME NOT NULL,
    Description VARCHAR(200),
    Amount DECIMAL(12,2) NOT NULL,

    CONSTRAINT UQ_Account_Transaction
    UNIQUE (AccountID, TransactionReference),

    CONSTRAINT FK_Transactions_Account
    FOREIGN KEY (AccountID)
    REFERENCES Account(AccountID)
    ON DELETE CASCADE
);
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

