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
## Project Dashboards
The project includes interactive Power BI dashboards designed to analyze Kenyan cafe chains (Java House and Art Caffe) from multiple perspectives, including trend analysis, customer loyalty and segmentation, and performance analysis.


### Page 1 - Overview Dashboard
This dashboard provides a high-level summary of cafe sales performance across Java House and Art Caffe from January 2023 to December 2024.

	Key KPIs:
	- Total Revenue — KES 5.99M (↓ 3.9% vs prior year)
	- Total Transactions — 10.18K (↑ 0.1% vs prior year)
	- Average Order Value — KES 588 (↓ 4.1% vs prior year)
	- Active Customers — 500 registered customers

Overall revenue stood at KES 5.99M, declining 3.9% year-over-year despite transaction volumes remaining virtually flat at 10.18K, suggesting customers visited at the same frequency but spent less per order, with average order value dropping 4.1% to KES 588. This points to a potential shift in customer purchasing behavior worth monitoring.

Coffee remains the backbone of revenue at 40.68%, reinforcing its role as the core product category for both chains. M-Pesa dominates payment transactions, consistent with Kenya's mobile-first financial landscape. The CBD branch significantly outperforms all others in revenue, indicating a concentration of high-value customers in urban Nairobi.

Morning hours between 8AM and 10AM represent the peak trading window, presenting an opportunity for targeted promotions and staffing optimization during that period.

This dashboard serves as an executive summary, enabling stakeholders to quickly assess overall business health and identify areas requiring strategic attention.

<img width="634" height="358" alt="OVERVIEW DASHBOARD" src="https://github.com/user-attachments/assets/3e502ba6-2951-48d7-8533-99e169076f97" />

### Page 2 - Sales Trends

This dashboard presents a time intelligence analysis of sales performance across both cafe chains, examining revenue patterns at monthly, weekly and hourly levels to identify peak periods, seasonal behavior and growth trajectories over the 2023–2024 period.

	Key KPIs:
	- Best Month — July 2024 (+28.58% MoM)
	- Worst Month — June 2024 (-16.05% MoM)
	- Best Quarter — Q4 2023 (KES 7.77M)
	- Peak Hours — 8AM–10AM (Morning rush)

July 2024 emerged as the strongest performing month with a remarkable +28.58% month-over-month growth, while June 2024 recorded the sharpest decline at -16.05% a volatility pattern suggesting possible seasonal factors or operational disruptions worth investigating. 

Q4 2023 stood out as the best performing quarter at KES 7.77M, indicating stronger consumer spending toward the end of the year.

Weekly revenue analysis reveals a relatively consistent pattern across all days, with Sunday leading at KES 0.85M and Wednesday recording the lowest at KES 0.81M, a narrow range that suggests cafe visits are not heavily weekend-dependent, reflecting a loyal base of weekday customers such as office workers and students.

Hourly revenue distribution confirms morning hours between 8AM and 10AM as the dominant trading window, generating KES 1.97M, significantly ahead of afternoon at KES 1.62M, evening at KES 1.36M and night at KES 1.04M. This pattern is consistent with typical cafe consumer behavior driven by morning coffee routines and breakfast orders.

M-Pesa accounted for the highest transaction volume at 39.95%, reinforcing its dominance as the preferred payment method and highlighting the importance of maintaining seamless mobile money integration across all branches.

This dashboard equips business managers with the temporal intelligence needed to optimize staffing, plan promotions and align inventory management with peak demand periods.

<img width="634" height="359" alt="SALES TREND DASHBOARD" src="https://github.com/user-attachments/assets/d8304410-255b-47ef-8314-53462de88e69" />


###	Page 3 - Customer Analysis

This dashboard presents a comprehensive analysis of customer behavior, loyalty patterns and segmentation across all registered customers and branches, providing actionable intelligence for customer retention and acquisition strategies.

	Key KPIs:
	- Active Customers — 500 registered
	- Walk-in Sales — 681 anonymous transactions (6.69%)
	- Avg Visits per Customer — 20.37

Of the 500 registered customers, all maintained active transaction records across the two-year period, averaging 20.37 visits per customer, a strong indicator of habitual cafe engagement. However, 681 transactions representing 6.69% of total sales could not be attributed to registered customers, highlighting a walk-in segment that presents a significant opportunity for loyalty program enrollment and customer data capture.

