
-- =====================================================
-- SET 3: TELECOM USAGE AND BILLING REPORTING
-- Database: TelecomDB
-- =====================================================

CREATE DATABASE TelescomDB;
GO

USE TelecomDB;
GO

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    data_limit_gb DECIMAL(10,2),
    monthly_charge DECIMAL(10,2)
);

CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    subscriber_name VARCHAR(100),
    circle VARCHAR(50),
    plan_id INT,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE call_records (
    call_id INT PRIMARY KEY,
    subscriber_id INT,
    call_date DATETIME,
    call_minutes DECIMAL(10,2),
    data_used_gb DECIMAL(10,2),
    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id)
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    subscriber_id INT,
    invoice_date DATE,
    due_date DATE,
    amount DECIMAL(10,2),
    payment_date DATE NULL,
    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id)
);

-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

INSERT INTO plans VALUES
(1, 'Basic', 2.00, 199),
(2, 'Standard', 5.00, 399),
(3, 'Premium', 10.00, 599),
(4, 'Unlimited', 50.00, 999);

INSERT INTO subscribers VALUES
(101, 'Arun', 'Chennai', 1),
(102, 'Bala', 'Chennai', 2),
(103, 'Charan', 'Coimbatore', 3),
(104, 'Divya', 'Madurai', 2),
(105, 'Ezhil', 'Chennai', 4),
(106, 'Farah', 'Coimbatore', 1),
(107, 'Gokul', 'Madurai', 3),
(108, 'Hari', 'Chennai', 2),
(109, 'Indhu', 'Salem', 1),
(110, 'Jeeva', 'Salem', 4);

INSERT INTO call_records VALUES
(1, 101, '2026-10-01 09:00', 30, 1.5),
(2, 101, '2026-10-05 10:00', 20, 1.0),
(3, 102, '2026-10-02 11:00', 45, 3.0),
(4, 102, '2026-11-01 12:00', 60, 3.5),
(5, 103, '2026-10-03 13:00', 80, 12.0),
(6, 103, '2026-11-02 14:00', 40, 5.0),
(7, 104, '2026-10-04 15:00', 25, 2.0),
(8, 105, '2026-10-05 16:00', 100, 20.0),
(9, 105, '2026-11-03 17:00', 90, 18.0),
(10, 106, '2026-10-06 18:00', 15, 0.5),
(11, 107, '2026-10-07 19:00', 50, 8.0),
(12, 108, '2026-11-04 20:00', 35, 4.0),
(13, 109, '2026-10-08 21:00', 10, 0.5);

INSERT INTO invoices VALUES
(1001, 101, '2026-10-01', '2026-10-15', 199, '2026-10-10'),
(1002, 102, '2026-10-01', '2026-10-15', 399, NULL),
(1003, 103, '2026-10-01', '2026-10-15', 599, '2026-10-12'),
(1004, 104, '2026-10-01', '2026-10-15', 399, NULL),
(1005, 105, '2026-11-01', '2026-11-15', 999, NULL),
(1006, 106, '2026-10-01', '2026-10-15', 199, '2026-10-14'),
(1007, 107, '2026-11-01', '2026-11-15', 599, NULL),
(1008, 108, '2026-11-01', '2026-11-15', 399, NULL),
(1009, 109, '2026-10-01', '2026-10-15', 199, NULL),
(1010, 110, '2026-11-01', '2026-11-15', 999, NULL);

-- =====================================================
-- 3. EIGHT REPORTING QUERIES
-- =====================================================

-- QUERY 1: Total call minutes per plan

SELECT
    p.plan_name,
    SUM(c.call_minutes) AS total_call_minutes
FROM plans p
JOIN subscribers s ON p.plan_id = s.plan_id
JOIN call_records c ON s.subscriber_id = c.subscriber_id
GROUP BY p.plan_name
ORDER BY total_call_minutes DESC;


-- QUERY 2: Subscribers exceeding their data limit

SELECT
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name,
    p.data_limit_gb,
    SUM(c.data_used_gb) AS total_data_used
FROM subscribers s
JOIN plans p ON s.plan_id = p.plan_id
JOIN call_records c ON s.subscriber_id = c.subscriber_id
GROUP BY
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name,
    p.data_limit_gb
HAVING SUM(c.data_used_gb) > p.data_limit_gb;


-- QUERY 3: Month-wise revenue

SELECT
    YEAR(invoice_date) AS invoice_year,
    MONTH(invoice_date) AS invoice_month,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY invoice_year, invoice_month;


