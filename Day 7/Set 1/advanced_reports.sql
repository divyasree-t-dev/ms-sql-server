
/*
=========================================================
DAY 7 - JOINS, SUBQUERIES AND LOOKUPS
SET 1 - LOGISTICS SHIPMENT ANALYSIS
Database: LogisticsDB
Platform: SQL Server 2025
=========================================================
*/

-- Create Database
IF DB_ID('LogisticsDB') IS NULL
    CREATE DATABASE LogisticsDB;
GO

USE LogisticsDB;
GO

-- =======================================================
-- 1. TABLE CREATION
-- =======================================================

DROP TABLE IF EXISTS DeliveryEvents;
DROP TABLE IF EXISTS Shipments;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Carriers;
DROP TABLE IF EXISTS Hubs;
GO

CREATE TABLE Hubs (
    HubID INT PRIMARY KEY,
    HubName VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100)
);

CREATE TABLE Carriers (
    CarrierID INT PRIMARY KEY,
    CarrierName VARCHAR(100),
    ContactNumber VARCHAR(20)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(100)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    SupervisorID INT NULL,
    Designation VARCHAR(100),
    FOREIGN KEY (SupervisorID)
        REFERENCES Employees(EmployeeID)
);

CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    CustomerID INT,
    CarrierID INT,
    OriginHubID INT,
    DestinationHubID INT,
    ShipmentDate DATE,
    DeliveryDate DATE NULL,
    ShippingCost DECIMAL(10,2),
    Status VARCHAR(30),

    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CarrierID) REFERENCES Carriers(CarrierID),
    FOREIGN KEY (OriginHubID) REFERENCES Hubs(HubID),
    FOREIGN KEY (DestinationHubID) REFERENCES Hubs(HubID)
);

CREATE TABLE DeliveryEvents (
    EventID INT PRIMARY KEY,
    ShipmentID INT,
    EventDate DATE,
    EventLocation VARCHAR(100),
    EventDescription VARCHAR(200),
    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID)
);
GO

-- =======================================================
-- 2. SAMPLE DATA
-- =======================================================

INSERT INTO Hubs VALUES
(1, 'Chennai Central Hub', 'Chennai', 'Tamil Nadu'),
(2, 'Bangalore Hub', 'Bangalore', 'Karnataka'),
(3, 'Hyderabad Hub', 'Hyderabad', 'Telangana'),
(4, 'Mumbai Hub', 'Mumbai', 'Maharashtra'),
(5, 'Delhi Hub', 'Delhi', 'Delhi'),
(6, 'Kochi Hub', 'Kochi', 'Kerala');

INSERT INTO Carriers VALUES
(1, 'BlueDart Logistics', '9876543210'),
(2, 'DTDC Express', '9876543211'),
(3, 'Delhivery', '9876543212'),
(4, 'FedEx India', '9876543213'),
(5, 'Ecom Express', '9876543214');

INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'arun@gmail.com', 'Chennai'),
(2, 'Priya Sharma', 'priya@gmail.com', 'Bangalore'),
(3, 'Rahul Verma', 'rahul@gmail.com', 'Hyderabad'),
(4, 'Sneha Raj', 'sneha@gmail.com', 'Mumbai'),
(5, 'Karthik M', 'karthik@gmail.com', 'Delhi'),
(6, 'Divya S', 'divya@gmail.com', 'Kochi');

INSERT INTO Employees VALUES
(1, 'Ramesh', NULL, 'Operations Manager'),
(2, 'Suresh', 1, 'Hub Supervisor'),
(3, 'Meena', 1, 'Logistics Manager'),
(4, 'Kavitha', 2, 'Delivery Coordinator'),
(5, 'Vijay', 2, 'Shipment Executive'),
(6, 'Anitha', 3, 'Operations Executive');

INSERT INTO Shipments VALUES
(101, 1, 1, 1, 2, '2026-01-01', '2026-01-03', 450, 'Delivered'),
(102, 2, 2, 2, 3, '2026-01-02', '2026-01-07', 600, 'Delayed'),
(103, 3, 3, 3, 4, '2026-01-03', '2026-01-04', 350, 'Delivered'),
(104, 4, 1, 1, 5, '2026-01-04', '2026-01-10', 800, 'Delayed'),
(105, 5, 4, 4, 1, '2026-01-05', '2026-01-06', 700, 'Delivered'),
(106, 1, 2, 2, 5, '2026-01-06', '2026-01-12', 550, 'Delayed'),
(107, 2, 3, 3, 1, '2026-01-07', '2026-01-09', 400, 'Delivered'),
(108, 3, 4, 4, 2, '2026-01-08', '2026-01-15', 900, 'Delayed'),
(109, 4, 5, 5, 3, '2026-01-09', '2026-01-10', 300, 'Delivered'),
(110, 5, 1, 1, 4, '2026-01-10', '2026-01-14', 650, 'Delayed'),
(111, 1, 3, 2, 4, '2026-01-11', '2026-01-12', 500, 'Delivered'),
(112, 6, 5, 5, 2, '2026-01-12', NULL, 750, 'In Transit');

