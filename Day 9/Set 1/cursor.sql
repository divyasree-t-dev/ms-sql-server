
USE RetailDB;
GO

/* =====================================================
   PART 1: CREATE FOLLOW-UP TABLE
   Stores follow-up details for delayed pending orders.
   ===================================================== */

IF OBJECT_ID('dbo.order_followups', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.order_followups
    (
        followup_id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL UNIQUE,
        followup_date DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        remarks VARCHAR(200) NOT NULL
            DEFAULT 'Follow-up required for pending order',

        CONSTRAINT FK_order_followups_orders
            FOREIGN KEY (order_id)
            REFERENCES dbo.orders(order_id)
    );
END;
GO


/* =====================================================
   PART 2: CURSOR-BASED STORED PROCEDURE
   Finds pending orders older than 3 days and
   inserts follow-up records one by one.
   ===================================================== */

CREATE OR ALTER PROCEDURE dbo.usp_ProcessPendingOrders_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrderID INT;
    DECLARE @InsertedCount INT = 0;

    DECLARE pending_order_cursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT order_id
        FROM dbo.orders
        WHERE order_status = 'Pending'
          AND order_date < DATEADD(
                DAY, -3, CAST(GETDATE() AS DATE)
              );

    OPEN pending_order_cursor;

    FETCH NEXT FROM pending_order_cursor
    INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.order_followups
            WHERE order_id = @OrderID
        )
        BEGIN
            INSERT INTO dbo.order_followups
            (
                order_id,
                remarks
            )
            VALUES
            (
                @OrderID,
                'Pending order older than 3 days - follow-up required'
            );

            SET @InsertedCount = @InsertedCount + 1;
        END;

        FETCH NEXT FROM pending_order_cursor
        INTO @OrderID;
    END;

    CLOSE pending_order_cursor;
    DEALLOCATE pending_order_cursor;

    SELECT @InsertedCount AS CursorFollowupsCreated;
END;
GO


/* =====================================================
   PART 3: SET-BASED ALTERNATIVE
   Processes all eligible orders in one statement.
   ===================================================== */

CREATE OR ALTER PROCEDURE dbo.usp_ProcessPendingOrders_SetBased
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.order_followups
    (
        order_id,
        remarks
    )
    SELECT
        o.order_id,
        'Pending order older than 3 days - follow-up required'
    FROM dbo.orders o
    WHERE o.order_status = 'Pending'
      AND o.order_date < DATEADD(
            DAY, -3, CAST(GETDATE() AS DATE)
          )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.order_followups f
          WHERE f.order_id = o.order_id
      );

    SELECT @@ROWCOUNT AS SetBasedFollowupsCreated;
END;
GO


/* =====================================================
   PART 4: VERIFY CREATED PROCEDURES
   ===================================================== */

SELECT name
FROM sys.procedures
WHERE name IN
(
    'usp_ProcessPendingOrders_Cursor',
    'usp_ProcessPendingOrders_SetBased'
);
GO


/* =====================================================
   PART 5: EXECUTION TESTS
   Run ONE method at a time for comparison.
   Both methods use the same follow-up table.
   ===================================================== */

-- Method 1: Cursor approach
-- EXEC dbo.usp_ProcessPendingOrders_Cursor;
-- GO

-- Method 2: Set-based approach
-- EXEC dbo.usp_ProcessPendingOrders_SetBased;
-- GO


/* =====================================================
   PART 6: VIEW FOLLOW-UP RECORDS
   ===================================================== */

SELECT
    f.followup_id,
    f.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    f.followup_date,
    f.remarks
FROM dbo.order_followups f
INNER JOIN dbo.orders o
    ON f.order_id = o.order_id
ORDER BY f.followup_id DESC;
GO


USE RetailDB;
GO

EXEC dbo.usp_ProcessPendingOrders_Cursor;
GO

SELECT * FROM dbo.order_followups;
GO


SELECT
    f.followup_id,
    f.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    f.followup_date,
    f.remarks
FROM dbo.order_followups f
INNER JOIN dbo.orders o
    ON f.order_id = o.order_id
ORDER BY f.followup_id;
GO


USE RetailDB;
GO

EXEC dbo.usp_ProcessPendingOrders_SetBased;
GO