Loyalty segmentation based on consecutive monthly visits reveals a healthy distribution across tiers. The majority of customers fall within the Regular and Occasional segments at 58.4% and 32.6% respectively, while Highly Loyal and Super Loyal customers collectively account for approximately 9% of the customer base. Despite being a small group, these high-frequency customers represent disproportionate revenue value and should be prioritized for retention incentives and personalized engagement.

The top performing customer, *Cynthia Abubakar (CUST-0314)* from Eldoret, recorded 17 consecutive months of visits, the highest loyalty streak in the entire dataset, followed closely by *Aisha Mutua* from Nairobi with 16 consecutive months. This level of consistency across different towns demonstrates that customer loyalty is not limited to urban centers but is distributed across multiple Kenyan regions.

CBD branch dominates customer concentration with 497 customers, significantly ahead of Westlands at 108 and Kilimani at 87, reinforcing the urban Nairobi market as the primary customer base. Food commands the highest average order value at KES 1,073 per transaction, followed by Shakes at KES 761 and Coffee at KES 601, suggesting that food pairing with beverages is a key revenue driver worth promoting.

This dashboard empowers marketing and customer success teams to identify high-value customers, design targeted loyalty campaigns and develop strategies to convert anonymous walk-in customers into registered members of the loyalty program.

<img width="635" height="357" alt="CUSTOMERS DASHBOARD" src="https://github.com/user-attachments/assets/2057957e-19e3-426f-8dd4-d705d169506b" />

### Page 4 - Products Performance

This dashboard analyzes revenue contribution, customer ratings and branch performance across 33 products spanning 6 categories, providing product-level intelligence to guide menu optimization and pricing decisions.

	Key KPIs:
	- Top Product — Eggs Benedict (KES 0.31M)
	- Top Category — Coffee (40.68% of revenue)
	- Highest Rated — Macchiato (4.25 avg rating)
	- Avg Discount — 3.35%

Coffee dominates category revenue at 40.68% (KES 2.4M), establishing it as the core revenue driver across both cafe chains, with Food following at KES 1.3M. At product level, Eggs Benedict leads individual revenue performance while Macchiato recorded the highest average customer rating at 4.25, suggesting that customer satisfaction does not always align with revenue volume, a distinction worth noting when making menu decisions.

Product rating distribution skews positively with 41 products rated Good and 40 rated Excellent, indicating strong overall customer satisfaction. Only 3 products fall in the Poor category, presenting a clear opportunity for menu review or product improvement.

CBD branch significantly outperforms all others with 497 customers, 7,469 transactions and KES 4.39M in total revenue, making it the highest performing branch by every measurable metric.

This dashboard equips product and operations teams with the insights needed to optimize the menu, address underperforming products and replicate the success of top performing branches.

<img width="635" height="358" alt="PRODUCTS DASHBOARD" src="https://github.com/user-attachments/assets/0821b1d7-b4c6-495c-bdf8-6aaabe68cb0a" />

---
## Recommendations
Based on the analysis of Kenya Cafe Sales data across Java House and Art Caffe from January 2023 to December 2024, the following recommendations are proposed to guide strategic decision making and improve overall business performance.

###	*1. Address the Decline in Average Order Value*
Despite stable transaction volumes, average order value dropped 4.1% in 2024. Both cafe chains should explore upselling strategies such as combo meal promotions, product bundling and loyalty-based discounts to encourage customers to spend more per visit rather than simply visiting more frequently.

###	*2. Convert Walk-in Customers into Registered Members*
6.69% of transactions representing 681 sales came from anonymous walk-in customers with no loyalty account. Implementing a simple point-of-sale sign-up incentive such as a free beverage or discount on first registered purchase could convert this segment into trackable, retained customers, directly improving customer data quality and loyalty program reach.

###	*3. Investigate Mid-Year Revenue Volatility*
June 2024 recorded the sharpest monthly decline at -16.05% while July 2024 rebounded strongly at +28.58%. This level of volatility warrants further investigation into operational, seasonal or external factors driving these swings, and the development of contingency promotions to stabilize revenue during historically weak months.

