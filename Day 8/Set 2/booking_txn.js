
// DAY 8 - SET 2
// AIRLINE SEAT BOOKING
// MONGODB 8.0

const { MongoClient } = require("mongodb");

const uri = "mongodb://localhost:27017/?replicaSet=rs0";

const client = new MongoClient(uri);

async function bookSeat() {

    const session = client.startSession();

    try {

        const database = client.db("AirlineDB");

        const seats = database.collection("Seats");
        const bookings = database.collection("Bookings");

        const passengerId = 1;
        const flightId = 101;
        const seatNumber = "A1";
        const fare = 5500;

        await session.withTransaction(async () => {

            // Check and reserve the available seat
            const seatResult = await seats.updateOne(
                {
                    flightId: flightId,
                    seatNumber: seatNumber,
                    status: "Available"
                },
                {
                    $set: {
                        status: "Booked"
                    }
                },
                {
                    session
                }
            );

            // Check whether the seat was successfully reserved
            if (seatResult.modifiedCount !== 1) {
                throw new Error("Seat is already booked or unavailable.");
            }

            // Insert booking document
            await bookings.insertOne(
                {
                    passengerId: passengerId,
                    flightId: flightId,
                    seatNumber: seatNumber,
                    fare: fare,
                    bookingDate: new Date(),
                    status: "Confirmed"
                },
                {
                    session
                }
            );

            console.log("Seat reserved successfully.");
            console.log("Booking document inserted.");

        }, {
            readConcern: { level: "snapshot" },
            writeConcern: { w: "majority" },
            readPreference: "primary"
        });

        console.log("Transaction committed successfully!");

    } catch (error) {

        console.error("Booking failed:", error.message);

    } finally {

        await session.endSession();

    }
}

async function main() {

    try {

        await client.connect();

        console.log("Connected to MongoDB.");

        await bookSeat();

    } catch (error) {

        console.error("MongoDB Error:", error);

    } finally {

        await client.close();

    }
}

main();
