
// DAY 7 - SET 3
// RETAIL RETURNS AND REFUNDS
// MongoDB 8.0

use("RetailReturnsDB");

// =========================================
// 1. SAMPLE COLLECTION DATA
// =========================================

db.stores.insertMany([
  { StoreID: 1, StoreName: "Chennai Central", Region: "South" },
  { StoreID: 2, StoreName: "Coimbatore Store", Region: "South" },
  { StoreID: 3, StoreName: "Bangalore Store", Region: "South" }
]);

db.employees.insertMany([
  { EmployeeID: 101, EmployeeName: "Ravi Kumar", ManagerID: null, StoreID: 1 },
  { EmployeeID: 102, EmployeeName: "Arun Kumar", ManagerID: 101, StoreID: 1 },
  { EmployeeID: 103, EmployeeName: "Priya Sharma", ManagerID: 101, StoreID: 2 },
  { EmployeeID: 104, EmployeeName: "Karthik Raj", ManagerID: 103, StoreID: 3 }
]);

db.customers.insertMany([
  { CustomerID: 1, CustomerName: "Divya", City: "Chennai" },
  { CustomerID: 2, CustomerName: "Arun", City: "Coimbatore" },
  { CustomerID: 3, CustomerName: "Karthik", City: "Bangalore" },
  { CustomerID: 4, CustomerName: "Meena", City: "Chennai" }
]);

db.products.insertMany([
  { ProductID: 101, ProductName: "Laptop", Category: "Electronics" },
  { ProductID: 102, ProductName: "Headphones", Category: "Electronics" },
  { ProductID: 103, ProductName: "Smart Watch", Category: "Accessories" },
  { ProductID: 104, ProductName: "Backpack", Category: "Accessories" }
]);

db.sales.insertMany([
  {
    SaleID: 1001, ProductID: 101, CustomerID: 1,
    StoreID: 1, EmployeeID: 102,
    SaleDate: ISODate("2026-01-05"),
    Quantity: 10, UnitPrice: 50000
  },
  {
    SaleID: 1002, ProductID: 101, CustomerID: 2,
    StoreID: 2, EmployeeID: 103,
    SaleDate: ISODate("2026-01-06"),
    Quantity: 10, UnitPrice: 50000
  },
  {
    SaleID: 1003, ProductID: 102, CustomerID: 1,
    StoreID: 1, EmployeeID: 102,
    SaleDate: ISODate("2026-01-07"),
    Quantity: 10, UnitPrice: 2000
  },
  {
    SaleID: 1004, ProductID: 103, CustomerID: 3,
    StoreID: 2, EmployeeID: 103,
    SaleDate: ISODate("2026-01-08"),
    Quantity: 5, UnitPrice: 8000
  },
  {
    SaleID: 1005, ProductID: 103, CustomerID: 4,
    StoreID: 3, EmployeeID: 104,
    SaleDate: ISODate("2026-01-09"),
    Quantity: 5, UnitPrice: 8000
  },
  {
    SaleID: 1006, ProductID: 104, CustomerID: 2,
    StoreID: 3, EmployeeID: 104,
    SaleDate: ISODate("2026-01-10"),
    Quantity: 10, UnitPrice: 1500
  },
  {
    SaleID: 1007, ProductID: 104, CustomerID: 3,
    StoreID: 1, EmployeeID: 102,
    SaleDate: ISODate("2026-01-11"),
    Quantity: 5, UnitPrice: 1500
  }
]);

db.returns.insertMany([
  {
    ReturnID: 5001, SaleID: 1001, CustomerID: 1,
    ReturnDate: ISODate("2026-01-12"),
    ReturnQty: 2, Reason: "Damaged product"
  },
  {
    ReturnID: 5002, SaleID: 1002, CustomerID: 2,
    ReturnDate: ISODate("2026-01-13"),
    ReturnQty: 1, Reason: "Wrong item"
  },
  {
    ReturnID: 5003, SaleID: 1003, CustomerID: 1,
    ReturnDate: ISODate("2026-01-14"),
    ReturnQty: 2, Reason: "Not satisfied"
  },
  {
    ReturnID: 5004, SaleID: 1005, CustomerID: 4,
    ReturnDate: ISODate("2026-01-15"),
    ReturnQty: 1, Reason: "Quality issue"
  },
  {
    ReturnID: 5005, SaleID: 1007, CustomerID: null,
    ReturnDate: ISODate("2026-01-16"),
    ReturnQty: 1, Reason: "Legacy record"
  }
]);

db.refunds.insertMany([
  {
    RefundID: 6001, ReturnID: 5001,
    RefundAmount: 100000,
    RefundDate: ISODate("2026-01-13"),
    RefundStatus: "Processed"
  },
  {
    RefundID: 6002, ReturnID: 5002,
    RefundAmount: 50000,
    RefundDate: ISODate("2026-01-14"),
    RefundStatus: "Processed"
  },
  {
    RefundID: 6003, ReturnID: 5003,
    RefundAmount: 4000,
    RefundDate: ISODate("2026-01-15"),
    RefundStatus: "Processed"
  }
]);

