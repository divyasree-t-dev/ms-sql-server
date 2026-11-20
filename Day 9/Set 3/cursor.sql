
USE TelecomDB;
GO

SET NOCOUNT ON;

-- ============================================
-- 1. CREATE TIMING RESULTS TABLE
-- ============================================

IF OBJECT_ID('dbo.NotificationTimingResults', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NotificationTimingResults
    (
        timing_id INT IDENTITY(1,1) PRIMARY KEY,
        method_name VARCHAR(50),
        execution_time_ms BIGINT,
        records_inserted INT,
        execution_date DATETIME DEFAULT GETDATE()
    );
END;
GO

-- ============================================
-- 2. DECLARE VARIABLES
-- ============================================

DECLARE @StartTime DATETIME2(7);
DECLARE @EndTime DATETIME2(7);

DECLARE @CursorTime BIGINT;
DECLARE @SetBasedTime BIGINT;

DECLARE @CursorCount INT;
DECLARE @SetBasedCount INT;

DECLARE @SubscriberID INT;

-- ============================================
-- 3. CURSOR-BASED PROCESSING
-- ============================================

DELETE FROM dbo.NotificationLog;

DECLARE LowBalanceCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT subscriber_id
FROM dbo.subscribers
WHERE subscriber_type = 'Prepaid'
  AND balance < 50;

SET @StartTime = SYSDATETIME();

OPEN LowBalanceCursor;

FETCH NEXT FROM LowBalanceCursor
INTO @SubscriberID;

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT INTO dbo.NotificationLog
    (
        subscriber_id,
        message,
        notification_date,
        is_read
    )
    VALUES
    (
        @SubscriberID,
        'Your prepaid balance is below 50. Please recharge.',
        GETDATE(),
        0
    );

    FETCH NEXT FROM LowBalanceCursor
    INTO @SubscriberID;

END;

CLOSE LowBalanceCursor;
DEALLOCATE LowBalanceCursor;

SET @EndTime = SYSDATETIME();

SET @CursorTime =
    DATEDIFF_BIG(MICROSECOND, @StartTime, @EndTime) / 1000;

SELECT @CursorCount = COUNT(*)
FROM dbo.NotificationLog;

INSERT INTO dbo.NotificationTimingResults
(
    method_name,
    execution_time_ms,
    records_inserted
)
VALUES
(
    'Cursor',
    @CursorTime,
    @CursorCount
);

PRINT 'Cursor processing completed.';

-- ============================================
-- 4. SET-BASED PROCESSING
-- ============================================

DELETE FROM dbo.NotificationLog;

SET @StartTime = SYSDATETIME();

INSERT INTO dbo.NotificationLog
(
    subscriber_id,
    message,
    notification_date,
    is_read
)
SELECT
    subscriber_id,
    'Your prepaid balance is below 50. Please recharge.',
    GETDATE(),
    0
FROM dbo.subscribers
WHERE subscriber_type = 'Prepaid'
  AND balance < 50;

SET @SetBasedCount = @@ROWCOUNT;

SET @EndTime = SYSDATETIME();

SET @SetBasedTime =
    DATEDIFF_BIG(MICROSECOND, @StartTime, @EndTime) / 1000;

INSERT INTO dbo.NotificationTimingResults
(
    method_name,
    execution_time_ms,
    records_inserted
)
VALUES
(
    'Set-Based',
    @SetBasedTime,
    @SetBasedCount
);

PRINT 'Set-based processing completed.';

-- ============================================
-- 5. DISPLAY TIMING COMPARISON
-- ============================================

SELECT
    method_name,
    execution_time_ms,
    records_inserted,
    execution_date
FROM dbo.NotificationTimingResults
ORDER BY timing_id DESC;

-- ============================================
-- 6. VERIFY NOTIFICATION RECORDS
-- ============================================

SELECT
    notification_id,
    subscriber_id,
    message,
    notification_date,
    is_read
FROM dbo.NotificationLog
ORDER BY notification_id;

PRINT 'Notification processing completed.';
GO
