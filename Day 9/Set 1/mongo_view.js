
// =====================================================
// DAY 9 - SET 1
// MONGODB VIEW - ORDER STATUS SUMMARY
// =====================================================

// Select database
db = db.getSiblingDB("RetailDB");

// Create sample collection
db.day9_orders_sample.deleteMany({});

// Insert sample order documents
db.day9_orders_sample.insertMany([
    {
        order_id: 101,
        customer_name: "Arun Kumar",
        order_status: "Pending",
        total_amount: 51000
    },
    {
        order_id: 102,
        customer_name: "Priya",
        order_status: "Completed",
        total_amount: 25000
    },
    {
        order_id: 103,
        customer_name: "Karthik",
        order_status: "Shipped",
        total_amount: 20500
    },
    {
        order_id: 104,
        customer_name: "Divya",
        order_status: "Pending",
        total_amount: 10000
    },
    {
        order_id: 105,
        customer_name: "Rahul",
        order_status: "Cancelled",
        total_amount: 2000
    },
    {
        order_id: 106,
        customer_name: "Sneha",
        order_status: "Completed",
        total_amount: 30000
    }
]);

// Remove existing view if it exists
const existingView = db.getCollectionInfos({
    name: "order_status_counts"
})[0];

if (existingView && existingView.type === "view") {
    db.order_status_counts.drop();
}

// Create MongoDB view
db.createView(
    "order_status_counts",
    "day9_orders_sample",
    [
        {
            $group: {
                _id: "$order_status",
                total_orders: { $sum: 1 },
                total_amount: { $sum: "$total_amount" }
            }
        },
        {
            $project: {
                _id: 0,
                order_status: "$_id",
                total_orders: 1,
                total_amount: 1
            }
        },
        {
            $sort: {
                order_status: 1
            }
        }
    ]
);

// Display view results
print("Order Status Summary:");

db.order_status_counts.find().forEach(printjson);

// Verify view creation
print("Collection Information:");

printjson(
    db.getCollectionInfos({
        name: "order_status_counts"
    })
);
