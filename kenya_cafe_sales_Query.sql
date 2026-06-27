SELECT * FROM sales_transaction;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM staffs;

ALTER TABLE customers 
    ADD COLUMN IF NOT EXISTS latitude FLOAT,
    ADD COLUMN IF NOT EXISTS longitude FLOAT;


UPDATE customers SET latitude = -1.2921, longitude = 36.8219 WHERE town = 'Nairobi';
UPDATE customers SET latitude = -4.0435, longitude = 39.6682 WHERE town = 'Mombasa';
UPDATE customers SET latitude = -0.0917, longitude = 34.7679 WHERE town = 'Kisumu';
UPDATE customers SET latitude = -0.3031, longitude = 36.0800 WHERE town = 'Nakuru';
UPDATE customers SET latitude =  0.5143, longitude = 35.2698 WHERE town = 'Eldoret';
UPDATE customers SET latitude = -1.0332, longitude = 37.0693 WHERE town = 'Thika';
UPDATE customers SET latitude = -1.5177, longitude = 37.2634 WHERE town = 'Machakos';
UPDATE customers SET latitude = -0.4167, longitude = 36.9500 WHERE town = 'Nyeri';
UPDATE customers SET latitude =  0.0467, longitude = 37.6490 WHERE town = 'Meru';
UPDATE customers SET latitude = -0.4532, longitude = 42.4800 WHERE town = 'Garissa';


SELECT town, latitude, longitude FROM customers LIMIT 10;

SELECT
	town, 
	latitude, 
	longitude,
	COUNT(*) AS total_customers
FROM customers
WHERE latitude IS NOT NULL
GROUP BY town, latitude, longitude


SELECT
	sum(totalamount_kes) total_revenue
FROM sales_transaction;

--- Checking for Duplicates Values
SELECT
	transactionid,
	COUNT(*) AS total_sales
FROM sales_transaction
GROUP BY transactionid
	HAVING COUNT(*) > 1;
	
--- TOTAL DISTINCT CUSTOMERS
SELECT
	COUNT(DISTINCT customerid) AS total_customers
FROM sales_transaction;

SELECT
	EXTRACT(YEAR FROM saledate) AS year,
	COUNT(DISTINCT customerid) AS total_customers
FROM sales_transaction
GROUP BY EXTRACT(YEAR FROM saledate);

SELECT
	cafename,
	COUNT(*) AS total_sales
FROM sales_transaction
GROUP BY cafename;

--- CREATING A VIEW FOR CUSTORMER WALK IN's
CREATE VIEW walk_in_sales AS
SELECT
	s.*,
	COUNT(*) AS total_customers
FROM sales_transaction s
LEFT JOIN customers c
	ON s.customerid = c.customerid
WHERE c.customerid IS NULL
GROUP BY s.transactionid


--- FINDING THE TOP MOST PERFORMING TOWNS IN TERMS OF SALES AND REVENUE
SELECT
	branch,
	COUNT(*) AS total_sales,
	sum(totalamount_kes) total_revenue
FROM sales_transaction
GROUP BY branch
ORDER BY total_revenue DESC;

--- TOP 10 BEST PERFORMING PRODUCTS
WITH products_ranking AS(
	SELECT
		productname,
		total_sales,
		total_revenue,
		ROW_NUMBER() OVER(ORDER BY total_revenue DESC) products_ranking
	FROM(
		SELECT
			productname,
			COUNT(*) AS total_sales,
			sum(totalamount_kes) total_revenue
		FROM sales_transaction
		GROUP BY productname
	)
)
SELECT
	productname,
	total_sales,
	total_revenue,
	products_ranking
FROM products_ranking
WHERE products_ranking <= 10;



--- SALES PERFORMANCE BASED ON THE MODE OF PAYMENT
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

--- TOP 3 CUSTOMERS BY TOTAL REVENUE
SELECT
	c.customername,
	SUM(s.totalamount_kes) AS total_revenue
FROM sales_transaction AS s
LEFT JOIN customers AS c
	ON s.customerid = c.customerid
WHERE c.customername IS NOT NULL
GROUP BY c.customername
ORDER BY total_revenue DESC
LIMIT 3;

--- SALES TREND

