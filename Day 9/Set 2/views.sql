
USE InsuranceDB;
GO

-- TASK 1: CREATE VIEW FOR POLICIES DUE
-- WITHIN THE NEXT 30 DAYS

CREATE OR ALTER VIEW vw_policy_due
AS
SELECT
    p.policy_id,
    p.policy_number,
    p.product_name,
    p.start_date,
    p.end_date AS renewal_due_date,
    p.status,
    c.customer_id,
    c.customer_name,
    a.agent_id,
    a.agent_name
FROM Policies p
INNER JOIN Customers c
    ON p.customer_id = c.customer_id
LEFT JOIN Agents a
    ON p.agent_id = a.agent_id
WHERE
    p.end_date BETWEEN CAST(GETDATE() AS DATE)
    AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE));
GO

-- TEST THE VIEW
SELECT * FROM vw_policy_due;
GO
