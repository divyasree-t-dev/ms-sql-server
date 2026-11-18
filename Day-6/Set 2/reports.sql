
/* =========================================================
   SET 2 – INSURANCE POLICY REPORTING
   Database: InsuranceDB
   Platform: SQL Server
   ========================================================= */

IF DB_ID('InsuranceDB') IS NULL
    CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

/* 1. CREATE TABLES */

IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE Customers (
        customer_id INT PRIMARY KEY,
        customer_name VARCHAR(100),
        date_of_birth DATE
    );
END;
GO

IF OBJECT_ID('dbo.Agents', 'U') IS NULL
BEGIN
    CREATE TABLE Agents (
        agent_id INT PRIMARY KEY,
        agent_name VARCHAR(100)
    );
END;
GO

IF OBJECT_ID('dbo.Policies', 'U') IS NULL
BEGIN
    CREATE TABLE Policies (
        policy_id INT PRIMARY KEY,
        policy_number VARCHAR(30) UNIQUE,
        customer_id INT,
        agent_id INT,
        product_name VARCHAR(50),
        start_date DATE,
        end_date DATE,
        status VARCHAR(20)
    );
END;
GO

IF OBJECT_ID('dbo.Premiums', 'U') IS NULL
BEGIN
    CREATE TABLE Premiums (
        premium_id INT PRIMARY KEY,
        policy_id INT,
        payment_date DATE,
        premium_amount DECIMAL(12,2)
    );
END;
GO

IF OBJECT_ID('dbo.Claims', 'U') IS NULL
BEGIN
    CREATE TABLE Claims (
        claim_id INT PRIMARY KEY,
        policy_id INT,
        claim_date DATE,
        claim_amount DECIMAL(12,2),
        claim_status VARCHAR(30)
    );
END;
GO

/* 2. INSERT SAMPLE DATA */

IF NOT EXISTS (SELECT 1 FROM Customers)
BEGIN
    INSERT INTO Customers VALUES
    (1, 'Arun Kumar', '1988-04-12'),
    (2, 'Priya Devi', '1995-08-21'),
    (3, 'Karthik Raj', '1978-02-15'),
    (4, 'Meena Lakshmi', '2001-11-09'),
    (5, 'Suresh Babu', '1969-06-30'),
    (6, 'Nila Rani', '1990-01-17'),
    (7, 'Vijay Anand', '1982-09-25'),
    (8, 'Divya Sri', '1999-12-05');
END;
GO

IF NOT EXISTS (SELECT 1 FROM Agents)
BEGIN
    INSERT INTO Agents VALUES
    (1, 'Ramesh'),
    (2, 'Anitha'),
    (3, 'Balaji'),
    (4, 'Kavitha'),
    (5, 'Manoj'),
    (6, 'Sandhya');
END;
GO

IF NOT EXISTS (SELECT 1 FROM Policies)
BEGIN
    INSERT INTO Policies VALUES
    (101, 'POL20260001', 1, 1, 'Health',
     DATEADD(DAY,-300,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,10,CAST(GETDATE() AS DATE)), 'Active'),

    (102, 'POL20260002', 1, 2, 'Life',
     DATEADD(DAY,-500,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,200,CAST(GETDATE() AS DATE)), 'Active'),

    (103, 'POL20260003', 2, 1, 'Vehicle',
     DATEADD(DAY,-200,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,20,CAST(GETDATE() AS DATE)), 'Active'),

    (104, 'POL20260004', 3, 3, 'Health',
     DATEADD(DAY,-700,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,300,CAST(GETDATE() AS DATE)), 'Active'),

    (105, 'POL20260005', 4, 4, 'Property',
     DATEADD(DAY,-100,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,5,CAST(GETDATE() AS DATE)), 'Active'),

    (106, 'POL20260006', 5, 2, 'Life',
     DATEADD(DAY,-900,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,100,CAST(GETDATE() AS DATE)), 'Active'),

    (107, 'POL20260007', 6, 5, 'Vehicle',
     DATEADD(DAY,-60,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,305,CAST(GETDATE() AS DATE)), 'Active'),

    (108, 'POL20260008', 7, 6, 'Health',
     DATEADD(DAY,-400,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,15,CAST(GETDATE() AS DATE)), 'Active'),

    (109, 'POL20260009', 8, 3, 'Property',
     DATEADD(DAY,-30,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,335,CAST(GETDATE() AS DATE)), 'Active'),

    (110, 'POL20260010', 2, 4, 'Life',
     DATEADD(DAY,-800,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,-10,CAST(GETDATE() AS DATE)), 'Expired'),

    (111, 'POL20260011', 3, 5, 'Vehicle',
     DATEADD(DAY,-150,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,215,CAST(GETDATE() AS DATE)), 'Active'),

    (112, 'POL20260012', 6, 1, 'Health',
     DATEADD(DAY,-15,CAST(GETDATE() AS DATE)),
     DATEADD(DAY,350,CAST(GETDATE() AS DATE)), 'Active');
