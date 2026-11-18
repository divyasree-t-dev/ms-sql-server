use("LogisticsDB");

// Pipeline 1 – Shipments with Delivery Events
db.shipments.aggregate([
  
  {
    $lookup: {
      from: "deliveryEvents",
      localField: "ShipmentID",
      foreignField: "ShipmentID",
      as: "DeliveryEvents"
    }
  },
  {
    $project: {
      _id: 0,
      ShipmentID: 1,
      CustomerID: 1,
      CarrierID: 1,
      Status: 1,
      ShippingCost: 1,
      DeliveryEvents: 1
    }
  },
  {
    $sort: {
      ShipmentID: 1
    }
  }

]);

// Pipeline 2 – Customers with Their Shipments
db.customers.aggregate([
  
  {
    $lookup: {
      from: "shipments",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "CustomerShipments"
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: 1,
      CustomerName: 1,
      Email: 1,
      City: 1,
      TotalShipments: {
        $size: "$CustomerShipments"
      },
      CustomerShipments: 1
    }
  },
  {
    $sort: {
      CustomerName: 1
    }
  }

]);

// Pipeline 3 – Carrier Delivery Statistics
db.carriers.aggregate([
  
  {
    $lookup: {
      from: "shipments",
      localField: "CarrierID",
      foreignField: "CarrierID",
      as: "CarrierShipments"
    }
  },
  {
    $unwind: "$CarrierShipments"
  },
  {
    $match: {
      "CarrierShipments.DeliveryDate": { $ne: null }
    }
  },
  {
    $addFields: {
      DeliveryDays: {
        $dateDiff: {
          startDate: {
            $dateFromString: {
              dateString: "$CarrierShipments.ShipmentDate"
            }
          },
          endDate: {
            $dateFromString: {
              dateString: "$CarrierShipments.DeliveryDate"
            }
          },
          unit: "day"
        }
      }
    }
  },
  {
    $group: {
      _id: "$CarrierID",
      CarrierName: { $first: "$CarrierName" },
      DeliveredShipments: { $sum: 1 },
      AverageDeliveryDays: { $avg: "$DeliveryDays" },
      MaximumDeliveryDays: { $max: "$DeliveryDays" },
      MinimumDeliveryDays: { $min: "$DeliveryDays" }
    }
  },
  {
    $project: {
      _id: 0,
      CarrierID: "$_id",
      CarrierName: 1,
      DeliveredShipments: 1,
      AverageDeliveryDays: {
        $round: ["$AverageDeliveryDays", 2]
      },
      MaximumDeliveryDays: 1,
      MinimumDeliveryDays: 1
    }
  },
  {
    $sort: {
      AverageDeliveryDays: -1
    }
  }

]);