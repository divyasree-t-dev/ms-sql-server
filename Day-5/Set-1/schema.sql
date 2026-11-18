
-- ============================================
-- SET 1: RETAIL INVENTORY DATABASE
-- TASK 2: DATABASE AND TABLE CREATION
-- SQL SERVER 2025
-- ============================================

-- 1. Create Database
CREATE DATABASE RetailInventoryDB;
GO

-- 2. Select Database
USE RetailInventoryDB;
GO

-- 3. Create Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
GO

-- 4. Create Supplier Table
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_phone VARCHAR(15) NOT NULL UNIQUE
);
GO

-- 5. Create Warehouse Table
CREATE TABLE Warehouse (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);
GO

-- 6. Create Product Table
CREATE TABLE Product (
    sku VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,

    category_id INT NOT NULL,
    supplier_id INT NOT NULL,

    reorder_level INT NOT NULL
        CONSTRAINT DF_Product_ReorderLevel DEFAULT 0,

    CONSTRAINT CHK_Product_ReorderLevel
        CHECK (reorder_level >= 0),

    CONSTRAINT FK_Product_Category
        FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    CONSTRAINT FK_Product_Supplier
        FOREIGN KEY (supplier_id)
        REFERENCES Supplier(supplier_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

-- 7. Create Inventory Table
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    sku VARCHAR(20) NOT NULL,
    warehouse_id INT NOT NULL,

    quantity INT NOT NULL
        CONSTRAINT DF_Inventory_Quantity DEFAULT 0,

    CONSTRAINT CHK_Inventory_Quantity
        CHECK (quantity >= 0),

    CONSTRAINT UQ_Inventory_SKU_Warehouse
        UNIQUE (sku, warehouse_id),

    CONSTRAINT FK_Inventory_Product
        FOREIGN KEY (sku)
        REFERENCES Product(sku)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    CONSTRAINT FK_Inventory_Warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES Warehouse(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

-- 8. Verify Table Creation
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

-- ============================================
-- VERIFY TABLE STRUCTURES
-- ============================================

USE RetailInventoryDB;
GO

EXEC sp_help 'Category';
EXEC sp_help 'Supplier';
EXEC sp_help 'Warehouse';
EXEC sp_help 'Product';
EXEC sp_help 'Inventory';
GO