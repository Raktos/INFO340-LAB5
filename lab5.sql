-- 1) Write the code to create a new database with your first name followed by your UWNetID (example 'Greg_gthay')
CREATE DATABASE Jason_raktos;

-- 2) Write the code to create the following five tables that include appropriate auto-increment, entity integrity and referential integrity:

-- CUSTOMER
-- ORDER
-- LINE_ITEM
-- PRODUCT
-- PRODUCT_TYPE

CREATE TABLE tblCUSTOMER(
	CustID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	CustFName varchar(60) NOT NULL,
	CustLName varchar(60) NOT NULL,
);

CREATE TABLE tblORDER(
	OrderID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	CustID int FOREIGN KEY REFERENCES tblCUSTOMER(CustID) NOT NULL
);

CREATE TABLE tblPRODUCT_TYPE(
	ProductTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ProductTypeName varchar(60) NOT NULL,
	ProductTyepDesc varchar(500)
)

CREATE TABLE tblPRODUCT(
	ProductID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ProductTypeID int FOREIGN KEY REFERENCES tblPRODUCT_TYPE NOT NULL,
	ProductName varchar(60) NOT NULL,
	Price money NOT NULL,
	ProductDesc varchar(500)
);

CREATE TABLE tblLINE_ITEM(
	ProductID FOREIGN KEY REFERENCES tblPRODUCT(ProductID) NOT NULL,
	OrderID FOREIGN KEY REFERENCES tblORDER(OrderID) NOT NULL,
	qty int NOT NULL,
	CONSTRAINT LineItemPK PRIMARY KEY(ProductID, OrderID)
);

-- 3) Write the code to INSERT 3 rows each in CUSTOMER, PRODUCT and PRODUCT_TYPE
INSERT INTO tblCUSTOMER(CustomerFname,CustomerLname) VALUES('John','Holt');
INSERT INTO tblCUSTOMER(CustomerFname,CustomerLname) VALUES('Bob','Dole');
INSERT INTO tblCUSTOMER(CustomerFname,CustomerLname) VALUES('Jane','Doe');

INSERT INTO tblPRODUCT_TYPE(ProductTypeName,ProductTyepDesc) VALUES('Meat','Animal based foods');
INSERT INTO tblPRODUCT_TYPE(ProductTypeName,ProductTyepDesc) VALUES('Dairy','Things made of dairy');
INSERT INTO tblPRODUCT_TYPE(ProductTypeName,ProductTyepDesc) VALUES('Fruits','Fruit that grow as a plant with seeds');

INSERT INTO tblPRODUCT(ProductTypeID,ProductName,ProductDesc,Price) VALUES('1','Sirloin','Steak that tastes pretty ok',5.00);
INSERT INTO tblPRODUCT(ProductTypeID,ProductName,ProductDesc,Price) VALUES('2','Milk','from a cow',4.00);
INSERT INTO tblPRODUCT(ProductTypeID,ProductName,ProductDesc,Price) VALUES('2','Cheese','it''s cheese man idk',3.00);

-- 4) Write the code to create a stored procedure that will INSERT a new order by accepting the parameters CustomerFname, CustomerLname, ProductName and Quantity. 
CREATE PROCEDURE newOrder(
	@FName varchar(60),
	@LName varchar(60),
	@Product varchar(60),
	@qty int
)
AS
DECLARE @CustID int;
DECLARE @ProductID int;
DECLARE @OrderID int;
BEGIN TRAN orderInsert;
SELECT @CustID = CustID 
	FROM tblCUSTOMER 
	WHERE CustomerFname = @FName AND CustomerLname = @LName;
SELECT @ProductID = ProductID
	FROM tblPRODUCT
	WHERE ProductName = @Product;

INSERT INTO tblORDER(CustID) VALUES(@CustID);
SET @OrderID = SCOPE_IDENTITY();

INSERT INTO tblLINE_ITEM(ProductID,OrderID,qty) VALUES(@ProductID,@OrderID,@qty);
COMMIT TRAN orderInsert;
GO


-- 5) Write the code to create a computed column in CUSTOMER that maintains the running total of the number of orders they have.
CREATE FUNCTION getOrders(int @CustID)
RETURNS int
AS
DECLARE @ret;
SELECT @ret = COUNT(OrderId)
	FROM tblORDER
	WHERE CustID = @CustID;
RETURN @ret;

ALTER TABLE tblCUSTOMER
ADD TotalOrders AS getOrders(CustID);

-- 6) Write the code to create a check constraint that will enforce the rule: the minimum price for any order must be $6.50.
CREATE FUNCTION getPrice(int @OrderID)
RETURNS int
AS
DECLARE @ret;
SELECT @ret = SUM(li.qty * p.price)
	FROM tblORDER o
		JOIN tblLINE_ITEM li
			ON li.OrderID = o.OrderID
		JOIN tblPRODUCT p
			ON p.ProductID = li.ProductID
	WHERE o.OrderID = @OrderID
	GROUP BY o.OrderID;
RETURN @ret;

ALTER TABLE tblORDER
ADD CONSTRAINT minPrice CHECK getPrice(OrderID) > 6.50;