# Kenya Cafe Sales Analysis

## Executive Summary

### Overview Findings
This project presents an end-to-end analysis of employee attrition using Excel, SQL, Python, and Power BI. It explores how factors such as job satisfaction, leadership, work-life balance, innovation, and overtime influences employee turnover.

Key metrics like attrition rate and category-based risk patterns were analyzed through segmentation and visualization techniques. The project identifies high-risk employee groups and highlights the main drivers of attrition, providing actionable insights to support data-driven retention strategies.

The interactive Power BI dashboard enables us to perform:
  -  Analysis of employee attrition drivers, including job satisfaction, leadership, work-life balance, innovation, overtime, company reputation, and employee recognition.
  -  Identification of patterns in attrition rates and key factors influencing employee turnover.
  -  Segmentation of employees to highlight high-risk groups prone to attrition.
  -  Development of an interactive dashboard to support data-driven insights into workforce retention and turnover risk.
  -  Comparison of attrition rates across different employee groups to uncover disparities and prioritize targeted retention strategies.

### Data Sources

A synthetically generated employee attrition dataset designed for data analytics and visualization practice, comprising of over 60,000 records. It models key workforce attributes such as demographics, job satisfaction, leadership, work-life balance, innovation, and overtime to support analysis of attrition patterns and underlying drivers of employee turnover.

---
## Tools Used
a. Excel

Excel was used as the initial data preparation tool to:
  -  Clean and standardize column formats (texts, numerical fields)
  -  Handle missing, duplicates and inconsistent values
  -  Validate data integrity before visualization

This step was used for light-weight data preparations before ingestion into notebook for heavy analysis

b.  Python(Jupyter Notebook)

The data was loaded into jupyter notebook, to help in:
  -  Dataset cleaning and standardizing columns formarts i.e gender
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
      -  Total Employees
      -  Total Attrition
      -  Attrition Rate
      -  Average Salary
      -  Average Tenure
  -  Visual storytelling through charts and KPIs
  -  Enabling stakeholder interactions and decision-making

Slicers were implemented for dynamic analysis, using Gender slicers.


