USE RetailInventoryDB;
GO

INSERT INTO Category (category_id, category_name)
VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Furniture'),
(4, 'Clothing'),
(5, 'Footwear'),
(6, 'Books'),
(7, 'Home Appliances'),
(8, 'Sports'),
(9, 'Toys'),
(10, 'Beauty');
GO

INSERT INTO Supplier
(supplier_id, supplier_name, supplier_phone)
VALUES
(1, 'ABC Traders', '9876543210'),
(2, 'XYZ Suppliers', '9876543211'),
(3, 'Global Distributors', '9876543212'),
(4, 'Prime Supplies', '9876543213'),
(5, 'Metro Wholesale', '9876543214'),
(6, 'Smart Products', '9876543215'),
(7, 'City Traders', '9876543216'),
(8, 'Universal Supply', '9876543217'),
(9, 'Elite Distributors', '9876543218'),
(10, 'Sunrise Suppliers', '9876543219');
GO

INSERT INTO Warehouse
(warehouse_id, warehouse_name, location)
VALUES
(1, 'Chennai Central', 'Chennai'),
(2, 'Bangalore Hub', 'Bangalore'),
(3, 'Mumbai Storage', 'Mumbai'),
(4, 'Delhi Warehouse', 'Delhi'),
(5, 'Hyderabad Hub', 'Hyderabad'),
(6, 'Coimbatore Storage', 'Coimbatore'),
(7, 'Pune Warehouse', 'Pune'),
(8, 'Kochi Hub', 'Kochi'),
(9, 'Kolkata Storage', 'Kolkata'),
(10, 'Jaipur Warehouse', 'Jaipur');
GO

INSERT INTO Product
(sku, product_name, category_id, supplier_id, reorder_level)
VALUES
('P101', 'Laptop', 1, 1, 5),
('P102', 'Wireless Mouse', 2, 2, 10),
('P103', 'Office Chair', 3, 3, 8),
('P104', 'Cotton Shirt', 4, 4, 15),
('P105', 'Running Shoes', 5, 5, 10),
('P106', 'Python Programming Book', 6, 6, 5),
('P107', 'Microwave Oven', 7, 7, 4),
('P108', 'Cricket Bat', 8, 8, 6),
('P109', 'Toy Car', 9, 9, 12),
('P110', 'Face Wash', 10, 10, 8);
GO

INSERT INTO Inventory
(inventory_id, sku, warehouse_id, quantity)
VALUES
(1, 'P101', 1, 25),
(2, 'P102', 2, 50),
(3, 'P103', 3, 30),
(4, 'P104', 4, 45),
(5, 'P105', 5, 20),
(6, 'P106', 6, 60),
(7, 'P107', 7, 15),
(8, 'P108', 8, 35),
(9, 'P109', 9, 40),
(10, 'P110', 10, 55);
GO

SELECT * FROM Category;
SELECT * FROM Supplier;
SELECT * FROM Warehouse;
SELECT * FROM Product;
SELECT * FROM Inventory;
GO


INSERT INTO Category (category_id, category_name)
VALUES (1, 'Duplicate Electronics');

INSERT INTO Product
(sku, product_name, category_id, supplier_id, reorder_level)
VALUES
('P999', 'Gaming Monitor', 999, 1, 5);

INSERT INTO Inventory
(inventory_id, sku, warehouse_id, quantity)
VALUES
(11, 'P101', 2, -10);

INSERT INTO Supplier
(supplier_id, supplier_name, supplier_phone)
VALUES
(11, NULL, '9876543220');
