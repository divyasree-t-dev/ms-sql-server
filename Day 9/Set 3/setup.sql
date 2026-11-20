
USE TelecomDB;
GO

-- ============================================
-- 1. UPDATE SUBSCRIBERS TABLE
-- ============================================

IF COL_LENGTH('dbo.subscribers', 'subscriber_type') IS NULL
BEGIN
    ALTER TABLE dbo.subscribers
    ADD subscriber_type VARCHAR(20) NOT NULL
        CONSTRAINT DF_subscribers_type DEFAULT 'Prepaid';
END;
GO

IF COL_LENGTH('dbo.subscribers', 'balance') IS NULL
BEGIN
    ALTER TABLE dbo.subscribers
    ADD balance DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_subscribers_balance DEFAULT 30.00;
END;
GO

IF COL_LENGTH('dbo.subscribers', 'validity_end_date') IS NULL
BEGIN
    ALTER TABLE dbo.subscribers
    ADD validity_end_date DATE NULL;
END;
GO

-- ============================================
-- 2. UPDATE PLANS TABLE
-- ============================================

IF COL_LENGTH('dbo.plans', 'validity_days') IS NULL
BEGIN
    ALTER TABLE dbo.plans
    ADD validity_days INT NOT NULL
        CONSTRAINT DF_plans_validity DEFAULT 30;
END;
GO

-- ============================================
-- 3. CREATE RECHARGE HISTORY TABLE
-- ============================================

IF OBJECT_ID('dbo.RechargeHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RechargeHistory
    (
        recharge_id INT IDENTITY(1,1) PRIMARY KEY,
        subscriber_id INT NOT NULL,
        plan_id INT NOT NULL,
        recharge_amount DECIMAL(10,2) NOT NULL,
        recharge_date DATETIME NOT NULL DEFAULT GETDATE(),
        validity_days INT NOT NULL,

        CONSTRAINT FK_RechargeHistory_Subscriber
            FOREIGN KEY (subscriber_id)
            REFERENCES dbo.subscribers(subscriber_id),

        CONSTRAINT FK_RechargeHistory_Plan
            FOREIGN KEY (plan_id)
            REFERENCES dbo.plans(plan_id),

        CONSTRAINT CK_RechargeHistory_Amount
            CHECK (recharge_amount > 0),

        CONSTRAINT CK_RechargeHistory_Validity
            CHECK (validity_days > 0)
    );
END;
GO

-- ============================================
-- 4. CREATE NOTIFICATION LOG TABLE
-- ============================================

IF OBJECT_ID('dbo.NotificationLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NotificationLog
    (
        notification_id INT IDENTITY(1,1) PRIMARY KEY,
        subscriber_id INT NOT NULL,
        message VARCHAR(255) NOT NULL,
        notification_date DATETIME NOT NULL DEFAULT GETDATE(),
        is_read BIT NOT NULL DEFAULT 0,

        CONSTRAINT FK_NotificationLog_Subscriber
            FOREIGN KEY (subscriber_id)
            REFERENCES dbo.subscribers(subscriber_id)
    );
END;
GO

-- ============================================
-- 5. VERIFY DATABASE SETUP
-- ============================================

SELECT * FROM dbo.subscribers;
SELECT * FROM dbo.plans;
SELECT * FROM dbo.RechargeHistory;
SELECT * FROM dbo.NotificationLog;
GO

PRINT 'TelecomDB setup completed successfully.';
GO
