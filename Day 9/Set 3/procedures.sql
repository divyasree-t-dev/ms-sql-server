
USE TelecomDB;
GO

-- ============================================
-- 1. STORED PROCEDURE: usp_Recharge
-- ============================================

CREATE OR ALTER PROCEDURE dbo.usp_Recharge
    @SubscriberID INT,
    @PlanID INT,
    @Amount DECIMAL(10,2),
    @NewBalance DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PlanAmount DECIMAL(10,2);
    DECLARE @ValidityDays INT;

    SET @NewBalance = NULL;

    BEGIN TRY

        -- Validate recharge amount

        IF @Amount IS NULL OR @Amount <= 0
        BEGIN
            THROW 50001,
                'Recharge amount must be greater than zero.', 1;
        END;

        -- Validate subscriber

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.subscribers
            WHERE subscriber_id = @SubscriberID
              AND subscriber_type = 'Prepaid'
        )
        BEGIN
            THROW 50002,
                'Invalid or non-prepaid subscriber.', 1;
        END;

        -- Validate plan

        SELECT
            @PlanAmount = monthly_charge,
            @ValidityDays = validity_days
        FROM dbo.plans
        WHERE plan_id = @PlanID;

        IF @PlanAmount IS NULL OR @ValidityDays IS NULL
        BEGIN
            THROW 50003,
                'Invalid recharge plan.', 1;
        END;

        -- Validate recharge amount against plan price

        IF @Amount <> @PlanAmount
        BEGIN
            THROW 50004,
                'Recharge amount does not match plan price.', 1;
        END;

        BEGIN TRANSACTION;

        -- Update subscriber balance and plan

        UPDATE dbo.subscribers
        SET
            balance = balance + @Amount,
            plan_id = @PlanID,
            validity_end_date =
                DATEADD(DAY, @ValidityDays, CAST(GETDATE() AS DATE))
        WHERE subscriber_id = @SubscriberID;

        -- Insert recharge history

        INSERT INTO dbo.RechargeHistory
        (
            subscriber_id,
            plan_id,
            recharge_amount,
            recharge_date,
            validity_days
        )
        VALUES
        (
            @SubscriberID,
            @PlanID,
            @Amount,
            GETDATE(),
            @ValidityDays
        );

        -- Get updated balance

        SELECT @NewBalance = balance
        FROM dbo.subscribers
        WHERE subscriber_id = @SubscriberID;

        COMMIT TRANSACTION;

        PRINT 'Recharge completed successfully.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @NewBalance = NULL;

        THROW;

    END CATCH;
END;
GO

-- ============================================
-- 2. SCALAR FUNCTION
-- fn_ValidityDaysLeft
-- ============================================

CREATE OR ALTER FUNCTION dbo.fn_ValidityDaysLeft
(
    @SubscriberID INT
)
RETURNS INT
AS
BEGIN

    DECLARE @DaysLeft INT;

    SELECT
        @DaysLeft =
            CASE
                WHEN validity_end_date IS NULL THEN 0

                WHEN validity_end_date < CAST(GETDATE() AS DATE)
                    THEN 0

                ELSE DATEDIFF
                (
                    DAY,
                    CAST(GETDATE() AS DATE),
                    validity_end_date
                )
            END
    FROM dbo.subscribers
    WHERE subscriber_id = @SubscriberID;

    RETURN ISNULL(@DaysLeft, 0);
END;
GO

-- ============================================
-- 3. TABLE-VALUED FUNCTION
-- fn_LastFiveRecharges
-- ============================================

CREATE OR ALTER FUNCTION dbo.fn_LastFiveRecharges
(
    @SubscriberID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5
        recharge_id,
        subscriber_id,
        plan_id,
        recharge_amount,
        recharge_date,
        validity_days
    FROM dbo.RechargeHistory
    WHERE subscriber_id = @SubscriberID
    ORDER BY recharge_date DESC, recharge_id DESC
);
GO

-- ============================================
-- 4. TEST STORED PROCEDURE
-- ============================================

DECLARE @UpdatedBalance DECIMAL(10,2);

EXEC dbo.usp_Recharge
    @SubscriberID = 101,
    @PlanID = 1,
    @Amount = 199.00,
    @NewBalance = @UpdatedBalance OUTPUT;

SELECT @UpdatedBalance AS NewBalance;
GO

-- ============================================
-- 5. TEST VALIDITY FUNCTION
-- ============================================

SELECT
    subscriber_id,
    subscriber_name,
    dbo.fn_ValidityDaysLeft(subscriber_id)
        AS ValidityDaysLeft
FROM dbo.subscribers;
GO

-- ============================================
-- 6. TEST LAST FIVE RECHARGES
-- ============================================

SELECT *
FROM dbo.fn_LastFiveRecharges(101);
GO

PRINT 'Procedure and functions created successfully.';
GO
