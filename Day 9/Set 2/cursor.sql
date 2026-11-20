
USE InsuranceDB;
GO

-- TASK 4: CURSOR IMPLEMENTATION

DECLARE
    @PolicyID INT,
    @OldStatus VARCHAR(20),
    @OldEndDate DATE;

BEGIN TRY

    BEGIN TRANSACTION;

    DECLARE PolicyCursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT
            p.policy_id,
            p.status,
            p.end_date
        FROM Policies p
        WHERE p.status = 'Active'
          AND p.end_date < CAST(GETDATE() AS DATE)
          AND NOT EXISTS
          (
              SELECT 1
              FROM Premiums pr
              WHERE pr.policy_id = p.policy_id
                AND pr.payment_date >= p.end_date
          );

    OPEN PolicyCursor;

    FETCH NEXT FROM PolicyCursor
    INTO @PolicyID, @OldStatus, @OldEndDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- UPDATE POLICY STATUS
        UPDATE Policies
        SET status = 'Lapsed'
        WHERE policy_id = @PolicyID
          AND status = 'Active';

        IF @@ROWCOUNT = 1
        BEGIN

            -- LOG EACH UPDATE
            INSERT INTO PolicyAudit
            (
                policy_id,
                action_type,
                old_status,
                new_status,
                old_end_date,
                new_end_date,
                details
            )
            VALUES
            (
                @PolicyID,
                'Policy Lapse',
                @OldStatus,
                'Lapsed',
                @OldEndDate,
                @OldEndDate,
                'Policy marked as lapsed due to unpaid renewal.'
            );

            PRINT 'Policy marked as Lapsed: '
                  + CAST(@PolicyID AS VARCHAR(10));
        END;

        FETCH NEXT FROM PolicyCursor
        INTO @PolicyID, @OldStatus, @OldEndDate;

    END;

    CLOSE PolicyCursor;
    DEALLOCATE PolicyCursor;

    COMMIT TRANSACTION;

    PRINT 'Cursor processing completed successfully.';

END TRY

BEGIN CATCH

    IF CURSOR_STATUS('local', 'PolicyCursor') >= 0
        CLOSE PolicyCursor;

    IF CURSOR_STATUS('local', 'PolicyCursor') > -3
        DEALLOCATE PolicyCursor;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

-- VERIFY CURSOR RESULTS
SELECT *
FROM Policies
WHERE status = 'Lapsed';
GO

SELECT *
FROM PolicyAudit
WHERE action_type = 'Policy Lapse';
GO



USE InsuranceDB;
GO

-- TASK 4: SET-BASED IMPLEMENTATION

DECLARE @UpdatedPolicies TABLE
(
    policy_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    old_end_date DATE,
    new_end_date DATE
);

BEGIN TRY

    BEGIN TRANSACTION;

    -- UPDATE ALL ELIGIBLE POLICIES
    UPDATE p
    SET status = 'Lapsed'

    OUTPUT
        deleted.policy_id,
        deleted.status,
        inserted.status,
        deleted.end_date,
        inserted.end_date

    INTO @UpdatedPolicies

    FROM Policies p

    WHERE p.status = 'Active'
      AND p.end_date < CAST(GETDATE() AS DATE)
      AND NOT EXISTS
      (
          SELECT 1
          FROM Premiums pr
          WHERE pr.policy_id = p.policy_id
            AND pr.payment_date >= p.end_date
      );

    -- LOG ALL UPDATES
    INSERT INTO PolicyAudit
    (
        policy_id,
        action_type,
        old_status,
        new_status,
        old_end_date,
        new_end_date,
        details
    )
    SELECT
        policy_id,
        'Policy Lapse',
        old_status,
        new_status,
        old_end_date,
        new_end_date,
        'Policy marked as lapsed using set-based processing.'
    FROM @UpdatedPolicies;

    COMMIT TRANSACTION;

    PRINT 'Set-based processing completed successfully.';

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

-- VERIFY RESULTS
SELECT *
FROM Policies
WHERE status = 'Lapsed';
GO

SELECT *
FROM PolicyAudit
WHERE action_type = 'Policy Lapse';
GO


USE InsuranceDB;
GO

SELECT policy_id, policy_number, status, end_date
FROM Policies
WHERE status = 'Lapsed';
GO

SELECT *
FROM PolicyAudit
WHERE action_type = 'Policy Lapse';
GO