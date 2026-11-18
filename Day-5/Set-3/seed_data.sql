
-- Set 3: Hospital Patient Records and Clinical Notes
-- File: seed_data.sql

USE HospitalDB;
GO

-- 1. Insert Department Records
INSERT INTO Department VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Orthopedics');

-- 2. Insert Doctor Records
INSERT INTO HospitalDoctor VALUES
(101, 'Dr. Arun', 1),
(102, 'Dr. Priya', 2),
(103, 'Dr. Karthik', 1),
(104, 'Dr. Meena', 3);

-- 3. Insert Patient Records
INSERT INTO Patient
(patient_id, patient_name, address, insurance_id)
VALUES
(201, 'Ravi', 'Chennai', 'INS1001'),
(202, 'Priya', 'Tambaram', 'INS1002'),
(203, 'Kumar', 'Vellore', 'INS1003'),
(204, 'Anitha', 'Chengalpattu', 'INS1004'),
(205, 'Suresh', 'Kanchipuram', 'INS1005');

-- 4. Insert Visit Records
INSERT INTO Visit VALUES
(301, 201, 101, '2026-11-05',
 'Heart Pain', 'ECG Test', 'Regular checkup'),

(302, 202, 102, '2026-11-10',
 'Headache', 'Medication', 'Follow-up required'),

(303, 203, 103, '2026-10-15',
 'Chest Pain', 'Blood Test', 'Observation'),

(304, 204, 104, '2026-11-12',
 'Bone Pain', 'X-Ray', 'Rest advised'),

(305, 205, 101, '2026-09-20',
 'Heart Disease', 'ECG Test', 'Regular monitoring');

-- 5. Insert Billing Records
INSERT INTO Billing
(bill_id, visit_id, bill_amount)
VALUES
(401, 301, 2500),
(402, 302, 1500),
(403, 303, 3000),
(404, 304, 2000),
(405, 305, 1800);
GO

-- 6. Update Patient Details
UPDATE Patient
SET address = 'Coimbatore'
WHERE patient_id = 203;

-- 7. Delete Patient Record
INSERT INTO Patient
(patient_id, patient_name, address, insurance_id)
VALUES
(206, 'Divya', 'Chennai', 'INS1006');

DELETE FROM Patient
WHERE patient_id = 206;

-- 8. Retrieve Patients Visited in November 2026
SELECT P.patient_id, P.patient_name, V.visit_date
FROM Patient P
JOIN Visit V
ON P.patient_id = V.patient_id
WHERE V.visit_date >= '2026-11-01'
AND V.visit_date < '2026-12-01';

-- 9. Retrieve Doctors in Cardiology Department
SELECT D.doctor_id, D.doctor_name,
       Dept.department_name
FROM HospitalDoctor D
JOIN Department Dept
ON D.department_id = Dept.department_id
WHERE Dept.department_name LIKE '%Cardio%';

-- 10. Display All Records
SELECT * FROM Department;
SELECT * FROM HospitalDoctor;
SELECT * FROM Patient;
SELECT * FROM Visit;
SELECT * FROM Billing;
GO
