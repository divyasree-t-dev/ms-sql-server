-- =========================================
-- 0. CREATE DATABASE
-- =========================================

CREATE DATABASE AirlineBookingDB;
GO

USE AirlineBookingDB;
GO


-- DAY 8 - SET 2
-- AIRLINE SEAT BOOKING
-- SQL SERVER 2025

-- =========================================
-- 1. CREATE TABLES
-- =========================================

CREATE TABLE Flights (
    FlightID INT PRIMARY KEY,
    FlightName VARCHAR(100)
);

CREATE TABLE Passengers (
    PassengerID INT PRIMARY KEY,
    PassengerName VARCHAR(100)
);

CREATE TABLE Seats (
    SeatID INT PRIMARY KEY,
    FlightID INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    SeatStatus VARCHAR(20) DEFAULT 'Available',
    CONSTRAINT FK_Seats_Flights
        FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    CONSTRAINT UQ_Flight_Seat
        UNIQUE (FlightID, SeatNumber)
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    PassengerID INT NOT NULL,
    FlightID INT NOT NULL,
    SeatID INT NOT NULL,
    Fare DECIMAL(10,2),
    BookingDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Bookings_Passengers
        FOREIGN KEY (PassengerID) REFERENCES Passengers(PassengerID),

    CONSTRAINT FK_Bookings_Flights
        FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),

    CONSTRAINT FK_Bookings_Seats
        FOREIGN KEY (SeatID) REFERENCES Seats(SeatID),

    CONSTRAINT UQ_Booking_Seat UNIQUE (SeatID)
);

-- =========================================
-- 2. INSERT SAMPLE DATA
-- =========================================

INSERT INTO Flights VALUES
(101, 'Chennai to Delhi'),
(102, 'Chennai to Mumbai');

INSERT INTO Passengers VALUES
(1, 'Arun'),
(2, 'Priya'),
(3, 'Karthik'),
(4, 'Divya');

INSERT INTO Seats VALUES
(1, 101, 'A1', 'Available'),
(2, 101, 'A2', 'Available'),
(3, 101, 'A3', 'Available'),
(4, 102, 'B1', 'Available'),
(5, 102, 'B2', 'Available');

-- =========================================
-- 3. BOOKING TRANSACTION
-- =========================================
GO

CREATE OR ALTER PROCEDURE BookSeat
    @PassengerID INT,
    @FlightID INT,
    @SeatID INT,
    @Fare DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        BEGIN TRANSACTION;

        -- Check and lock the selected seat
        IF NOT EXISTS (
            SELECT 1
            FROM Seats WITH (UPDLOCK, HOLDLOCK)
            WHERE SeatID = @SeatID
              AND FlightID = @FlightID
              AND SeatStatus = 'Available'
        )
        BEGIN
            THROW 50001, 'Seat is already booked or unavailable.', 1;
        END;

        -- Insert booking record
        INSERT INTO Bookings
        (PassengerID, FlightID, SeatID, Fare)
        VALUES
        (@PassengerID, @FlightID, @SeatID, @Fare);

        -- Update seat status
        UPDATE Seats
        SET SeatStatus = 'Booked'
        WHERE SeatID = @SeatID
          AND FlightID = @FlightID;

        COMMIT TRANSACTION;

        PRINT 'Booking successful!';
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Booking failed: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- =========================================
-- 4. TEST BOOKING TRANSACTION
-- =========================================

EXEC BookSeat
    @PassengerID = 1,
    @FlightID = 101,
    @SeatID = 1,
    @Fare = 5500.00;

-- Attempt to book the same seat again
EXEC BookSeat
    @PassengerID = 2,
    @FlightID = 101,
    @SeatID = 1,
    @Fare = 5500.00;

-- Verify booking details
SELECT * FROM Bookings;

SELECT * FROM Seats;

-- =========================================
-- 5. CONCURRENT BOOKING SIMULATION
-- =========================================

-- SESSION A:
-- Open a separate SQL Server query window.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT *
FROM Seats
WHERE SeatID = 2
  AND SeatStatus = 'Available';

WAITFOR DELAY '00:00:10';

INSERT INTO Bookings
(PassengerID, FlightID, SeatID, Fare)
VALUES (1, 101, 2, 6000.00);

UPDATE Seats
SET SeatStatus = 'Booked'
WHERE SeatID = 2;

COMMIT TRANSACTION;


-- SESSION B:
-- Execute during the 10-second delay in Session A.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT *
FROM Seats
WHERE SeatID = 2
  AND SeatStatus = 'Available';

-- If Session A has already committed,
-- this query returns no available seat.

ROLLBACK TRANSACTION;


-- =========================================
-- 6. SERIALIZABLE SIMULATION
-- =========================================

-- Reset test seat before running this section:
-- UPDATE Seats SET SeatStatus = 'Available'
-- WHERE SeatID = 3;

-- SESSION A:

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

SELECT *
FROM Seats WITH (UPDLOCK, HOLDLOCK)
WHERE SeatID = 3
  AND SeatStatus = 'Available';

WAITFOR DELAY '00:00:10';

INSERT INTO Bookings
(PassengerID, FlightID, SeatID, Fare)
VALUES (1, 101, 3, 6500.00);

UPDATE Seats
SET SeatStatus = 'Booked'
WHERE SeatID = 3;

COMMIT TRANSACTION;


-- SESSION B:
-- Run while Session A is waiting.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

SELECT *
FROM Seats WITH (UPDLOCK, HOLDLOCK)
WHERE SeatID = 3
  AND SeatStatus = 'Available';

-- Session B waits for Session A to finish.
-- After Session A commits, the seat is unavailable.

ROLLBACK TRANSACTION;



SELECT * FROM Flights;
SELECT * FROM Passengers;
SELECT * FROM Seats;
SELECT * FROM Bookings;