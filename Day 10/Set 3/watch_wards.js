
// =============================================
// DAY 10 - SET 3
// MONGODB CHANGE STREAM
// File: watch_wards.js
// =============================================

const { MongoClient } = require("mongodb");

const uri =
    process.env.MONGODB_URI ||
    "mongodb://localhost:27017/?replicaSet=rs0";

const client = new MongoClient(uri);

async function watchWardAlerts() {
    try {
        await client.connect();

        console.log("Connected to MongoDB.");

        const database = client.db("HospitalDB");

        const wardAlerts =
            database.collection("ward_alerts");

        // Listen only for new critical alerts
        const changeStream = wardAlerts.watch([
            {
                $match: {
                    operationType: "insert",
                    "fullDocument.severity": "critical"
                }
            }
        ]);

        console.log("Watching for critical ward alerts...");

        for await (const change of changeStream) {

            const alert = change.fullDocument;

            console.log("\nCRITICAL WARD ALERT");

            console.log(
                "Alert ID:",
                change.documentKey._id
            );

            console.log(
                "Ward:",
                alert.ward
            );

            console.log(
                "Severity:",
                alert.severity
            );

            console.log(
                "Time:",
                alert.time || alert.created_at || new Date()
            );

            console.log("-----------------------------");
        }

    } catch (error) {

        console.error("Change stream error:", error);

    } finally {

        await client.close();

    }
}

watchWardAlerts();