--- Yearly sales trend
SELECT
	EXTRACT(YEAR FROM saledate) AS year,
	SUM(totalamount_kes) AS total_revenue
FROM sales_transaction
GROUP BY EXTRACT(YEAR FROM saledate)
ORDER BY total_revenue DESC;

--- Quarterly trend
SELECT
	EXTRACT(YEAR FROM saledate) AS year,
	quarter,
	SUM(totalamount_kes) AS total_revenue
FROM sales_transaction
GROUP BY EXTRACT(YEAR FROM saledate), quarter
ORDER BY total_revenue DESC 

--- Monthly sales trend
SELECT
	TO_CHAR(saledate, 'Mon') AS month_name,
	EXTRACT(MONTH FROM saledate) AS month_num,
	SUM(totalamount_kes) AS total_revenue
FROM sales_transaction
GROUP BY 
	TO_CHAR(saledate, 'Mon'),
	EXTRACT(MONTH FROM saledate)
ORDER BY month_num;

--- MONTHLY GROWTH RATE 
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

--- IDENTIFYING CUSTOMERS WITH FREQUENT VISITS AND LOYALTY

SELECT
	customerid,
	consecutive_months,
	CASE
		WHEN consecutive_months >= 15 THEN 'Super Loyal'
		WHEN consecutive_months >= 12 THEN 'Highly Loyal'
		WHEN consecutive_months >=6 THEN 'Regular'
		ELSE 'Occasional'
	END AS loyalty_seg

FROM(
	WITH monthly_visit AS(
		SELECT
			c.customerid,
			EXTRACT(YEAR FROM s.saledate) AS year,
			EXTRACT(MONTH FROM s.saledate) month_num
		FROM sales_transaction s
		LEFT JOIN customers c
			ON s.customerid = c.customerid
		WHERE c.customerid IS NOT NULL
		GROUP BY
			c.customerid,
			EXTRACT(YEAR FROM s.saledate),
			EXTRACT(MONTH FROM s.saledate)
	),
	consecutive_visits AS(
		SELECT
			customerid,
			year,
			month_num,
			LAG(month_num) OVER(PARTITION BY customerid ORDER BY year, month_num) prev_month,
			LAG(year) OVER(PARTITION BY customerid ORDER BY year, month_num) prev_year
		FROM monthly_visit
	)
	SELECT 
	    DISTINCT
		customerid,
		COUNT(*) OVER (PARTITION BY customerid) AS consecutive_months
	FROM consecutive_visits
	WHERE 
		(month_num = prev_month + 1 AND year = prev_year)
	    OR
	    (month_num = 1 AND prev_month = 12 AND year = prev_year + 1)

)
ORDER BY consecutive_months DESC;

--- AVERAGE SALES VALUE PER MONTH
SELECT
	EXTRACT(YEAR FROM saledate) AS year,
	TO_CHAR(saledate, 'Mon') AS month_name,
	EXTRACT(MONTH FROM saledate) AS month_num,
	ROUND(AVG(totalamount_kes)::numeric, 2) avg_sales_value
FROM sales_transaction
GROUP BY
	EXTRACT(YEAR FROM saledate),
	TO_CHAR(saledate, 'Mon'), 
	EXTRACT(MONTH FROM saledate)
ORDER BY month_num;

--- PERCENTAGE CONTRIBUTION OF PRODUCTS TOWARDS THE REVENUE

SELECT
	productid,
	 productname,
	total_revenue,
	contribution_pct,
	cont_pct_ranking
FROM (
	WITH product_pct_cont AS(
		SELECT
			productid,
			productname,
			SUM(totalamount_kes) total_revenue
		FROM sales_transaction
		GROUP BY productid, productname
	), 
	cont_pct AS(
		SELECT
			productid, 
			productname,
			total_revenue,
			ROUND((total_revenue / SUM(total_revenue) OVER())::numeric * 100, 2) contribution_pct
		FROM product_pct_cont
	)
	SELECT
		productid, 
		productname,
		total_revenue,
		contribution_pct,
		ROW_NUMBER() OVER(ORDER BY contribution_pct DESC) cont_pct_ranking
	FROM cont_pct
)
WHERE cont_pct_ranking <= 10;


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




