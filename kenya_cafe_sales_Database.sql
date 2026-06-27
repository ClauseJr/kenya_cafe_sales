
CREATE TABLE customers(
	CustomerID VARCHAR(15),
	CustomerName VARCHAR(25),
	Email VARCHAR(50),
	Town VARCHAR(20),
	LoyaltyTier	VARCHAR(15),
	JoinDate DATE,
	PRIMARY KEY (CustomerID)

);

CREATE TABLE products(
	ProductID VARCHAR(15),
	Category VARCHAR(20),
	ProductName	VARCHAR(25),
	UnitPrice_KES INT,
	PRIMARY KEY (ProductID)

);

CREATE TABLE staffs(
	 StaffID VARCHAR(15),	
	 StaffName VARCHAR(20),	
	 Role VARCHAR(15),
	 Branch	VARCHAR(25),
	 HireDate DATE,
	 Salary_KES BIGINT,
	 PRIMARY KEY (StaffID)

);

CREATE TABLE sales_transaction(
	TransactionID VARCHAR(15),
	SaleDate DATE,
	SaleTime TIME,
	CafeName VARCHAR(20),
	Branch VARCHAR(20),
	CustomerID VARCHAR(15),
	ProductID VARCHAR(15),	
	ProductName	VARCHAR(25),
	Category VARCHAR(15),
	Quantity INT,
	UnitPrice_KES INT,
	Discount_Pct INT,
	TotalAmount_KES FLOAT,	
	PaymentMethod VARCHAR(15),
	StaffID	VARCHAR(15),
	Rating INT,
	Year INT,	
	Month INT,	
	MonthName VARCHAR(15),
	Quarter	VARCHAR(5),
	DayOfWeek VARCHAR(10),
	Hour INT,
	TimeKnown BOOL,
	TimeOfDay VARCHAR(15),
	PRIMARY KEY(TransactionID),
	CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
	CONSTRAINT fk_product FOREIGN KEY (ProductID) REFERENCES products(ProductID),
	CONSTRAINT fk_staff FOREIGN KEY (StaffID) REFERENCES staffs(StaffID)


);

--- CUSTOMERS DATA
SELECT * FROM customers;


SELECT
	COUNT(*) AS total_customers
FROM customers;

--- PRODUCTS DATA
SELECT * FROM products;

SELECT
	COUNT(*) AS total_products
FROM products;

--- STAFFS DATA
SELECT * FROM staffs;

SELECT
	COUNT(*) AS total_staffs
FROM staffs;

--- SALES TRANSACTION DATA
SELECT * FROM sales_transaction;

SELECT
	COUNT(*) total_sales
FROM sales_transaction;
