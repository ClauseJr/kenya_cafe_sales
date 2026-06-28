# Kenyan Cafe Sales Analysis

## Executive Summary

### Overview Findings
This project presents a full end-to-end data analytics pipeline, analyzing synthetic sales data from two leading Kenyan cafe chains (Java House and Art Caffe). The analysis explores retail cafe performance, customer behavior, product trends, and revenue patterns across multiple Kenyan towns and branches.

The interactive Power BI dashboard enables us to perform:
  - Identify top performing branches, products and categories
  - Analyze customer loyalty and visit frequency
  - Track revenue trends month-over-month across 2023 and 2024
  - Segment customers by loyalty and consecutive visit patterns
  - Understand peak sales hours, days and seasonal patterns

### Data Sources

  - 10,500+ synthetic sales transactions
  - 500 registered customers across 10 Kenyan towns
  - 33 products across 6 categories
  - 80 staff members across multiple branches
  - Date range: January 2023 — December 2024

---
## Tools Used

**a. Excel**

Excel was used as the initial data inspection tool to:
  - Explore the raw dataset structure and column formats
  - Perform a preliminary review of missing values and inconsistencies
  - Validate data before ingestion into Python for deeper analysis

**b. Python (Jupyter Notebook)**

Python was the primary cleaning and transformation tool used to:
  - Standardize column formats — cafe names, branches, payment methods, towns
  - Handle missing values, duplicates, negative quantities and outliers
  - Engineer new features — TimeOfDay, Quarter, MonthName, DayOfWeek
  - Perform Exploratory Data Analysis (EDA)
  - Export clean datasets for SQL and Power BI ingestion

**c. SQL (PostgreSQL)**

The cleaned data was loaded into PostgreSQL for structured analysis:
  - Designed a star schema with primary and foreign key relationships
  - Wrote analytical queries using subqueries, CTEs and window functions (LAG, RANK, DENSE_RANK)
  - Performed revenue trend analysis, customer segmentation and product performance queries
  - Created views for loyalty segmentation used directly in Power BI

**d. Power BI**

Power BI was used for interactive dashboard development:
  - Built a 4-page dashboard covering Overview, Sales Trends, Customer Analysis and Product Performance
  - Created DAX measures for:
    - Total Revenue
    - Total Transactions
    - Active Customers
    - Average Order Value
    - YoY Growth Rate
  - Implemented slicers for dynamic filtering by Year, Cafe Name, Branch and Category
  - Designed visual storytelling through KPI cards, bar charts, donut charts and trend lines

---
## Data Analysis

```python
# Load the dataset
sales = pd.read_csv("Sales_Transactions.csv")
customers = pd.read_csv("Customers.csv")
products = pd.read_csv("Products.csv")
staff = pd.read_csv("Staffs.csv")
```
```python
# Exporting cleaned dataset
sales.to_csv("cleaned_sales_transaction.csv", index=False)
customers.to_csv("cleaned_customers_data.csv", index=False)
products.to_csv('cleaned_products_data.csv', index=False)
staff.to_csv('cleaned_staff_data.csv', index=False)

print("Cleaned Dataset Exported Successfully")
```
```sql
--- PRODUCTS RATING BY CUSTOMERS

WITH products_rating AS(
	SELECT
		p.productid,
		p.productname,
		p.category,
		SUM(s.totalamount_kes) AS total_revenue,
		COUNT(*) total_orders,
		ROUND(AVG(s.rating),2) avg_rating
	FROM sales_transaction s
	JOIN products p
		ON s.productid = p.productid
	WHERE s.rating > 0
	GROUP BY p.productid, p.productname, p.category
)
SELECT
	productid,
	productname,
	category,
	total_revenue,
	total_orders,
	avg_rating,
	CASE
		WHEN avg_rating >= 4.5 THEN 'Excellent'
		WHEN avg_rating >= 3.5 THEN 'Good'
		WHEN avg_rating >= 2.5 THEN 'Average'
		ELSE 'Poor'
	END AS products_seg
FROM products_rating
ORDER BY avg_rating DESC;
```
```sql
--- MONTH OVER MONTH REVENUE GROWTH
WITH sales_growth_rate AS(
	SELECT
		EXTRACT(YEAR FROM saledate) AS year,
		TO_CHAR(saledate, 'Mon') AS month_name,
		EXTRACT(MONTH FROM saledate) AS month_num,
		SUM(totalamount_kes) AS total_revenue
	FROM sales_transaction
	GROUP BY 
		EXTRACT(YEAR FROM saledate),
		TO_CHAR(saledate, 'Mon'), 
		EXTRACT(MONTH FROM saledate)
	ORDER BY month_num
)
SELECT
	year,
	month_name,
	month_num,
	total_revenue,
	LAG(total_revenue) OVER(ORDER BY year, month_num) prev_month_revenue,
	ROUND(
	((total_revenue - LAG(total_revenue) OVER(ORDER BY year, month_num)) /
	LAG(total_revenue) OVER(ORDER BY year, month_num))::numeric
	* 100, 2
	) AS growth_rate_pct
	
FROM sales_growth_rate;
--- summaries:
--- Best month == July 2024 at +28.58%
--- Worst month == June 2024 at -16.05%
--- Most consistent growth == May-June 2023
--- Biggest spike == March 2024 at +18.67%
```
```sql
WITH payment_methods AS(
	SELECT
		paymentmethod,
		COUNT(*) AS total_sales,
		SUM(totalamount_kes) total_revenue
	FROM sales_transaction
	GROUP BY paymentmethod
	ORDER BY total_revenue DESC
)
SELECT
	paymentmethod,
	total_sales,
	total_revenue,
	ROUND((total_revenue / SUM(total_revenue) OVER())::numeric * 100, 2) payment_rate
FROM payment_methods;
--- The top 3 most preffered modes of payment by customers are:
	---	Mpesa == 39.95%
	---	Cash == 29.20%
	---	Visa == 20.62%
```
---

