# Telco Customer Churn Analysis

## Project Overview
This project analyzes customer churn within a telecommunications company using the **IBM Telco Customer Churn dataset**. 

The goal of this analysis is to identify key customer segments associated with elevated churn rates, evaluate operational and service factors influencing customer departures, and quantify the monthly recurring revenue associated with churned accounts.

The project follows an end-to-end data analytics workflow—ranging from data validation, cleaning, and exploratory data analysis (EDA) using **MySQL**, to interactive business intelligence dashboard design using **Microsoft Power BI**.

---

## Business Problem
Customer churn directly erodes recurring revenue streams and degrades long-term business performance. Identifying churn risks early empowers management to design targeted retention strategies and make informed operational decisions.

This project addresses the following critical business questions:
- What is the overall customer churn rate?
- Which customer segments exhibit the highest churn rates?
- Are month-to-month contract holders significantly more likely to churn?
- How does customer tenure correlate with churn probability?
- Which internet and value-added services are associated with higher churn rates?
- Do specific payment methods correlate with increased customer turnover?
- How much monthly revenue is attached to churned accounts (Revenue at Risk)?
- What strategic actions can management take to improve customer retention?

---

## Tools & Technologies
- **MySQL Workbench / SQL:** Data cleaning, data validation, exploratory data analysis (EDA), aggregations, dynamic CTEs, and customer segmentation.
- **Microsoft Power BI:** Data modeling, dynamic visualizations, and interactive dashboard creation.
- **DAX (Data Analysis Expressions):** Calculated measures, KPIs, and custom business logic.
- **Power Query:** Initial data inspection, type transformations, and data shaping.

---

## Dataset Summary
- **Source:** [IBM Telco Customer Churn Dataset (Kaggle)](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
- **Scale:** 7,043 customer records | 21 attributes
- **Key Attributes:**
  - **Demographics:** Gender, Senior Citizen status, Partners, Dependents.
  - **Account Details:** Contract type, Tenure (months), Paperless billing, Payment method.
  - **Services Subscribed:** Phone, Multiple lines, Internet service (DSL/Fiber optic), Online Security, Online Backup, Device Protection, Tech Support, Streaming TV/Movies.
  - **Financials:** Monthly Charges, Total Charges.
  - **Target Variable:** `Churn` (`Yes` / `No`).

---

## Project Workflow

### 1.Data Cleaning & Preparation (MySQL)
Data quality checks and transformations were executed via MySQL (`customer_churn_staging` table):
- Inspected overall structure, column data types, and record integrity.
- Verified absence of duplicate customer IDs.
- Handled missing values in `TotalCharges` (identified 11 records with `Tenure = 0` months; set missing `TotalCharges` to `$0.00` to retain all 7,043 rows).
- Formatted `MonthlyCharges` and `TotalCharges` explicitly to `DECIMAL(10,2)`.

### 2.Exploratory Data Analysis (SQL)
Conducted deep-dive queries examining churn variance across demographics, service tiers, payment methods, tenure buckets, and contract types to calculate group-level churn rates and revenue impacts.

### 3.Dashboard Development (Power BI)
Built a two-page interactive Power BI report (`.pbix`):
* **Page 1: Executive Overview**
  - Core KPIs: Total Customers, Churned/Retained Counts, Churn Rate, Retention Rate, Monthly Revenue at Risk.
  - Visual distributions: Churn by Contract Type, Tenure, Payment Method, and Contract Revenue Exposure.
* **Page 2: Customer Churn Drivers**
  - Demographic breakdowns and service add-on adoption rates.
  - Interactive slice-and-dice functionality for granular segment analysis.

---

## Key Findings

### Overall Performance Metrics
| Metric | Result |
| :--- | :--- |
| **Total Customers** | 7,043 |
| **Churned Customers** | 1,869 |
| **Retained Customers** | 5,174 |
| **Overall Churn Rate** | **26.54%** |
| **Retention Rate** | **73.46%** |

---

### Churn Drivers Breakdown

#### 1. Contract Type
| Contract Type | Churn Rate |
| :--- | :--- |
| **Month-to-month** | **42.71%** |
| **One year** | 11.27% |
| **Two year** | 2.83% |

*Month-to-month contracts represent the vast majority of customer departures.*

#### 2. Customer Tenure
| Tenure Window | Churn Rate |
| :--- | :--- |
| **0–12 months** | **47.44%** |
| **13–24 months** | 28.71% |
| **25–48 months** | 20.39% |
| **49–72 months** | 9.51% |

*Churn risk declines steadily as customer tenure increases.*

#### 3. Internet Service Category
| Internet Service | Churn Rate |
| :--- | :--- |
| **Fiber Optic** | **41.89%** |
| **DSL** | 18.96% |
| **No Internet Service** | 7.40% |

#### 4. Impact of Value-Added Services
Customers **without** additional security/support services churn at significantly higher rates:

| Service Category | Churn Rate (Without Service) | Churn Rate (With Service) |
| :--- | :---: | :---: |
| **Online Security** | **41.77%** | 14.61% |
| **Tech Support** | **41.64%** | 15.17% |
| **Online Backup** | **39.93%** | 21.53% |
| **Device Protection** | **39.13%** | 22.50% |

#### 5. Payment Method
| Payment Method | Churn Rate |
| :--- | :--- |
| **Electronic Check** | **45.29%** |
| **Mailed Check** | 19.11% |
| **Bank Transfer (Automatic)** | 16.71% |
| **Credit Card (Automatic)** | 15.24% |

---

### Financial Exposure (Revenue at Risk)
| Metric | Value |
| :--- | :--- |
| **Monthly Charges Lost to Churn** | **$139,130.85** / month |
| **Average Monthly Charge (Churned Account)** | **$74.44** |
| **Historical Total Charges (Churned Accounts)** | **$311,644.55** |

> **Note:** Month-to-month accounts account for **$120,847.10** (86.85%) of total monthly revenue at risk. *Revenue at risk measures current monthly charges tied to churned accounts and does not constitute a net profit loss calculation.*

---

## Business Recommendations
1. **Optimize Early Onboarding:** Introduce target engagement campaigns for new subscribers during their first 12 months.
2. **Contract Migration Incentives:** Develop promotional incentives to transition month-to-month customers toward 1-year or 2-year agreements.
3. **Fiber Optic Service Review:** Investigate technical stability, pricing perception, and customer satisfaction specific to Fiber Optic tiers.
4. **Bundle Value-Added Services:** Offer discounted bundles featuring *Online Security* and *Tech Support* to boost retention.
5. **Streamline Payments:** Encourage automated payment adoption (Credit Card / Bank Transfer) to reduce friction seen in Electronic Check workflows.

---

## Limitations
- Dataset represents a static snapshot; historical departure timing/time-series dynamics are unavailable.
- Findings demonstrate correlation, not direct causality.
- Predictive modeling and machine learning classification were outside the scope of this project.

---

## Repository Structure
```text
telco-customer-churn-analysis/
│
├── SQL/
│   ├── Data_Cleaning.sql
│   └── Exploratory_Data_Analysis.sql
│
├── PowerBI/
│   └── Telco_Customer_Churn.pbix
│
├── Report/
│   └── Telco_Customer_Churn_Report.docx
│
├── Images/
│   ├── Executive_Overview.png
│   └── Churn_Drivers.png
│
└── README.md
```

---

## Skills Demonstrated
- Data wrangling, cleaning, and schema staging via SQL.
- Exploratory data analytics and statistical aggregations.
- Interactive dashboard construction and data storytelling in Power BI.
- Metric calculation using DAX and data transformations in Power Query.
- Translating data observations into actionable business recommendations.
