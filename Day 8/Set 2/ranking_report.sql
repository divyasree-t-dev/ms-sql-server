
-- DAY 8 - SET 2
-- AIRLINE SEAT BOOKING
-- RANKING REPORT

-- =========================================
-- 1. INSERT ADDITIONAL SAMPLE BOOKINGS
-- =========================================

-- Run these inserts only if the corresponding
-- seats are still available.

EXEC BookSeat 2, 101, 2, 6000.00;
EXEC BookSeat 3, 101, 3, 6000.00;
EXEC BookSeat 4, 102, 4, 4500.00;
EXEC BookSeat 1, 102, 5, 7000.00;

-- =========================================
-- 2. RANK() AND DENSE_RANK()
-- =========================================

SELECT
    f.FlightID,
    f.FlightName,
    p.PassengerName,
    b.Fare,

    RANK() OVER (
        PARTITION BY b.FlightID
        ORDER BY b.Fare DESC
    ) AS FareRank,

    DENSE_RANK() OVER (
        PARTITION BY b.FlightID
        ORDER BY b.Fare DESC
    ) AS DenseFareRank

FROM Bookings b
JOIN Passengers p
    ON b.PassengerID = p.PassengerID
JOIN Flights f
    ON b.FlightID = f.FlightID

ORDER BY
    b.FlightID,
    b.Fare DESC;

-- =========================================
-- 3. CTE WITH RANKING AND RUNNING REVENUE
-- =========================================

WITH PassengerRanking AS
(
    SELECT
        f.FlightID,
        f.FlightName,
        p.PassengerName,
        b.BookingID,
        b.Fare,

        RANK() OVER (
            PARTITION BY b.FlightID
            ORDER BY b.Fare DESC
        ) AS FareRank,

        DENSE_RANK() OVER (
            PARTITION BY b.FlightID
            ORDER BY b.Fare DESC
        ) AS DenseFareRank,

        SUM(b.Fare) OVER (
            PARTITION BY b.FlightID
            ORDER BY b.BookingID
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RunningRevenue

    FROM Bookings b
    JOIN Passengers p
        ON b.PassengerID = p.PassengerID
    JOIN Flights f
        ON b.FlightID = f.FlightID
)

SELECT
    FlightID,
    FlightName,
    PassengerName,
    Fare,
    FareRank,
    DenseFareRank,
    RunningRevenue
FROM PassengerRanking
ORDER BY FlightID, BookingID;