END;
GO

IF NOT EXISTS (SELECT 1 FROM Premiums)
BEGIN
    INSERT INTO Premiums VALUES
    (1,101,DATEADD(DAY,-30,GETDATE()),12000),
    (2,102,DATEADD(DAY,-25,GETDATE()),18000),
    (3,103,DATEADD(DAY,-20,GETDATE()),9000),
    (4,104,DATEADD(DAY,-18,GETDATE()),15000),
    (5,105,DATEADD(DAY,-15,GETDATE()),11000),
    (6,106,DATEADD(DAY,-12,GETDATE()),20000),
    (7,107,DATEADD(DAY,-10,GETDATE()),8500),
    (8,108,DATEADD(DAY,-8,GETDATE()),13000),
    (9,109,DATEADD(DAY,-6,GETDATE()),16000),
    (10,110,DATEADD(DAY,-4,GETDATE()),17500),
    (11,111,DATEADD(DAY,-2,GETDATE()),9500),
    (12,112,GETDATE(),14000),
    (13,101,DATEADD(DAY,-60,GETDATE()),12000),
    (14,103,DATEADD(DAY,-50,GETDATE()),9000),
    (15,106,DATEADD(DAY,-45,GETDATE()),20000);
END;
GO

IF NOT EXISTS (SELECT 1 FROM Claims)
BEGIN
    INSERT INTO Claims VALUES
    (201,101,DATEADD(DAY,-20,GETDATE()),4000,'Settled'),
    (202,103,DATEADD(DAY,-18,GETDATE()),2500,'Under Review'),
    (203,104,DATEADD(DAY,-15,GETDATE()),6000,'Settled'),
    (204,105,DATEADD(DAY,-12,GETDATE()),3000,'Pending'),
    (205,107,DATEADD(DAY,-8,GETDATE()),1500,'Settled'),
    (206,108,DATEADD(DAY,-5,GETDATE()),2000,'Under Review'),
    (207,111,DATEADD(DAY,-3,GETDATE()),1000,'Pending');
END;
GO

/* =========================================================
   TASK 1 – EIGHT REPORTING QUERIES
   ========================================================= */

/* QUERY 1: Policies expiring in the next 30 days */

SELECT
    p.policy_id,
    CONCAT(
        REPLICATE('*', LEN(p.policy_number) - 4),
        RIGHT(p.policy_number, 4)
    ) AS masked_policy_number,
    c.customer_name,
    p.product_name,
    p.end_date
FROM Policies p
INNER JOIN Customers c
    ON p.customer_id = c.customer_id
WHERE p.status = 'Active'
  AND p.end_date >= CAST(GETDATE() AS DATE)
  AND p.end_date <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY p.end_date;
GO

/* QUERY 2: Premium collected per product */

SELECT
    p.product_name,
    SUM(pr.premium_amount) AS total_premium_collected
FROM Policies p
INNER JOIN Premiums pr
    ON p.policy_id = pr.policy_id
GROUP BY p.product_name
ORDER BY total_premium_collected DESC;
GO