-- QUERY 4: Invoices overdue by more than 15 days

SELECT
    invoice_id,
    subscriber_id,
    due_date,
    amount,
    DATEDIFF(DAY, due_date, CAST(GETDATE() AS DATE))
        AS overdue_days
FROM invoices
WHERE payment_date IS NULL
AND DATEDIFF(DAY, due_date, CAST(GETDATE() AS DATE)) > 15;


-- QUERY 5: Subscribers with no usage

SELECT
    s.subscriber_id,
    s.subscriber_name
FROM subscribers s
LEFT JOIN call_records c
    ON s.subscriber_id = c.subscriber_id
WHERE c.call_id IS NULL;


-- QUERY 6: Average revenue per user (ARPU) by circle

SELECT
    s.circle,
    COUNT(DISTINCT s.subscriber_id) AS total_subscribers,
    SUM(i.amount) AS total_revenue,
    CAST(SUM(i.amount) * 1.0 /
        NULLIF(COUNT(DISTINCT s.subscriber_id), 0)
        AS DECIMAL(10,2)) AS ARPU
FROM subscribers s
JOIN invoices i
    ON s.subscriber_id = i.subscriber_id
GROUP BY s.circle;


-- QUERY 7: Plan popularity

SELECT
    p.plan_name,
    COUNT(s.subscriber_id) AS subscriber_count
FROM plans p
LEFT JOIN subscribers s
    ON p.plan_id = s.plan_id
GROUP BY p.plan_name
ORDER BY subscriber_count DESC;


-- QUERY 8: Top 10 data consumers

SELECT TOP 10
    s.subscriber_id,
    s.subscriber_name,
    SUM(c.data_used_gb) AS total_data_used
FROM subscribers s
JOIN call_records c
    ON s.subscriber_id = c.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY total_data_used DESC;


-- =====================================================
-- 4. STRING AND DATE FUNCTIONS
-- =====================================================

-- Format invoice numbers using string functions

SELECT
    invoice_id,
    CONCAT('INV-', RIGHT('000000' +
        CAST(invoice_id AS VARCHAR(10)), 6))
        AS formatted_invoice_number
FROM invoices;


-- Calculate due-date status

SELECT
    invoice_id,
    due_date,
    FORMAT(due_date, 'dd-MMM-yyyy') AS formatted_due_date,
    CASE
        WHEN payment_date IS NOT NULL
            THEN 'Paid'
        WHEN CAST(GETDATE() AS DATE) <= due_date
            THEN 'Pending'
        WHEN DATEDIFF(DAY, due_date,
             CAST(GETDATE() AS DATE)) > 15
            THEN 'Overdue by more than 15 days'
        ELSE 'Overdue'
    END AS due_date_status
FROM invoices;


-- =====================================================
-- 5. DEMONSTRATE NULL EFFECT ON SUM AND AVG
-- =====================================================

-- Subscribers with missing usage rows

SELECT
    s.subscriber_id,
    s.subscriber_name,
    COUNT(c.call_id) AS usage_records,
    SUM(c.data_used_gb) AS total_data_used,
    AVG(c.data_used_gb) AS average_data_used
FROM subscribers s
LEFT JOIN call_records c
    ON s.subscriber_id = c.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY s.subscriber_id;


-- Overall SUM and AVG with NULL values

SELECT
    COUNT(*) AS total_subscribers,
    COUNT(total_usage) AS subscribers_with_usage,
    SUM(total_usage) AS total_data_usage,
    AVG(total_usage) AS average_data_usage
FROM (
    SELECT
        s.subscriber_id,
        SUM(c.data_used_gb) AS total_usage
    FROM subscribers s
    LEFT JOIN call_records c
        ON s.subscriber_id = c.subscriber_id
    GROUP BY s.subscriber_id
) AS UsageSummary;


-- Compare AVG with and without missing usage values

SELECT
    AVG(total_usage) AS average_excluding_null,
    AVG(ISNULL(total_usage, 0)) AS average_including_zero
FROM (
    SELECT
        s.subscriber_id,
        SUM(c.data_used_gb) AS total_usage
    FROM subscribers s
    LEFT JOIN call_records c
        ON s.subscriber_id = c.subscriber_id
    GROUP BY s.subscriber_id
) AS UsageSummary;

-- =====================================================
-- END OF REPORTING SCRIPT
-- =====================================================
