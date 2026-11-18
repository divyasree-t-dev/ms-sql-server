
-- Set 3: Hospital Patient Records and Clinical Notes
-- File: schema.sql

-- Create Database
IF DB_ID('HospitalDB') IS NULL
    CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

-- 1. Department Table
CREATE TABLE Department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- 2. Doctor Table
CREATE TABLE Doctor (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT FK_Doctor_Department
        FOREIGN KEY (department_id)
        REFERENCES Department(department_id)
);

-- 3. Patient Table
CREATE TABLE Patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    address VARCHAR(200)
);

-- 4. Visit Table
CREATE TABLE Visit (
    visit_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    diagnosis VARCHAR(200),
    prescription VARCHAR(200),
    notes VARCHAR(500),

    CONSTRAINT FK_Visit_Patient
        FOREIGN KEY (patient_id)
        REFERENCES Patient(patient_id),

    CONSTRAINT FK_Visit_Doctor
        FOREIGN KEY (doctor_id)
        REFERENCES Doctor(doctor_id),

    CONSTRAINT CHK_Visit_Date
        CHECK (visit_date <= CAST(GETDATE() AS DATE))
);

-- 5. Billing Table
CREATE TABLE Billing (
    bill_id INT PRIMARY KEY,
    visit_id INT NOT NULL UNIQUE,
    bill_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Open',

    CONSTRAINT FK_Billing_Visit
        FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id),

    CONSTRAINT CHK_Bill_Amount
        CHECK (bill_amount >= 0)
);
GO

-- ALTER TABLE Operations

-- Add insurance_id column
ALTER TABLE Patient
ADD insurance_id VARCHAR(30);
GO

-- Rename Doctor table
EXEC sp_rename 'Doctor', 'HospitalDoctor';
GO

-- Drop bill amount constraint
ALTER TABLE Billing
DROP CONSTRAINT CHK_Bill_Amount;
GO