/* QUERY 3: Customers with more than one active policy */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(p.policy_id) AS active_policy_count
FROM Customers c
INNER JOIN Policies p
    ON c.customer_id = p.customer_id
WHERE p.status = 'Active'
  AND p.end_date >= CAST(GETDATE() AS DATE)
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.policy_id) > 1
ORDER BY active_policy_count DESC;
GO

/* QUERY 4: Claim ratio per product */

WITH PremiumTotals AS (
    SELECT
        p.product_name,
        SUM(pr.premium_amount) AS total_premium
    FROM Policies p
    INNER JOIN Premiums pr
        ON p.policy_id = pr.policy_id
    GROUP BY p.product_name
),
ClaimTotals AS (
    SELECT
        p.product_name,
        SUM(c.claim_amount) AS total_claim_amount
    FROM Policies p
    INNER JOIN Claims c
        ON p.policy_id = c.policy_id
    GROUP BY p.product_name
)
SELECT
    pt.product_name,
    COALESCE(ct.total_claim_amount, 0) AS total_claim_amount,
    pt.total_premium AS total_premium_collected,
    CAST(
        COALESCE(ct.total_claim_amount, 0) * 100.0 /
        NULLIF(pt.total_premium, 0)
        AS DECIMAL(10,2)
    ) AS claim_ratio_percent
FROM PremiumTotals pt
LEFT JOIN ClaimTotals ct
    ON pt.product_name = ct.product_name
ORDER BY claim_ratio_percent DESC;
GO

/* QUERY 5: Policies without claims */

SELECT
    p.policy_id,
    p.policy_number,
    c.customer_name,
    p.product_name
FROM Policies p
INNER JOIN Customers c
    ON p.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Claims cl
    WHERE cl.policy_id = p.policy_id
)
ORDER BY p.policy_id;
GO

/* QUERY 6: Average premium by customer age band */

SELECT
    CASE
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) < 25
            THEN 'Below 25'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 25 AND 34
            THEN '25-34'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 35 AND 44
            THEN '35-44'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 45 AND 59
            THEN '45-59'
        ELSE '60 and above'
    END AS age_band,
    CAST(AVG(pr.premium_amount) AS DECIMAL(12,2))
        AS average_premium
FROM Customers c
INNER JOIN Policies p
    ON c.customer_id = p.customer_id
INNER JOIN Premiums pr
    ON p.policy_id = pr.policy_id
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) < 25
            THEN 'Below 25'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 25 AND 34
            THEN '25-34'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 35 AND 44
            THEN '35-44'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE()) BETWEEN 45 AND 59
            THEN '45-59'
        ELSE '60 and above'
    END
ORDER BY age_band;
GO

/* QUERY 7: Monthly new policies */

SELECT
    YEAR(start_date) AS policy_year,
    MONTH(start_date) AS policy_month,
    COUNT(*) AS new_policy_count
FROM Policies
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY policy_year, policy_month;
GO

/* QUERY 8: Top five agents by premium collected */

SELECT TOP 5
    a.agent_id,
    a.agent_name,
    SUM(pr.premium_amount) AS total_premium
FROM Agents a
INNER JOIN Policies p
    ON a.agent_id = p.agent_id
INNER JOIN Premiums pr
    ON p.policy_id = pr.policy_id
GROUP BY a.agent_id, a.agent_name
ORDER BY total_premium DESC;
GO

/* EXTRA: Policy age bands using DATEDIFF and CASE */

SELECT
    policy_id,
    policy_number,
    DATEDIFF(YEAR, start_date, GETDATE()) AS policy_age_years,
    CASE
        WHEN DATEDIFF(YEAR, start_date, GETDATE()) < 1
            THEN 'Less than 1 year'
        WHEN DATEDIFF(YEAR, start_date, GETDATE()) BETWEEN 1 AND 3
            THEN '1-3 years'
        WHEN DATEDIFF(YEAR, start_date, GETDATE()) BETWEEN 4 AND 5
            THEN '4-5 years'
        ELSE 'More than 5 years'
    END AS policy_age_band
FROM Policies
ORDER BY policy_id;
GO

/* END OF REPORTS */
