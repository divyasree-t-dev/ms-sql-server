
// DAY 8 - SET 1: MONGODB MULTI-DOCUMENT TRANSACTION
// MongoDB 8.0

const { MongoClient } = require("mongodb");

const uri = "mongodb://localhost:27017/?replicaSet=rs0";

const client = new MongoClient(uri);

async function transferFunds() {
    await client.connect();

    const session = client.startSession();

    const db = client.db("BankDB");

    const accounts = db.collection("accounts");
    const transactions = db.collection("transactions");

    try {
        await session.withTransaction(async () => {

            const fromAccount = await accounts.findOne(
                { accountId: 101, status: "ACTIVE" },
                { session }
            );

            const toAccount = await accounts.findOne(
                { accountId: 102, status: "ACTIVE" },
                { session }
            );

            if (!fromAccount || !toAccount) {
                throw new Error("Invalid or inactive account.");
            }

            const amount = 1000;

            if (fromAccount.balance < amount) {
                throw new Error("Insufficient balance.");
            }

            // Debit source account
            const debit = await accounts.updateOne(
                {
                    accountId: 101,
                    status: "ACTIVE",
                    balance: { $gte: amount }
                },
                {
                    $inc: { balance: -amount }
                },
                { session }
            );

            if (debit.modifiedCount !== 1) {
                throw new Error("Debit failed.");
            }

            // Credit destination account
            const credit = await accounts.updateOne(
                {
                    accountId: 102,
                    status: "ACTIVE"
                },
                {
                    $inc: { balance: amount }
                },
                { session }
            );

            if (credit.modifiedCount !== 1) {
                throw new Error("Credit failed.");
            }

            // Record transaction
            await transactions.insertOne(
                {
                    fromAccount: 101,
                    toAccount: 102,
                    amount: amount,
                    status: "SUCCESS",
                    date: new Date()
                },
                { session }
            );

            console.log("Debit successful.");
            console.log("Credit successful.");
        });

        console.log("Bank transfer completed successfully.");
        console.log("Transaction committed.");

    } catch (error) {
        console.error("Transfer failed:", error.message);
        console.log("Transaction aborted. No partial transfer retained.");

    } finally {
        await session.endSession();
        await client.close();
    }
}

transferFunds();