--- FINDING THE HIGHEST PAID EMPLOYEES
WITH employees_rank AS(
	SELECT *,
		DENSE_RANK() OVER(ORDER BY salary_kes DESC) AS emloyee_rnk
	FROM staffs
	WHERE role = 'Barista' AND branch = 'Kilimani'

)
SELECT
	staffid,
	staffname,
	role,
	branch,
	salary_kes,
	emloyee_rnk
FROM employees_rank
WHERE emloyee_rnk <= 2

--- MONTH OVER MONTH REVENUE GROWTH
WITH monthly_revenue AS(
	SELECT
		TO_CHAR(saledate, 'Mon') AS month_name,
		EXTRACT(MONTH FROM saledate) AS month_num,
		SUM(totalamount_kes) AS total_revenue
	FROM sales_transaction
	GROUP BY 
		TO_CHAR(saledate, 'Mon'), 
		EXTRACT(MONTH FROM saledate)
)
SELECT
	month_name,
	month_num,
	total_revenue,
	LAG(total_revenue) OVER(ORDER BY month_num ASC) prev_month,
	ROUND(100 *
	(total_revenue - LAG(total_revenue) OVER(ORDER BY month_num ASC))::numeric
	/ LAG(total_revenue) OVER(ORDER BY month_num ASC)::numeric
	,2 ) AS growth_pct
FROM monthly_revenue;

--- AVERAGE RATINGS
SELECT
	cafename,
	AVG(rating) AS avg_ratings
FROM sales_transaction
GROUP BY cafename

--- CREATING PRODUCTS RATING SEGMENTATIONS
CREATE VIEW products_ratings AS
WITH product_reviews AS(
	SELECT
		productid,
	    rating,
	    COUNT(*) AS total_reviews
	FROM sales_transaction
	WHERE rating > 0
	GROUP BY productid, rating
)
SELECT
	productid,
	rating,
	CASE
		WHEN rating = 5 THEN 'Excellent (5★)'
		WHEN rating = 4 THEN 'Good (4★)'
		WHEN rating = 3 THEN 'Average (3★)'
		WHEN rating = 2 THEN 'Fair (2★)'
		ELSE 'Poor (1★)'
	END AS ratings_seg,
	total_reviews,
	ROUND(total_reviews * 100.0 / SUM(total_reviews) OVER(), 2) AS pct_reviews
FROM product_reviews;



--- CREATING A CUSTOMER LOYALTY VIEW TABLE
CREATE VIEW customer_loyalty_segments AS
WITH monthly_visit AS (
    SELECT
        c.customerid,
        EXTRACT(YEAR FROM s.saledate) AS year,
        EXTRACT(MONTH FROM s.saledate) AS month_num
    FROM sales_transaction s
    LEFT JOIN customers c ON s.customerid = c.customerid
    WHERE c.customerid IS NOT NULL
    GROUP BY c.customerid,
             EXTRACT(YEAR FROM s.saledate),
             EXTRACT(MONTH FROM s.saledate)
),
consecutive_visits AS (
    SELECT
        customerid,
        year,
        month_num,
        LAG(month_num) OVER (PARTITION BY customerid ORDER BY year, month_num) AS prev_month,
        LAG(year) OVER (PARTITION BY customerid ORDER BY year, month_num) AS prev_year
    FROM monthly_visit
),
consecutive_counts AS (
    SELECT DISTINCT
        customerid,
        COUNT(*) OVER (PARTITION BY customerid) AS consecutive_months
    FROM consecutive_visits
    WHERE
        (month_num = prev_month + 1 AND year = prev_year)
        OR
        (month_num = 1 AND prev_month = 12 AND year = prev_year + 1)
)
SELECT
    customerid,
    consecutive_months,
    RANK() OVER (ORDER BY consecutive_months DESC) AS customer_rank,
    CASE
        WHEN consecutive_months >= 15 THEN 'Super Loyal'
        WHEN consecutive_months >= 12 THEN 'Highly Loyal'
        WHEN consecutive_months >= 6  THEN 'Regular'
        ELSE 'Occasional'
    END AS loyalty_segment
FROM consecutive_counts
ORDER BY consecutive_months DESC;









