
-- =============================================
-- DAY 10 - SET 3
-- TEST EVIDENCE
-- File: test_evidence.sql
-- =============================================

USE HospitalDB;
GO

-- =============================================
-- 1. RESET TEST DATA
-- =============================================

DELETE FROM dbo.admission_audit;
DELETE FROM dbo.admissions;
DELETE FROM dbo.wards;
GO

-- =============================================
-- 2. INSERT SAMPLE WARDS
-- =============================================

INSERT INTO dbo.wards
(
    ward_id,
    ward_name,
    capacity,
    occupied_beds
)
VALUES
(1, 'General Ward', 3, 0),
(2, 'ICU Ward', 2, 0),
(3, 'Emergency Ward', 4, 0);
GO

SELECT * FROM dbo.wards;
GO

-- =============================================
-- 3. INSERT INITIAL ADMISSIONS
-- =============================================

INSERT INTO dbo.admissions
(
    admission_id,
    patient_name,
    ward_id
)
VALUES
(101, 'Arun', 1),
(102, 'Bala', 1);
GO

PRINT 'Initial admissions completed.';
GO

SELECT * FROM dbo.admissions;
SELECT * FROM dbo.wards;
GO

-- =============================================
-- 4. TEST SINGLE-ROW INSERT
-- =============================================

INSERT INTO dbo.admissions
(
    admission_id,
    patient_name,
    ward_id
)
VALUES
(103, 'Charan', 1);
GO

PRINT 'Single-row admission successful.';
GO

SELECT * FROM dbo.wards;
GO

-- =============================================
-- 5. TEST MULTI-ROW INSERT
-- Ward 1 has capacity 3 and is already full.
-- One row requests admission to the full ward.
-- The entire batch must be rejected.
-- =============================================

BEGIN TRY

    INSERT INTO dbo.admissions
    (
        admission_id,
        patient_name,
        ward_id
    )
    VALUES
    (104, 'Divya', 1),
    (105, 'Ezhil', 2),
    (106, 'Farhan', 2);

    PRINT 'Multi-row admission completed.';

END TRY
BEGIN CATCH

    PRINT 'MULTI-ROW ADMISSION REJECTED';
    PRINT ERROR_MESSAGE();

END CATCH;
GO

-- =============================================
-- 6. VERIFY REJECTED BATCH
-- =============================================

SELECT *
FROM dbo.admissions
ORDER BY admission_id;
GO

SELECT *
FROM dbo.wards
ORDER BY ward_id;
GO

-- Expected:
-- No records 104, 105 or 106.
-- ICU occupied beds must remain 0.
-- General Ward occupied beds must remain 3.

-- =============================================
-- 7. TEST SUCCESSFUL MULTI-ROW INSERT
-- ICU has capacity 2.
-- Both admissions should succeed.
-- =============================================

INSERT INTO dbo.admissions
(
    admission_id,
    patient_name,
    ward_id
)
VALUES
(107, 'Gokul', 2),
(108, 'Harish', 2);
GO

PRINT 'Successful ICU admissions completed.';
GO

SELECT * FROM dbo.wards;
GO

-- =============================================
-- 8. TEST ADMISSION UPDATE
-- Change patient name.
-- =============================================

UPDATE dbo.admissions
SET patient_name = 'Gokul Kumar'
WHERE admission_id = 107;
GO

PRINT 'Admission UPDATE completed.';
GO

-- =============================================
-- 9. TEST ADMISSION DELETE
-- =============================================

DELETE FROM dbo.admissions
WHERE admission_id = 108;
GO

PRINT 'Admission DELETE completed.';
GO

-- =============================================
-- 10. VERIFY OCCUPIED BED COUNTS
-- =============================================

SELECT
    ward_id,
    ward_name,
    capacity,
    occupied_beds,
    capacity - occupied_beds AS available_beds
FROM dbo.wards
ORDER BY ward_id;
GO

-- =============================================
-- 11. VERIFY ADMISSION AUDIT
-- =============================================

SELECT
    audit_id,
    admission_id,
    action_type,
    old_patient_name,
    new_patient_name,
    old_ward_id,
    new_ward_id,
    changed_by,
    changed_at
FROM dbo.admission_audit
ORDER BY audit_id;
GO

PRINT 'All Set 3 tests completed.';
GO
