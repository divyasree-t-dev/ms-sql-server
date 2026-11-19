
# Day 8 - Set 2: Airline Seat Booking

## Objective

To implement a reliable airline seat booking system using SQL Server transactions and MongoDB multi-document transactions.

## 1. SQL Server Booking Transaction

The booking operation consists of three steps:

1. Check whether the selected seat is available.
2. Insert the passenger booking record.
3. Update the seat status to Booked.

All three operations execute inside a single transaction.

TRY...CATCH handles errors. If any operation fails, ROLLBACK ensures that partial changes are not saved.

## 2. Concurrent Booking Behaviour

Two customers attempt to book the same seat simultaneously.

### READ COMMITTED

- Both sessions can initially read the seat as Available because the shared read lock is released after the SELECT statement.
- Both customers may attempt to insert a booking.
- The unique constraint on SeatID prevents duplicate bookings.
- One transaction succeeds, while the other fails when it attempts to insert the same seat.

### SERIALIZABLE

- The transaction holds the necessary locks until it completes.
- The second session waits while the first transaction is active.
- After the first transaction commits, the second session finds that the seat is already booked.
- Only one booking is completed.

### Observation

SERIALIZABLE provides stronger isolation and prevents the concurrent availability-check race. The unique constraint provides an additional layer of protection.

## 3. RANK() and DENSE_RANK()

Both functions rank passengers based on their fare within each flight.

- RANK(): Assigns the same rank to tied fares and skips the next rank.
- DENSE_RANK(): Assigns the same rank to tied fares without skipping the next rank.

Example:

| Fare | RANK | DENSE_RANK |
|------|------|------------|
| 7000 | 1 | 1 |
| 7000 | 1 | 1 |
| 5000 | 3 | 2 |

## 4. CTE and Running Revenue

A Common Table Expression (CTE) makes the ranking query easier to read and maintain.

SUM() OVER() calculates the cumulative revenue for each flight using a window function.

PARTITION BY separates revenue calculations for different flights.

## 5. MongoDB Transaction

MongoDB uses a session and withTransaction() to execute the seat update and booking insertion atomically.

If either operation fails, the transaction is aborted.

The seat update uses a conditional filter to ensure that only an Available seat can be reserved.

## Conclusion

SQL Server transactions and MongoDB multi-document transactions ensure data consistency during airline seat booking.

Isolation levels, locking, unique constraints and transaction rollback help prevent duplicate bookings and maintain data integrity.
