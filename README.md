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