INSERT INTO DeliveryEvents VALUES
(1, 101, '2026-01-01', 'Chennai', 'Shipment picked up'),
(2, 101, '2026-01-02', 'Bangalore', 'Arrived at hub'),
(3, 101, '2026-01-03', 'Bangalore', 'Delivered'),
(4, 102, '2026-01-02', 'Bangalore', 'Shipment picked up'),
(5, 102, '2026-01-05', 'Hyderabad', 'Customs clearance delayed'),
(6, 102, '2026-01-07', 'Hyderabad', 'Delivered'),
(7, 104, '2026-01-04', 'Chennai', 'Shipment picked up'),
(8, 104, '2026-01-08', 'Mumbai', 'Transit delay'),
(9, 104, '2026-01-10', 'Delhi', 'Delivered'),
(10, 108, '2026-01-08', 'Mumbai', 'Shipment picked up'),
(11, 108, '2026-01-12', 'Bangalore', 'Shipment delayed'),
(12, 108, '2026-01-15', 'Bangalore', 'Delivered');
GO

-- =======================================================
-- TASK 1: TEN BUSINESS QUESTIONS USING JOINS
-- =======================================================

-- Q1. Find shipments delayed by more than two days
-- with carrier names.
-- INNER JOIN: Shipment and carrier details are required.

SELECT
    s.ShipmentID,
    c.CarrierName,
    s.ShipmentDate,
    s.DeliveryDate,
    DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) - 2
        AS DelayBeyondTwoDays
FROM Shipments s
INNER JOIN Carriers c
    ON s.CarrierID = c.CarrierID
WHERE s.DeliveryDate IS NOT NULL
  AND DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate) > 2;


-- Q2. Display all hubs and their outbound shipment counts.
-- LEFT JOIN: Include hubs even when they have no shipments.

SELECT
    h.HubID,
    h.HubName,
    COUNT(s.ShipmentID) AS OutboundShipments
FROM Hubs h
LEFT JOIN Shipments s
    ON h.HubID = s.OriginHubID
GROUP BY h.HubID, h.HubName
ORDER BY h.HubID;


-- Q3. Find hubs with no outbound shipments.
-- LEFT JOIN with NULL filtering.

SELECT
    h.HubID,
    h.HubName
FROM Hubs h
LEFT JOIN Shipments s
    ON h.HubID = s.OriginHubID
WHERE s.ShipmentID IS NULL;


-- Q4. Display employees and their supervisors.
-- SELF JOIN: Both columns refer to Employees.

SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Designation,
    sup.EmployeeName AS SupervisorName
FROM Employees e
LEFT JOIN Employees sup
    ON e.SupervisorID = sup.EmployeeID;


-- Q5. Display shipment details with customer and carrier names.
-- Multiple INNER JOINs.

SELECT
    s.ShipmentID,
    cu.CustomerName,
    ca.CarrierName,
    s.ShippingCost,
    s.Status
FROM Shipments s
INNER JOIN Customers cu
    ON s.CustomerID = cu.CustomerID
INNER JOIN Carriers ca
    ON s.CarrierID = ca.CarrierID;


-- Q6. Display all customers and their shipment details.
-- LEFT JOIN: Include customers without shipments.

SELECT
    cu.CustomerID,
    cu.CustomerName,
    s.ShipmentID,
    s.Status
FROM Customers cu
LEFT JOIN Shipments s
    ON cu.CustomerID = s.CustomerID;


-- Q7. Display shipments and delivery events.
-- LEFT JOIN: Include shipments without delivery events.

SELECT
    s.ShipmentID,
    s.Status,
    de.EventDate,
    de.EventLocation,
    de.EventDescription
FROM Shipments s
LEFT JOIN DeliveryEvents de
    ON s.ShipmentID = de.ShipmentID
ORDER BY s.ShipmentID, de.EventDate;


-- Q8. Display all hubs and their incoming/outgoing shipments.
-- FULL OUTER JOIN: Preserve unmatched records from both sides.

SELECT
    COALESCE(o.HubName, i.HubName) AS HubName,
    o.ShipmentID AS OutboundShipment,
    i.ShipmentID AS InboundShipment
FROM
(
    SELECT h.HubID, h.HubName, s.ShipmentID
    FROM Hubs h
    LEFT JOIN Shipments s
        ON h.HubID = s.OriginHubID
) o
FULL OUTER JOIN
(
    SELECT h.HubID, h.HubName, s.ShipmentID
    FROM Hubs h
    LEFT JOIN Shipments s
        ON h.HubID = s.DestinationHubID
) i
    ON o.HubID = i.HubID;


-- Q9. Find shipments where origin and destination hubs
-- are different, showing both hub names.
-- SELF JOIN on Hubs.

SELECT
    s.ShipmentID,
    origin.HubName AS OriginHub,
    destination.HubName AS DestinationHub
