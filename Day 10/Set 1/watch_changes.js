
// =============================================
// DAY 10 - SET 1
// MONGODB CHANGE STREAM
// File: watch_changes.js
// =============================================

const { MongoClient } = require("mongodb");

const uri =
    process.env.MONGODB_URI ||
    "mongodb://localhost:27017/?replicaSet=rs0";

const client = new MongoClient(uri);

async function watchPriceChanges() {
    try {
        await client.connect();

        console.log("Connected to MongoDB.");

        const database = client.db("RetailDB");
        const products = database.collection("products");

        // Watch price field updates
        const changeStream = products.watch(
            [
                {
                    $match: {
                        operationType: "update",
                        "updateDescription.updatedFields.price": {
                            $exists: true
                        }
                    }
                }
            ],
            {
                fullDocument: "updateLookup"
            }
        );

        console.log("Watching product price changes...");

        for await (const change of changeStream) {
            console.log("\nPRICE CHANGE DETECTED");

            console.log("Product ID:", change.documentKey._id);

            console.log(
                "New Price:",
                change.fullDocument?.price
            );

            console.log(
                "Updated Fields:",
                change.updateDescription.updatedFields
            );

            console.log("Time:", new Date());
            console.log("-----------------------------");
        }

    } catch (error) {
        console.error("Change stream error:", error);
    } finally {
        await client.close();
    }
}

watchPriceChanges();
