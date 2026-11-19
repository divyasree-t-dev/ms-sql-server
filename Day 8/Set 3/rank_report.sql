
-- Day 8 - Set 3: Retail Inventory Reservation
-- Correlated Subqueries, CTEs and Window Functions

-- TASK 2: Products with stock below their category average

SELECT
    P.ProductID,
    P.ProductName,
    C.CategoryName,
    P.Stock
FROM Products P
INNER JOIN Categories C
    ON P.CategoryID = C.CategoryID
WHERE P.Stock < (
    SELECT AVG(CAST(P2.Stock AS DECIMAL(10,2)))
    FROM Products P2
    WHERE P2.CategoryID = P.CategoryID
);

-- TASK 3: Top 3 products by sales within each category

WITH ProductSales AS (
    SELECT
        P.ProductID,
        P.ProductName,
        C.CategoryName,
        SUM(OI.Quantity) AS TotalUnitsSold,
        SUM(OI.Quantity * OI.UnitPrice) AS TotalSales
    FROM Products P
    INNER JOIN Categories C
        ON P.CategoryID = C.CategoryID
    INNER JOIN OrderItems OI
        ON P.ProductID = OI.ProductID
    GROUP BY
        P.ProductID,
        P.ProductName,
        C.CategoryName
),
RankedProducts AS (
    SELECT
        ProductID,
        ProductName,
        CategoryName,
        TotalUnitsSold,
        TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName
            ORDER BY TotalSales DESC
        ) AS SalesRank
    FROM ProductSales
)
SELECT
    ProductID,
    ProductName,
    CategoryName,
    TotalUnitsSold,
    TotalSales,
    SalesRank
FROM RankedProducts
WHERE SalesRank <= 3
ORDER BY CategoryName, SalesRank;

-- TASK 4: Month-on-month sales change using LAG and LEAD

WITH MonthlySales AS (
    SELECT
        OI.ProductID,
        P.ProductName,
        YEAR(O.OrderDate) AS SalesYear,
        MONTH(O.OrderDate) AS SalesMonth,
        SUM(OI.Quantity * OI.UnitPrice) AS MonthlySales
    FROM OrderItems OI
    INNER JOIN Orders O
        ON OI.OrderID = O.OrderID
    INNER JOIN Products P
        ON OI.ProductID = P.ProductID
    GROUP BY
        OI.ProductID,
        P.ProductName,
        YEAR(O.OrderDate),
        MONTH(O.OrderDate)
),
SalesComparison AS (
    SELECT
        ProductID,
        ProductName,
        SalesYear,
        SalesMonth,
        MonthlySales,

        LAG(MonthlySales) OVER (
            PARTITION BY ProductID
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthSales,

        LEAD(MonthlySales) OVER (
            PARTITION BY ProductID
            ORDER BY SalesYear, SalesMonth
        ) AS NextMonthSales

    FROM MonthlySales
)
SELECT
    ProductID,
    ProductName,
    SalesYear,
    SalesMonth,
    MonthlySales,
    PreviousMonthSales,
    NextMonthSales,

    MonthlySales - PreviousMonthSales
        AS MonthOnMonthChange,

    CASE
        WHEN PreviousMonthSales IS NULL THEN 'No Previous Data'
        WHEN MonthlySales > PreviousMonthSales THEN 'Increased'
        WHEN MonthlySales < PreviousMonthSales THEN 'Decreased'
        ELSE 'No Change'
    END AS SalesTrend

FROM SalesComparison
ORDER BY ProductID, SalesYear, SalesMonth;
