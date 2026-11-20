USE InsuranceDB;
GO

-- AUDIT TABLE

IF OBJECT_ID('dbo.PolicyAudit', 'U') IS NULL
BEGIN
    CREATE TABLE PolicyAudit
    (
        audit_id INT IDENTITY(1,1) PRIMARY KEY,
        policy_id INT NOT NULL,
        action_type VARCHAR(50),
        old_status VARCHAR(20),
        new_status VARCHAR(20),
        old_end_date DATE,
        new_end_date DATE,
        old_premium DECIMAL(18,2),
        new_premium DECIMAL(18,2),
        action_date DATETIME DEFAULT GETDATE(),
        details VARCHAR(500)
    );
END;
GO




USE InsuranceDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_PremiumWithNoClaimDiscount
(
    @PolicyID INT,
    @BasePremium DECIMAL(18,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @FinalPremium DECIMAL(18,2);

    IF NOT EXISTS
    (
        SELECT 1
        FROM Claims
        WHERE policy_id = @PolicyID
    )
    BEGIN
        SET @FinalPremium = @BasePremium * 0.90;
    END
    ELSE
    BEGIN
        SET @FinalPremium = @BasePremium;
    END;

    RETURN @FinalPremium;
END;
GO

-- TEST SCALAR FUNCTION
SELECT
    policy_id,
    premium_amount,
    dbo.fn_PremiumWithNoClaimDiscount(
        policy_id,
        premium_amount
    ) AS discounted_premium
FROM Premiums;
GO




USE InsuranceDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_RenewPolicy
    @PolicyID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @PolicyStatus VARCHAR(20),
        @OldEndDate DATE,
        @NewEndDate DATE,
        @BasePremium DECIMAL(18,2),
        @NewPremium DECIMAL(18,2);

    BEGIN TRY

        BEGIN TRANSACTION;

        -- 1. CHECK POLICY
        SELECT
            @PolicyStatus = status,
            @OldEndDate = end_date
        FROM Policies WITH (UPDLOCK, HOLDLOCK)
        WHERE policy_id = @PolicyID;

        IF @PolicyStatus IS NULL
        BEGIN
            THROW 50001, 'Policy does not exist.', 1;
        END;

        -- 2. CHECK ACTIVE STATUS
        IF @PolicyStatus <> 'Active'
        BEGIN
            THROW 50002, 'Only active policies can be renewed.', 1;
        END;

        -- 3. CHECK PENDING CLAIMS
        IF EXISTS
        (
            SELECT 1
            FROM Claims
            WHERE policy_id = @PolicyID
              AND claim_status = 'Pending'
        )
        BEGIN
            THROW 50003, 'Policy has pending claims.', 1;
        END;

        -- 4. GET LATEST PREMIUM
        SELECT TOP 1
            @BasePremium = premium_amount
        FROM Premiums
        WHERE policy_id = @PolicyID
        ORDER BY payment_date DESC, premium_id DESC;

        IF @BasePremium IS NULL
        BEGIN
            THROW 50004, 'No existing premium found.', 1;
        END;

        -- 5. RECALCULATE PREMIUM
        SET @NewPremium =
            dbo.fn_PremiumWithNoClaimDiscount(
                @PolicyID,
                @BasePremium
            );

        -- 6. CALCULATE NEW END DATE
        IF @OldEndDate IS NULL
        BEGIN
            THROW 50005, 'Policy end date is missing.', 1;
        END;

        SET @NewEndDate = DATEADD(YEAR, 1, @OldEndDate);

        -- 7. UPDATE POLICY
        UPDATE Policies
        SET end_date = @NewEndDate
        WHERE policy_id = @PolicyID;

        -- 8. INSERT NEW PREMIUM
        INSERT INTO Premiums
        (
            policy_id,
            payment_date,
            premium_amount
        )
        VALUES
        (
            @PolicyID,
            CAST(GETDATE() AS DATE),
            @NewPremium
        );

        -- 9. INSERT AUDIT RECORD
        INSERT INTO PolicyAudit
        (
            policy_id,
            action_type,
            old_status,
            new_status,
            old_end_date,
            new_end_date,
            old_premium,
            new_premium,
            details
        )
        VALUES
        (
            @PolicyID,
            'Policy Renewal',
            @PolicyStatus,
            @PolicyStatus,
            @OldEndDate,
            @NewEndDate,
            @BasePremium,
            @NewPremium,
            'Policy renewed successfully.'
        );

        COMMIT TRANSACTION;

        PRINT 'Policy renewed successfully.';
        PRINT 'New premium calculated and audit record inserted.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;
GO

-- TEST STORED PROCEDURE
-- Use an active policy without pending claims
-- EXEC dbo.usp_RenewPolicy @PolicyID = 101;




USE InsuranceDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_AgentRenewalQuotes
(
    @AgentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.policy_id,
        p.policy_number,
        p.product_name,
        p.end_date AS renewal_due_date,
        c.customer_id,
        c.customer_name,
        a.agent_id,
        a.agent_name,
        lp.premium_amount AS current_premium,

        dbo.fn_PremiumWithNoClaimDiscount(
            p.policy_id,
            lp.premium_amount
        ) AS renewal_quote

    FROM Policies p

    INNER JOIN Customers c
        ON p.customer_id = c.customer_id

    INNER JOIN Agents a
        ON p.agent_id = a.agent_id

    CROSS APPLY
    (
        SELECT TOP 1
            premium_amount
        FROM Premiums pr
        WHERE pr.policy_id = p.policy_id
        ORDER BY payment_date DESC, premium_id DESC
    ) lp

    WHERE p.agent_id = @AgentID
      AND p.status = 'Active'
);
GO

-- TEST TABLE-VALUED FUNCTION
SELECT *
FROM dbo.fn_AgentRenewalQuotes(1);
GO




USE InsuranceDB;
GO

-- CHECK AUDIT RECORDS
SELECT * FROM PolicyAudit;
GO

-- CHECK RENEWED POLICIES
SELECT * FROM Policies;
GO

-- CHECK PREMIUM HISTORY
SELECT * FROM Premiums;
GO

-- CHECK AGENT RENEWAL QUOTES
SELECT *
FROM dbo.fn_AgentRenewalQuotes(1);
GO