db.returnsFeedback.insertMany([
  {
    FeedbackID: 7001, ReturnID: 5001,
    Rating: 2,
    Comments: "Product was damaged",
    FeedbackDate: ISODate("2026-01-13")
  },
  {
    FeedbackID: 7002, ReturnID: 5002,
    Rating: 3,
    Comments: "Received wrong item",
    FeedbackDate: ISODate("2026-01-14")
  },
  {
    FeedbackID: 7003, ReturnID: 5003,
    Rating: 2,
    Comments: "Not satisfied with quality",
    FeedbackDate: ISODate("2026-01-15")
  },
  {
    FeedbackID: 7004, ReturnID: 5004,
    Rating: 1,
    Comments: "Poor product quality",
    FeedbackDate: ISODate("2026-01-16")
  }
]);

// =========================================
// 2. AGGREGATION PIPELINES
// =========================================

// PIPELINE 1:
// Return details with customer, product
// and feedback information.

db.returns.aggregate([
  {
    $lookup: {
      from: "sales",
      localField: "SaleID",
      foreignField: "SaleID",
      as: "SaleDetails"
    }
  },
  {
    $unwind: "$SaleDetails"
  },
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
      from: "products",
      localField: "SaleDetails.ProductID",
      foreignField: "ProductID",
      as: "ProductDetails"
    }
  },
  {
    $lookup: {
      from: "returnsFeedback",
      localField: "ReturnID",
      foreignField: "ReturnID",
      as: "FeedbackDetails"
    }
  },
  {
    $project: {
      _id: 0,
      ReturnID: 1,
      ReturnQty: 1,
      Reason: 1,
      CustomerName: {
        $arrayElemAt: ["$CustomerDetails.CustomerName", 0]
      },
      ProductName: {
        $arrayElemAt: ["$ProductDetails.ProductName", 0]
      },
      Feedback: "$FeedbackDetails"
    }
  }
]);


// PIPELINE 2:
// Store-wise total refund report
// with store and return feedback details.

db.stores.aggregate([
  {
    $lookup: {
      from: "sales",
      localField: "StoreID",
      foreignField: "StoreID",
      as: "SalesDetails"
    }
  },
  {
    $unwind: "$SalesDetails"
  },
  {
    $lookup: {
      from: "returns",
      localField: "SalesDetails.SaleID",
      foreignField: "SaleID",
      as: "ReturnDetails"
    }
  },
  {
    $unwind: "$ReturnDetails"
  },
  {
    $lookup: {
      from: "refunds",
      localField: "ReturnDetails.ReturnID",
      foreignField: "ReturnID",
      as: "RefundDetails"
    }
  },
  {
    $unwind: "$RefundDetails"
  },
  {
    $lookup: {
      from: "returnsFeedback",
      localField: "ReturnDetails.ReturnID",
      foreignField: "ReturnID",
      as: "FeedbackDetails"
    }
  },
  {
    $group: {
      _id: {
        StoreID: "$StoreID",
        StoreName: "$StoreName",
        Region: "$Region"
      },
      TotalRefund: {
        $sum: "$RefundDetails.RefundAmount"
      },
      RefundCount: {
        $sum: 1
      },
      FeedbackCount: {
        $sum: {
          $size: "$FeedbackDetails"
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      StoreID: "$_id.StoreID",
      StoreName: "$_id.StoreName",
      Region: "$_id.Region",
      TotalRefund: 1,
      RefundCount: 1,
      FeedbackCount: 1
    }
  },
  {
    $sort: {
      TotalRefund: -1
    }
  }
]);


// PIPELINE 3:
// Customers who returned products
// without receiving a refund.
// Includes return feedback details.

db.customers.aggregate([
  {
    $lookup: {
      from: "returns",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "ReturnDetails"
    }
  },
  {
    $unwind: "$ReturnDetails"
  },
  {
    $lookup: {
      from: "refunds",
      localField: "ReturnDetails.ReturnID",
      foreignField: "ReturnID",
      as: "RefundDetails"
    }
  },
  {
    $match: {
      "RefundDetails.0": {
        $exists: false
      }
    }
  },
  {
    $lookup: {
      from: "returnsFeedback",
      localField: "ReturnDetails.ReturnID",
      foreignField: "ReturnID",
      as: "FeedbackDetails"
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: 1,
      CustomerName: 1,
      ReturnID: "$ReturnDetails.ReturnID",
      ReturnReason: "$ReturnDetails.Reason",
      ReturnQty: "$ReturnDetails.ReturnQty",
      Feedback: "$FeedbackDetails"
    }
  }
]);

// END OF SCRIPT
