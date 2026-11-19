
// Day 8 - Set 3: Retail Inventory Reservation
// MongoDB 8.0

// Select database
use RetailInventory;

// Sample product document
db.products.insertOne({
    productId: 101,
    productName: "Laptop",
    category: "Electronics",
    stock: 20,
    price: 55000
});

// 1. Atomic stock decrement during order placement

const result = db.products.updateOne(
    {
        productId: 101,
        stock: { $gte: 2 }
    },
    {
        $inc: { stock: -2 }
    }
);

if (result.modifiedCount === 1) {
    print("Stock reserved successfully.");
} else {
    print("Insufficient stock or product not found.");
}

// 2. Check updated stock

db.products.find(
    { productId: 101 },
    { _id: 0, productId: 1, productName: 1, stock: 1 }
);

// 3. Release reserved stock if payment fails

const releaseResult = db.products.updateOne(
    { productId: 101 },
    {
        $inc: { stock: 2 }
    }
);

if (releaseResult.modifiedCount === 1) {
    print("Reserved stock released successfully.");
}

// 4. Verify final stock

db.products.find(
    { productId: 101 },
    { _id: 0, productId: 1, productName: 1, stock: 1 }
);
