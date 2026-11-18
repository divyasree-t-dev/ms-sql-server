USE RetailInventoryDB;
GO

-- Check supplier before update
SELECT * FROM Supplier
WHERE supplier_id = 1;

-- Check discontinued product before deletion
SELECT p.sku, p.product_name,
       i.inventory_id, i.warehouse_id, i.quantity
FROM Product p
LEFT JOIN Inventory i ON p.sku = i.sku
WHERE p.sku = 'P110';
GO

UPDATE Supplier
SET supplier_phone = '9000012345'
WHERE supplier_id = 1;

-- Verify updated record
SELECT * FROM Supplier
WHERE supplier_id = 1;
GO

-- Delete inventory record first
DELETE FROM Inventory
WHERE sku = 'P110';

-- Then delete the discontinued product
DELETE FROM Product
WHERE sku = 'P110';

-- Verify deletion
SELECT * FROM Product
WHERE sku = 'P110';

SELECT * FROM Inventory
WHERE sku = 'P110';
GO
