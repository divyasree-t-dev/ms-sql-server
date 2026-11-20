
// Select database
use InsuranceDB;

// TASK 5: CREATE VIEW FOR UNRESOLVED COMPLAINTS

db.createView(
    "unresolved_complaints",
    "customer_communications",
    [
        {
            $match: {
                communication_type: "Complaint",
                status: "Unresolved"
            }
        }
    ]
);

// TEST THE VIEW
db.unresolved_complaints.find().pretty();

// COUNT UNRESOLVED COMPLAINTS
db.unresolved_complaints.countDocuments();
