
// =============================================
// DAY 10 - SET 2
// MONGODB CHANGE STREAM
// File: watch_alerts.js
// =============================================

const { MongoClient } = require("mongodb");

const uri =
    process.env.MONGODB_URI ||
    "mongodb://localhost:27017/?replicaSet=rs0";

const client = new MongoClient(uri);

async function watchFraudAlerts() {
    try {
        await client.connect();

        console.log("Connected to MongoDB.");

        const database = client.db("BankDB");

        const fraudAlerts =
            database.collection("fraud_alerts");

        // Watch every INSERT operation
        const changeStream = fraudAlerts.watch([
            {
                $match: {
                    operationType: "insert"
                }
            }
        ]);

        console.log("Watching for new fraud alerts...");

        for await (const change of changeStream) {

            const alert = change.fullDocument;

            console.log("\nNEW FRAUD ALERT DETECTED");

            console.log("Alert ID:", change.documentKey._id);

            console.log("Account ID:", alert.account_id);

            console.log("Alert Type:", alert.alert_type);

            console.log("Description:", alert.description);

            console.log("Amount:", alert.amount);

            console.log("Time:", new Date());

            console.log("-----------------------------");
        }

    } catch (error) {

        console.error("Change stream error:", error);

    } finally {

        await client.close();

    }
}

watchFraudAlerts();