###	*4. Prioritize and Reward Super Loyal Customers*
Only 9% of customers fall within the Highly Loyal and Super Loyal segments yet they represent the most consistent revenue contributors. Introducing exclusive rewards, early access to new menu items or personalized offers for this group would strengthen retention and encourage other customers to aspire to higher loyalty tiers.

###	*5. Optimize Staffing and Promotions Around Peak Hours*
Morning hours between 8AM and 10AM consistently generate the highest revenue at KES 1.97M. Cafe management should ensure optimal staffing levels during this window while introducing targeted morning promotions such as breakfast combos to maximize revenue during peak demand periods.

###	*6. Expand Beyond CBD Concentration*
CBD branch dominates across all metrics: revenue, customers and transactions while branches like Karen, Lavington and Upperhill significantly underperform. Strategic investment in marketing, menu variety and customer experience improvements at lower performing branches could unlock untapped revenue potential across other Nairobi neighborhoods and upcountry towns.

###	*7. Review and Improve Underperforming Products*
Three products received Poor customer ratings while several others fall in the Average category. A structured menu review focusing on recipe improvement, presentation or pricing adjustment for these products would improve overall customer satisfaction scores and protect brand reputation across both chains.

###	*8. Leverage M-Pesa as a Marketing Channel*
M-Pesa accounts for 39.95% of all transactions making it the dominant payment method. Both chains should explore M-Pesa integrated loyalty programs, Lipa Na M-Pesa promotions and targeted SMS campaigns to engage customers directly through their preferred payment platform, a strategy well aligned with Kenya's mobile-first consumer behavior.

---

## Limitations

This analysis has several limitations that should be acknowledged when interpreting the results:

- The dataset used in this project is synthetically generated and does not reflect real cafe sales behavior. As a result, certain patterns and trends may be simplified or artificially structured, limiting the extent to which findings can be generalized to actual Java House and Art Caffe operations.

- 6.69% of transactions (681 sales) could not be attributed to registered customers due to missing CustomerID records, limiting the depth of customer behavior analysis for this segment.

- The dataset contained significant data quality issues including mixed date formats, inconsistent naming conventions, duplicate rows, negative quantities and missing values across multiple columns, which required extensive cleaning before meaningful analysis could be performed.

- The analysis does not account for external factors such as public holidays, economic conditions, competitor activity or seasonal events that would significantly influence real-world cafe sales performance.

---
## Conclusion
This project analyzed the key factors influencing sales performance across Java House and Art Caffe using a combination of Excel, Python, SQL and Power BI to explore retail cafe behavior and identify the main drivers of revenue, customer loyalty and product performance across multiple Kenyan towns and branches.

The analysis revealed that cafe sales performance is shaped by multiple interrelated factors rather than a single determinant. Coffee emerged as the dominant revenue category, contributing 40.68% of total sales, while morning hours between 8AM and 10AM consistently drove the highest customer activity, highlighting the importance of product focus and time-based operational planning in the cafe industry. M-Pesa dominated payment transactions, reinforcing Kenya's mobile-first financial behavior as a critical consideration for any retail strategy in the market.

Customer loyalty analysis demonstrated that consistent engagement drives disproportionate value, with Super Loyal and Highly Loyal customers, though representing only 9% of the base maintaining the most reliable revenue contribution over the two-year period. The 6.69% walk-in rate further highlighted an untapped customer acquisition opportunity that both chains could leverage through targeted loyalty enrollment initiatives at the point of sale.

Revenue declined 3.9% year-over-year despite stable transaction volumes, pointing to a drop in average order value rather than a loss of customers a nuanced finding that calls for upselling and bundling strategies rather than customer acquisition campaigns. CBD branch significantly outperformed all other locations, suggesting that geographic concentration remains a challenge that warrants strategic investment in underperforming branches.

Overall, the findings demonstrate that cafe sales performance is a multifaceted outcome shaped by product mix, customer loyalty, time-based demand patterns and branch-level execution. This project highlights the value of data-driven decision making in the retail cafe industry and establishes a foundation for deeper predictive analysis as more real-world data becomes available.

---

## References
1.	SQL for Data Engineering [Data with Baraa](https://www.youtube.com/watch?v=SSKVgrwhzus)
2.	Data Analytics with [Chandoo](https://www.youtube.com/results?search_query=chandoo)
3.	[HackerRank](https://www.hackerrank.com/dashboard)
4.	[DataCamp](https://app.datacamp.com/)
