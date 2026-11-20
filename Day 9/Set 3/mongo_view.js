// ============================================
// TELECOM LOW-BALANCE NOTIFICATION VIEW
// ============================================

// Select database
use("TelecomMongoDB");

// Create notification-log collection if required
db.createCollection("notification_log");

// ============================================
// INSERT SAMPLE NOTIFICATIONS
// ============================================

db.notification_log.insertMany([
    {
        subscriber_id: 101,
        message: "Your balance is below 50.",
        is_read: false
    },
    {
        subscriber_id: 101,
        message: "Please recharge your account.",
        is_read: false
    },
    {
        subscriber_id: 102,
        message: "Your balance is low.",
        is_read: true
    },
    {
        subscriber_id: 103,
        message: "Recharge required.",
        is_read: false
    },
    {
        subscriber_id: 103,
        message: "Your balance is below 50.",
        is_read: false
    },
    {
        subscriber_id: 104,
        message: "Please recharge your account.",
        is_read: true
    }
]);

// ============================================
// CREATE MONGODB VIEW
// ============================================

db.createView(
    "vw_unread_notification_counts",
    "notification_log",
    [
        {
            $match: {
                is_read: false
            }
        },
        {
            $group: {
                _id: "$subscriber_id",
                unread_count: {
                    $sum: 1
                }
            }
        },
        {
            $project: {
                _id: 0,
                subscriber_id: "$_id",
                unread_count: 1
            }
        },
        {
            $sort: {
                subscriber_id: 1
            }
        }
    ]
);

// ============================================
// DISPLAY VIEW RESULTS
// ============================================

db.vw_unread_notification_counts.find().pretty();

// ============================================
// VERIFY COLLECTION
// ============================================

db.notification_log.find().pretty();

print("MongoDB notification view created successfully.");