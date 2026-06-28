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
a. Excel

Excel was used as the initial data preparation tool to:
  -  Clean and standardize column formats (texts, numerical fields).
  -  Handle missing, duplicates and inconsistent values.
  -  Validate data integrity.

This step was used for light-weight data preparations before ingestion into notebook for heavy analysis

b.  Python (Jupyter Notebook)

The data was loaded into jupyter notebook, to help in:
  -  Dataset cleaning and standardizing columns formarts i.e branches, towns
  -  Handling inconsistency, duplicates and missing data sections
  -  Data transformation and preprocessing
  -  Explanatory data analysis(EDA)
  -  Validation of data for integrity before performing descriptive analysis

c. SQL(PostgreSQL)

The data was intergrated into PostgreSQl for SQL analysis and querying, to help in:
  -  Data extraction and Performing structured analysis
  -  Explanatory analysis, Descriptive analysis and Predictive preparation
  -  Validation of data for integrity before visualization

d. Power BI

Within Power BI:
  -  Creation of custom columns and conditional columns for data segmentation
  -  DAX measures were created for the following KPIs:
      -  Total Revenue
      -  Total Transactions
      -  Total Active Customers
      -  Growth Rate
      -  Average Order Value
  -  Visual storytelling through charts and KPIs
  -  Enabling stakeholder interactions and decision-making

Slicers were implemented for dynamic analysis, using Gender slicers.


