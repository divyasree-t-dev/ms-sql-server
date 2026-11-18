
// ============================================================
// DAY 7 - SET 2: BANK LOAN PORTFOLIO
// MongoDB 8.0
// File: reports.js
// ============================================================

use("BankLoanDB");

// ============================================================
// PIPELINE 1: Loans with Customer Details
// Concept: $lookup and $unwind
// ============================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "CustomerDetails"
        }
    },
    {
        $unwind: "$CustomerDetails"
    },
    {
        $project: {
            _id: 0,
            LoanID: 1,
            LoanAmount: 1,
            InterestRate: 1,
            LoanStatus: 1,
            CustomerName: "$CustomerDetails.CustomerName",
            Email: "$CustomerDetails.Email",
            City: "$CustomerDetails.City"
        }
    }
]);

// ============================================================
// PIPELINE 2: Loans with Customer and Repayment Details
// Concept: Multiple $lookup operations
// ============================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "CustomerDetails"
        }
    },
    {
        $lookup: {
            from: "repayments",
            localField: "LoanID",
            foreignField: "LoanID",
            as: "RepaymentDetails"
        }
    },
    {
        $unwind: "$CustomerDetails"
    },
    {
        $project: {
            _id: 0,
            LoanID: 1,
            LoanAmount: 1,
            LoanStatus: 1,
            CustomerName: "$CustomerDetails.CustomerName",
            Repayments: "$RepaymentDetails",
            TotalRepayments: {
                $sum: "$RepaymentDetails.Amount"
            },
            RepaymentCount: {
                $size: "$RepaymentDetails"
            }
        }
    }
]);

// ============================================================
// PIPELINE 3: Get the Last Repayment for Each Loan
// Concept: $lookup with pipeline, $sort and $limit
// ============================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "CustomerDetails"
        }
    },
    {
        $lookup: {
            from: "repayments",
            let: {
                loanId: "$LoanID"
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$LoanID", "$$loanId"]
                        }
                    }
                },
                {
                    $sort: {
                        RepaymentDate: -1,
                        RepaymentID: -1
                    }
                },
                {
                    $limit: 1
                }
            ],
            as: "LastRepayment"
        }
    },
    {
        $unwind: "$CustomerDetails"
    },
    {
        $project: {
            _id: 0,
            LoanID: 1,
            LoanAmount: 1,
            CustomerName: "$CustomerDetails.CustomerName",
            LastRepayment: {
                $arrayElemAt: ["$LastRepayment", 0]
            }
        }
    }
]);

// ============================================================
// END OF DAY 7 - SET 2
// ============================================================
