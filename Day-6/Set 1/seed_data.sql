
USE RetailDB;
GO

-- Create Payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT UNIQUE,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
GO

-- 1. Insert Customers
INSERT INTO customers VALUES
(1, 'Arun Kumar', 'Chennai', 'arun@gmail.com'),
(2, 'Priya', 'Chennai', 'priya@gmail.com'),
(3, 'Karthik', 'Bangalore', 'karthik@gmail.com'),
(4, 'Divya', 'Mumbai', 'divya@gmail.com'),
(5, 'Rahul', 'Madurai', 'rahul@gmail.com'),
(6, 'Sneha', 'Coimbatore', 'sneha@gmail.com'),
(7, 'Vijay', 'Hyderabad', 'vijay@gmail.com'),
(8, 'Meena', 'Salem', 'meena@gmail.com');
GO

-- 2. Insert Products
INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 50000),
(2, 'Mouse', 'Electronics', 500),
(3, 'T-Shirt', 'Clothing', 800),
(4, 'Office Chair', 'Furniture', 5000),
(5, 'Rice Bag', 'Grocery', 100),
(6, 'Smartphone', 'Electronics', 20000);
GO

-- 3. Insert Orders
INSERT INTO orders VALUES
(101, 1, '2025-01-05', 'Paid'),
(102, 1, '2025-01-10', 'Paid'),
(103, 1, '2025-02-03', NULL),
(104, 1, '2025-03-15', 'Paid'),
(105, 2, '2025-01-05', 'Paid'),
(106, 2, '2025-02-14', NULL),
(107, 3, '2025-01-20', 'Paid'),
(108, 3, '2025-03-20', NULL),
(109, 4, '2025-02-02', 'Paid'),
(110, 5, '2025-03-01', 'Paid'),
(111, 6, '2025-03-10', NULL),
(112, 7, '2025-03-18', 'Paid');
GO

-- 4. Insert Order Items
INSERT INTO order_items VALUES
(1, 101, 1, 1, 50000),
(2, 101, 2, 2, 500),
(3, 102, 3, 3, 800),
(4, 103, 1, 1, 50000),
(5, 103, 4, 1, 5000),
(6, 104, 5, 5, 100),
(7, 105, 2, 1, 500),
(8, 105, 3, 2, 800),
(9, 106, 6, 1, 20000),
(10, 107, 6, 1, 20000),
(11, 107, 2, 1, 500),
(12, 108, 3, 1, 800),
(13, 108, 5, 10, 100),
(14, 109, 4, 2, 5000),
(15, 110, 5, 20, 100),
(16, 111, 6, 1, 20000),
(17, 112, 3, 2, 800);
GO

-- 5. Insert Payments
INSERT INTO payments VALUES
(1, 101, '2025-01-05', 51000, 'UPI'),
(2, 102, '2025-01-10', 2400, 'Card'),
(3, 104, '2025-03-15', 500, 'UPI'),
(4, 105, '2025-01-05', 2100, 'Cash'),
(5, 107, '2025-01-20', 20500, 'Card'),
(6, 109, '2025-02-02', 10000, 'UPI'),
(7, 110, '2025-03-01', 2000, 'Cash'),
(8, 112, '2025-03-18', 1600, 'UPI');
GO


SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;