FROM Shipments s
INNER JOIN Hubs origin
    ON s.OriginHubID = origin.HubID
INNER JOIN Hubs destination
    ON s.DestinationHubID = destination.HubID
WHERE s.OriginHubID <> s.DestinationHubID;


-- Q10. Display all carriers and the number of shipments
-- assigned to each carrier.
-- LEFT JOIN: Include carriers with zero shipments.

SELECT
    c.CarrierID,
    c.CarrierName,
    COUNT(s.ShipmentID) AS TotalShipments
FROM Carriers c
LEFT JOIN Shipments s
    ON c.CarrierID = s.CarrierID
GROUP BY c.CarrierID, c.CarrierName
ORDER BY TotalShipments DESC;


-- =======================================================
-- TASK 2: SUBQUERIES - IN, EXISTS, ANY AND ALL
-- =======================================================

-- Q11. Find customers who shipped to every hub.
-- IN + nested NOT EXISTS (relational division).

SELECT
    c.CustomerID,
    c.CustomerName
FROM Customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM Hubs h
    WHERE h.HubID NOT IN
    (
        SELECT s.DestinationHubID
        FROM Shipments s
        WHERE s.CustomerID = c.CustomerID
    )
);


-- Q12. Find customers who shipped to at least one hub
-- in the destination hub list.

SELECT
    CustomerID,
    CustomerName
FROM Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Shipments
    WHERE DestinationHubID IN (1, 2, 3, 4, 5, 6)
);


-- Q13. Find carriers whose average shipping duration
-- is above the overall average shipping duration.
-- EXISTS + correlated subquery.

SELECT
    c.CarrierID,
    c.CarrierName
FROM Carriers c
WHERE EXISTS
(
    SELECT 1
    FROM Shipments s
    WHERE s.CarrierID = c.CarrierID
      AND s.DeliveryDate IS NOT NULL
    GROUP BY s.CarrierID
    HAVING AVG(
        CAST(DATEDIFF(DAY, s.ShipmentDate, s.DeliveryDate)
        AS DECIMAL(10,2))
    ) >
    (
        SELECT AVG(
            CAST(DATEDIFF(DAY, ShipmentDate, DeliveryDate)
            AS DECIMAL(10,2))
        )
        FROM Shipments
        WHERE DeliveryDate IS NOT NULL
    )
);


-- Q14. Find shipments with shipping cost greater than
-- ANY shipment originating from Chennai Central Hub.

SELECT
    ShipmentID,
    ShippingCost
FROM Shipments
WHERE ShippingCost > ANY
(
    SELECT s.ShippingCost
    FROM Shipments s
    INNER JOIN Hubs h
        ON s.OriginHubID = h.HubID
    WHERE h.HubName = 'Chennai Central Hub'
);


-- Q15. Find shipments whose shipping cost is greater
-- than ALL shipments originating from Bangalore Hub.

SELECT
    ShipmentID,
    ShippingCost
FROM Shipments
WHERE ShippingCost > ALL
(
    SELECT ShippingCost
    FROM Shipments
    WHERE OriginHubID = 2
);


-- =======================================================
-- TASK 3: REWRITE SUBQUERIES AS JOINS
-- =======================================================

-- Q16. Subquery version: Customers with shipments.

SELECT
    CustomerID,
    CustomerName
FROM Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Shipments
);

-- JOIN version.

SELECT DISTINCT
    c.CustomerID,
    c.CustomerName
FROM Customers c
INNER JOIN Shipments s
    ON c.CustomerID = s.CustomerID;


-- Q17. Subquery version: Carriers with shipments
-- costing more than 500.

SELECT
    CarrierID,
    CarrierName
FROM Carriers
WHERE CarrierID IN
(
    SELECT CarrierID
    FROM Shipments
    WHERE ShippingCost > 500
);

-- JOIN version.

SELECT DISTINCT
    c.CarrierID,
    c.CarrierName
FROM Carriers c
INNER JOIN Shipments s
    ON c.CarrierID = s.CarrierID
WHERE s.ShippingCost > 500;


-- =======================================================
-- TASK 4: SECOND-HIGHEST SHIPPING COST PER HUB
-- =======================================================

-- Q18. Find the second-highest distinct shipping cost
-- for each origin hub using nested subqueries.

SELECT
    h.HubID,
    h.HubName,
    (
        SELECT MAX(s1.ShippingCost)
        FROM Shipments s1
        WHERE s1.OriginHubID = h.HubID
          AND s1.ShippingCost <
          (
              SELECT MAX(s2.ShippingCost)
              FROM Shipments s2
              WHERE s2.OriginHubID = h.HubID
          )
    ) AS SecondHighestShippingCost
FROM Hubs h
WHERE EXISTS
(
    SELECT 1
    FROM Shipments s
    WHERE s.OriginHubID = h.HubID
);

-- =======================================================
-- END OF DAY 7 - SET 1
-- =======================================================
