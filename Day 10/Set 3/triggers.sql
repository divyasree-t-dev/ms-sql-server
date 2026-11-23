
-- =============================================
-- DAY 10 - SET 3
-- HOSPITAL BED CAPACITY CONTROL
-- File: triggers.sql
-- SQL Server 2025
-- =============================================

-- 1. CREATE DATABASE
IF DB_ID('HospitalDB') IS NULL
    CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

-- =============================================
-- 2. DROP EXISTING OBJECTS
-- =============================================

DROP TRIGGER IF EXISTS dbo.trg_Admission_Capacity;
DROP TRIGGER IF EXISTS dbo.trg_Admission_Audit;
GO

DROP TABLE IF EXISTS dbo.admission_audit;
DROP TABLE IF EXISTS dbo.admissions;
DROP TABLE IF EXISTS dbo.wards;
GO

-- =============================================
-- 3. CREATE WARDS TABLE
-- =============================================

CREATE TABLE dbo.wards
(
    ward_id INT PRIMARY KEY,
    ward_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    occupied_beds INT NOT NULL DEFAULT 0,

    CONSTRAINT CK_Ward_Capacity
        CHECK (capacity > 0),

    CONSTRAINT CK_Ward_Occupied
        CHECK (
            occupied_beds >= 0
            AND occupied_beds <= capacity
        )
);
GO

-- =============================================
-- 4. CREATE ADMISSIONS TABLE
-- =============================================

CREATE TABLE dbo.admissions
(
    admission_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    ward_id INT NOT NULL,
    admission_date DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Admission_Ward
        FOREIGN KEY (ward_id)
        REFERENCES dbo.wards(ward_id)
);
GO

-- =============================================
-- 5. CREATE ADMISSION AUDIT TABLE
-- =============================================

CREATE TABLE dbo.admission_audit
(
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    admission_id INT NOT NULL,
    action_type VARCHAR(10) NOT NULL,
    old_patient_name VARCHAR(100) NULL,
    new_patient_name VARCHAR(100) NULL,
    old_ward_id INT NULL,
    new_ward_id INT NULL,
    changed_by SYSNAME NOT NULL,
    changed_at DATETIME2 NOT NULL
);
GO

-- =============================================
-- 6. CAPACITY VALIDATION TRIGGER
-- Blocks admission when capacity is exceeded
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_Admission_Capacity
ON dbo.admissions
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Lock ward records during validation
    IF EXISTS
    (
        SELECT 1
        FROM dbo.wards w WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN
        (
            SELECT
                ward_id,
                COUNT(*) AS requested_beds
            FROM inserted
            GROUP BY ward_id
        ) i
            ON w.ward_id = i.ward_id
        WHERE
            w.occupied_beds + i.requested_beds > w.capacity
    )
    BEGIN
        THROW 51010,
            'Admission rejected: Ward has insufficient bed capacity.',
            1;
    END;

    -- Insert admissions only when capacity is available
    INSERT INTO dbo.admissions
    (
        admission_id,
        patient_name,
        ward_id,
        admission_date
    )
    SELECT
        admission_id,
        patient_name,
        ward_id,
        admission_date
    FROM inserted;

    -- Update occupied bed count
    UPDATE w
    SET occupied_beds = occupied_beds + i.requested_beds
    FROM dbo.wards w
    INNER JOIN
    (
        SELECT
            ward_id,
            COUNT(*) AS requested_beds
        FROM inserted
        GROUP BY ward_id
    ) i
        ON w.ward_id = i.ward_id;

END;
GO

-- =============================================
-- 7. AFTER INSERT / UPDATE / DELETE AUDIT TRIGGER
-- Also maintains bed occupancy for UPDATE/DELETE
-- =============================================

CREATE OR ALTER TRIGGER dbo.trg_Admission_Audit
ON dbo.admissions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Changes TABLE
    (
        ward_id INT PRIMARY KEY,
        bed_change INT
    );

    -- INSERT occupancy is already maintained
    -- by the INSTEAD OF INSERT trigger.
    -- For UPDATE and DELETE, calculate net changes.

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO @Changes(ward_id, bed_change)
        SELECT
            ward_id,
            SUM(bed_change)
        FROM
        (
            SELECT
                ward_id,
                COUNT(*) AS bed_change
            FROM inserted
            GROUP BY ward_id

            UNION ALL

            SELECT
                ward_id,
                -COUNT(*) AS bed_change
            FROM deleted
            GROUP BY ward_id
        ) AS Changes
        GROUP BY ward_id
        HAVING SUM(bed_change) <> 0;

        -- Prevent moving admissions into a full ward
        IF EXISTS
        (
            SELECT 1
            FROM dbo.wards w
            INNER JOIN @Changes c
                ON w.ward_id = c.ward_id
            WHERE c.bed_change > 0
              AND w.occupied_beds + c.bed_change > w.capacity
        )
        BEGIN
            THROW 51011,
                'Admission update rejected: Insufficient ward capacity.',
                1;
        END;

        -- Maintain occupied bed counts
        UPDATE w
        SET w.occupied_beds =
            w.occupied_beds + c.bed_change
        FROM dbo.wards w
        INNER JOIN @Changes c
            ON w.ward_id = c.ward_id;
    END;

    -- Record every admission operation
    INSERT INTO dbo.admission_audit
    (
        admission_id,
        action_type,
        old_patient_name,
        new_patient_name,
        old_ward_id,
        new_ward_id,
        changed_by,
        changed_at
    )
    SELECT
        COALESCE(i.admission_id, d.admission_id),

        CASE
            WHEN d.admission_id IS NULL THEN 'INSERT'
            WHEN i.admission_id IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,

        d.patient_name,
        i.patient_name,
        d.ward_id,
        i.ward_id,
        SUSER_SNAME(),
        SYSDATETIME()

    FROM inserted i
    FULL OUTER JOIN deleted d
        ON i.admission_id = d.admission_id;
END;
GO

PRINT 'Set 3 triggers created successfully.';
GO
