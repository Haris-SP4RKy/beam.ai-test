-- Create a schema for the order management app
USE Beam;

-- Create a table for products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL
);

-- Create a table for orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDate DATE NOT NULL,
    CustomerEmail VARCHAR(255) NOT NULL,
    OrderStatus INT DEFAULT 0
);

-- Create a table for order items (to represent products in each order)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create a table for stock transactions (to track changes in stock quantity)
CREATE TABLE StockTransactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    TransactionDate DATE NOT NULL,
    QuantityChange INT NOT NULL,
    NewStockQuantity INT NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);



INSERT INTO Products ( ProductName, Price, StockQuantity)
VALUES
    ( 'Product A', 19.99, 100),
    ( 'Product B', 29.99, 50),
    ( 'Product C', 9.99, 200),
 ( 'Product D', 9.99, 200);


INSERT INTO Orders ( OrderDate, CustomerEmail, OrderStatus)
VALUES
    ( '2023-01-15', 'customer1@example.com', 1),
    ( '2023-01-16', 'customer2@example.com', 0),
    ( '2023-01-17', 'customer3@example.com', 1),
       ( '2023-01-17', 'customer4@example.com', 1)


INSERT INTO OrderItems ( OrderID, ProductID, Quantity, TotalPrice)
VALUES
    ( 1, 1, 2, 39.98),
    ( 1, 2, 1, 29.99),
    ( 2, 3, 5, 49.95),
    ( 3, 1, 1, 19.99),
    ( 3, 3, 3, 29.97);


INSERT INTO StockTransactions (  ProductID,TransactionDate, QuantityChange, NewStockQuantity)
VALUES
    ( 1, '2023-01-15', -2, 98),
    ( 2, '2023-01-15', -1, 49),
    ( 3, '2023-01-15', -5, 195),
    ( 1, '2023-01-16', 1, 99),
    ( 3, '2023-01-16', 2, 197),
    ( 2, '2023-01-17', 5, 54);

