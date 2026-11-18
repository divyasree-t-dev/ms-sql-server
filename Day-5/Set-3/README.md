# Set 3 – Hospital Patient Records and Clinical Notes

## Business Scenario
A hospital maintains patient visits, doctor details, department information, billing records and clinical notes. The objective is to organize the data using database normalization and generate reports using SQL Server and MongoDB.

## Technologies Used
- Microsoft SQL Server
- MongoDB
- MongoDB Compass / Mongosh

## Tasks Completed

### 1. Database Normalization
- Normalized the original wide table into 3NF.
- Created five tables: Patient, Doctor, Department, Visit and Billing.
- Defined primary keys and foreign key relationships.

### 2. SQL Server Implementation
- Created HospitalDB database and tables.
- Added primary key and foreign key constraints.
- Added CHECK constraints for visit dates and bill amounts.
- Set the default billing status to 'Open'.

### 3. ALTER TABLE Operations
- Added `insurance_id` column to Patient.
- Renamed Doctor table to HospitalDoctor.
- Dropped the bill amount CHECK constraint.

### 4. SQL Operations and Queries
- Performed INSERT, UPDATE and DELETE operations.
- Retrieved patients who visited during November 2026.
- Retrieved doctors belonging to the Cardiology department using WHERE and LIKE.

### 5. MongoDB Implementation
- Created the `clinical_notes` collection with JSON Schema validation.
- Inserted two clinical note documents with different structures.
- Retrieved clinical notes based on diagnosis.

## Deliverables

| File | Description |
|---|---|
| schema.sql | Database, tables, constraints and ALTER operations |
| seed_data.sql | Sample data and SQL queries |
| MongoDB_Clinical_Notes.docx | MongoDB commands, explanations and screenshots |
| ER_Diagram.png | Database relationship diagram and assumptions |

## Assumptions
1. A patient can have multiple visits.
2. Each doctor belongs to one department.
3. Each visit generates at most one billing record.

## Conclusion
This assignment demonstrates database normalization, relational database implementation, SQL operations, constraints and MongoDB document storage for hospital patient records and clinical notes.
