/*
===============================================================================
PROJECT: TELCO CUSTOMER CHURN ANALYSIS
DATABASE: Customer_churn
SOURCE TABLE: customer_churn_staging
TOOLS: MySQL
===============================================================================

PROJECT OBJECTIVE
Analyse customer churn patterns, identify customer segments associated with
higher churn, examine service and payment-method relationships and estimate
the recurring monthly revenue associated with churned customers.

IMPORTANT ANALYTICAL NOTES
- Churn rate = churned customers / total customers in the relevant group.
- Customer counts shown in segment analyses are group totals unless explicitly
  labelled churned_customers.
- The analysis identifies associations, not necessarily causal relationships.
- monthly_revenue_at_risk is the sum of monthly charges for customers marked
  as churned. It is an estimate of recurring revenue associated with those
  customers, not a verified forecast of future financial losses.
- TotalCharges represents historical charges accumulated during each
  customer's recorded relationship with the company.
- Monetary values are in the source dataset's currency (USD in the original
  IBM Telco Customer Churn dataset).
- Some customer segments have relatively small sample sizes.
  Churn rates from these groups should be interpreted 
  cautiously because a small number of customer departures
  can substantially change the reported percentage.  

===============================================================================
0. DATABASE AND DATA PREVIEW
===============================================================================
*/

USE Customer_churn;

-- A preview of the cleaned staging table.
SELECT *
FROM customer_churn_staging;


/*
===============================================================================
EDA 01: OVERALL CUSTOMER CHURN
===============================================================================

BUSINESS QUESTION 1:
What percentage of customers are leaving the company?

This query summarises the customer base and calculates the churn and retention
rates in one result.
*/

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage,
    ROUND(
        SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS retention_rate_percentage
FROM customer_churn_staging;

/*
FINDING:
The company has 7,043 customers, of whom 5,174 (73.46%) are retained,
while 1,869 (26.54%) have churned. Although most customers remain with the
company, a churn rate of approximately 27% indicates a customer-retention
challenge worth investigating.

The churn rate alone does not establish whether company performance is poor;
it should ideally be compared with an appropriate industry or historical
benchmark.
*/


-- Number and percentage of customers in each churn category.
SELECT
    Churn AS churn_status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM customer_churn_staging
GROUP BY Churn
ORDER BY customer_count DESC;


/*
===============================================================================
EDA 02: CUSTOMER CHURN BY DEMOGRAPHIC GROUPS
===============================================================================

BUSINESS QUESTION 2:
Which customer groups have the highest churn rates?

The following queries compare churn rates across demographic and household
characteristics. Churn rates, rather than counts alone, are used to compare
groups of different sizes.
*/


-- 2.1 Churn by gender
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY gender
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Female customers recorded a churn rate of 26.92%
(939 out of 3,488 customers), compared with 26.16%
(930 out of 3,555 customers) among male customers.

The difference is relatively small, suggesting that
gender is not a substantial differentiating factor
in churn within this dataset.
*/


-- 2.2 Churn by senior citizen status
SELECT
    SeniorCitizen,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY SeniorCitizen
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Senior citizens have a churn rate of 41.68% (476 churned customers),
compared with 23.61% (1,393 churned customers) among non-senior citizens.
This is a notable difference and may warrant further investigation.
*/


-- 2.3 Churn by partner status
SELECT
    Partner,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY Partner
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without partners have a churn rate of 32.96% (1,200 churned
customers) compared to the 19.66% (669 churned customers) among customers
with partners.
*/


-- 2.4 Churn by dependents status
SELECT
    Dependents,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY Dependents
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without dependents have a churn rate of 31.28% (1,543 churned
customers) compared to a 15.45% (326 churned customers) churn rate among customers
with dependents.
*/


/*
===============================================================================
EDA 03: COMBINED CUSTOMER-SEGMENT ANALYSIS
===============================================================================

BUSINESS QUESTION 2 (continued):
Do combinations of demographic and household characteristics reveal customer
segments with particularly high churn rates?

These cross-tabulations help explore combinations of characteristics. They
should be interpreted as descriptive associations, not causal effects.
*/


-- 3.1 Churn by senior citizen and partner status
SELECT
    SeniorCitizen,
    Partner,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY SeniorCitizen, Partner
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Senior citizens without partners have the highest reported churn rate in
this cross-tabulation: 48.86% (278 churned out of 569 customers).

They are followed by senior citizens with partners at 34.55% (198 out of 573),
non-senior citizens without partners at 30.01% (922 out of 3,072) and
non-senior citizens with partners at 16.65% (471 out of 2,829).
*/


-- 3.2 Churn by dependents and contract type
SELECT
    Dependents,
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY Dependents, Contract
ORDER BY churn_rate_percentage DESC;

/*
FINDINGS:
- Customers without dependents on month-to-month contracts have a churn rate
  of 45.24% (1,396 out of 3,086 customers).
- Customers with dependents on month-to-month contracts have a churn rate
  of 32.83% (259 out of 789).
- Customers with dependents on one-year contracts have a churn rate of
  12.42% (117 out of 942).
- Customers without dependents on one-year contracts have a churn rate of
  9.23% (49 out of 531).
- Customers without dependents on two-year contracts have a churn rate of
  3.31% (30 out of 905).
- Customers with dependents on two-year contracts have a churn rate of
  2.28% (18 out of 790).
*/


/*
===============================================================================
EDA 04: CUSTOMER CHURN BY TENURE
===============================================================================

BUSINESS QUESTION 4:
Does customer tenure affect churn?

Tenure is grouped into four intervals to examine how churn varies with the
length of the customer relationship.
*/


-- 4.1 Overall churn by tenure group
SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 36 THEN '25-36 months'
        WHEN tenure BETWEEN 37 AND 48 THEN '37-48 months'
        WHEN tenure BETWEEN 49 AND 60 THEN '49-60 months'
        WHEN tenure BETWEEN 61 AND 72 THEN '61-72 months'
        ELSE 'Unclassified'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY tenure_group
ORDER BY
    CASE tenure_group
        WHEN '0-12 months' THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-36 months' THEN 3
        WHEN '37-48 months' THEN 4
        WHEN '49-60 months' THEN 5
        ELSE 6
    END;

/*
FINDING:
Churn decreases as tenure increases:
- 0-12 months: 47.44% (1,037 out of 2,186 customers).
- 13-24 months: 28.71% (294 out of 1,024 customers).
- 25-36 months: 21.63% (180 out of 832 customers).
- 37-48 months: 19.03% (145 out of 762 customers).
- 49-60 months: 14.42% (120 out of 832 customers).
- 61-72 months: 6.61% (93 out of 1407 customers).

The first 12 months appear to be an important period for customer retention.
*/


-- 4.2 Churn by senior citizen status, partner status and tenure group
WITH overall AS (
    SELECT
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*) AS overall_churn_rate
    FROM customer_churn_staging
),
segment_analysis AS (
    SELECT
        SeniorCitizen,
        Partner,
        CASE
            WHEN tenure BETWEEN 0 AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 36 THEN '25-36 months'
        WHEN tenure BETWEEN 37 AND 48 THEN '37-48 months'
        WHEN tenure BETWEEN 49 AND 60 THEN '49-60 months'
        WHEN tenure BETWEEN 61 AND 72 THEN '61-72 months'
        ELSE 'Unclassified'
        END AS tenure_group,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            AS churned_customers
    FROM customer_churn_staging
    GROUP BY
        SeniorCitizen,
        Partner,
        tenure_group
)
SELECT
    s.*,
    ROUND(
        s.churned_customers * 100.0 / s.total_customers, 2
    ) AS churn_rate,
    ROUND(
        (s.churned_customers * 100.0 / s.total_customers)
        - o.overall_churn_rate, 2
    ) AS difference_from_overall
FROM segment_analysis s
CROSS JOIN overall o
ORDER BY churn_rate DESC;
/*
KEY FINDINGS:
Senior citizens with 0–12 months of tenure recorded the
highest churn rates, regardless of partner status.
Those without partners had a churn rate of 68.42%
(156 out of 228 customers).
Those with partners had a churn rate of 66.30%
(61 out of 92 customers).
Senior citizens continued to record relatively high churn
rates during the 13–24 month period.
Senior citizens without partners: 53.47%
(54 out of 101 customers).
Senior citizens with partners: 43.28%
(29 out of 67 customers).
Non-senior citizens without partners and with 0–12 months
of tenure recorded the largest number of churned customers
among the analysed segments: 637 out of 1,395 customers,
representing a churn rate of 45.66%.
Churn rates generally declined as customer tenure increased
across the analysed segments.
Senior citizens without partners: 68.42% at 0–12 months
compared with 14.53% at 49–72 months.
Senior citizens with partners: 66.30% at 0–12 months
compared with 16.80% at 49–72 months.
Non-senior citizens with partners: 38.85% at 0–12 months
compared with 7.55% at 49–72 months.
Non-senior citizens without partners: 45.66% at 0–12
months compared with 9.85% at 49–72 months.
*/


-- 4.3 Churn by dependents, contract type and tenure group
SELECT
    Dependents,
    Contract,
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 36 THEN '25-36 months'
        WHEN tenure BETWEEN 37 AND 48 THEN '37-48 months'
        WHEN tenure BETWEEN 49 AND 60 THEN '49-60 months'
        WHEN tenure BETWEEN 61 AND 72 THEN '61-72 months'
        ELSE 'Unclassified'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY
    Dependents,
    Contract,
    tenure_group
ORDER BY churn_rate_percentage DESC;

/*
KEY FINDINGS:
Customers without dependents on month-to-month contracts
recorded the highest churn rates across the analysed
segments.
0-12 months: 53.43% (881 out of 1,649 customers).
13-24 months: 40.46% (231 out of 571 customers).
25-48 months: 35.48% (215 out of 606 customers).
49-72 months: 26.54% (69 out of 260 customers).
Month-to-month customers without dependents consistently
recorded higher churn rates than those with dependents
across all tenure groups.
The largest difference occurred among customers with
0-12 months of tenure: 53.43% versus 41.45%.
Longer-term contracts were associated with substantially
lower churn rates.
One-year contracts recorded churn rates ranging from
5.26% to 15.94%.
Two-year contracts recorded churn rates ranging from
0% to 3.65%.
Month-to-month contracts recorded considerably higher
churn rates, reaching 53.43%.
Two-year contract customers recorded the lowest churn
rates across the analysed segments.
The highest churn rate among these segments was 3.65%,
recorded among customers without dependents and with
49-72 months of tenure.
Several segments recorded zero churn, although their
customer counts were relatively small.
Churn generally declined with increasing tenure among
month-to-month customers.
Customers without dependents: 53.43% at 0-12 months
compared with 26.54% at 49-72 months.
Customers with dependents: 41.45% at 0-12 months
compared with 24.39% at 49-72 months.
*/


/*
===============================================================================
EDA 05: CUSTOMER CHURN BY CONTRACT TYPE
===============================================================================

BUSINESS QUESTION 3:
Are customers on month-to-month subscriptions more likely to leave than
customers on one-year or two-year contracts?
*/

WITH contract_analysis AS (
    SELECT
        Contract,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers
    FROM customer_churn_staging
    GROUP BY Contract
)
SELECT
    Contract,
    total_customers,
    churned_customers,
    ROUND(churned_customers * 100.0 / total_customers, 2)
        AS churn_rate_percentage
FROM contract_analysis
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
- Month-to-month contracts have the highest churn rate at 42.71%.
- One-year contracts have a churn rate of 11.27%.
- Two-year contracts have the lowest churn rate at 2.83%.

The results show a strong association between shorter contract duration and
higher churn. They do not by themselves, prove that contract duration causes
customers to leave.
*/


/*
===============================================================================
EDA 06: CUSTOMER CHURN BY INTERNET AND ADDITIONAL SERVICES
===============================================================================

BUSINESS QUESTION 5:
Which services are associated with higher customer churn?

The following queries compare churn rates across internet service and
additional service categories.
*/


-- 6.1 Churn by internet service
SELECT
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY InternetService
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
- Fibre optic customers have the highest churn rate at 41.89%, with 3,096
  customers in this category.
- DSL customers have a churn rate of 18.96%, with 2,421 customers.
- Customers without internet service have the lowest churn rate at 7.40%,
  with 1,526 customers.
*/


-- 6.2 Churn by OnlineSecurity
SELECT
    OnlineSecurity,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY OnlineSecurity
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without OnlineSecurity have a churn rate of 41.77% (3,498
customers in the category), compared to 14.61% among customers with
OnlineSecurity (2,019 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).
*/


-- 6.3 Churn by OnlineBackup
SELECT
    OnlineBackup,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY OnlineBackup
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without OnlineBackup have a churn rate of 39.93% (3,088
customers in the category), compared to 21.53% among customers with
OnlineBackup (2,429 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).
*/


-- 6.4 Churn by DeviceProtection
SELECT
    DeviceProtection,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY DeviceProtection
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without DeviceProtection have a churn rate of 39.13% (3,095
customers in the category), compared to 22.50% among customers with
DeviceProtection (2,422 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).
*/


-- 6.5 Churn by TechSupport
SELECT
    TechSupport,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY TechSupport
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without TechSupport have a churn rate of 41.64% (3,473
customers in the category), compared to 15.17% among customers with
TechSupport (2,044 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).
*/


-- 6.6 Churn by StreamingTV
SELECT
    StreamingTV,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY StreamingTV
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without StreamingTV have a churn rate of 35.52% (2,810
customers in the category), compared to 30.07% among customers with
StreamingTV (2,707 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).
*/


-- 6.7 Churn by StreamingMovies
SELECT
    StreamingMovies,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY StreamingMovies
ORDER BY churn_rate_percentage DESC;

/*
FINDING:
Customers without StreamingMovies have a churn rate of 33.68% (2,785
customers in the category), compared to 29.94% among customers with
StreamingMovies (2,732 customers). Customers with no internet service have
a churn rate of 7.40% (1,526 customers).

INTERPRETATION:
The largest observed differences are for OnlineSecurity and TechSupport.
These relationships may be worth investigating further. They do not establish
that subscribing to these services directly prevents churn. Contract type,
tenure, internet service and other factors may also be related to churn.
*/


/*
===============================================================================
EDA 07: CUSTOMER CHURN BY PAYMENT METHOD
===============================================================================

BUSINESS QUESTION 5 (continued):
Are particular payment methods associated with higher customer churn?
*/

SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customer_churn_staging
GROUP BY PaymentMethod
ORDER BY churn_rate_percentage DESC;

/*
FINDINGS:
- Electronic check customers have the highest churn rate at 45.29%, with
  2,365 customers in this payment-method category.
- Mailed check customers have a churn rate of 19.11%, with 1,612 customers.
- Automatic bank transfer customers have a churn rate of 16.71%, with
  1,544 customers.
- Automatic credit card customers have the lowest churn rate at 15.24%,
  with 1,522 customers.

The counts above are total customers in each payment-method category, not
the number of churned customers in each category.
*/


/*
===============================================================================
EDA 08: FINANCIAL IMPACT OF CUSTOMER CHURN
===============================================================================

BUSINESS QUESTION 6:
How much recurring monthly revenue is associated with customers who churned?

This query calculates the combined monthly charges and historical charges
for customers whose Churn status is 'Yes'.
*/

SELECT
    COUNT(*) AS churned_customers,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk,
    ROUND(AVG(MonthlyCharges), 2) AS average_monthly_charge,
    ROUND(SUM(TotalCharges), 2) AS historical_revenue_from_churned
FROM customer_churn_staging
WHERE Churn = 'Yes';

/*
FINDINGS:
- The company has 1,869 churned customers, representing 26.54% of its
  customer base.
- These customers account for $139,130.85 in combined monthly charges.
- The average monthly charge per churned customer is $74.44.
- Historical charges accumulated by these customers amount to $311,644.55.

The $139,130.85 is an estimate of monthly recurring revenue associated with
customers who have churned. It should not be presented as a verified measure
of actual future financial losses. The $311,644.55 represents historical
charges, not future revenue.
*/


/*
===============================================================================
EDA 09: MONTHLY REVENUE AT RISK BY CONTRACT TYPE
===============================================================================

BUSINESS QUESTION 7:
Which contract type contributes the most to monthly revenue associated with
churned customers?

This analysis groups churned customers by contract type and compares the
combined monthly charges associated with each group.
*/

SELECT
    Contract,
    COUNT(*) AS churned_customers,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk,
    ROUND(AVG(MonthlyCharges), 2) AS average_monthly_charge,
    ROUND(
        SUM(MonthlyCharges) * 100.0
        / (
            SELECT SUM(MonthlyCharges)
            FROM customer_churn_staging
            WHERE Churn = 'Yes'
        ),
        2
    ) AS percentage_of_monthly_revenue_at_risk
FROM customer_churn_staging
WHERE Churn = 'Yes'
GROUP BY Contract
ORDER BY monthly_revenue_at_risk DESC;

/*
FINDINGS:
- Month-to-month contracts account for $120,847.10 in monthly revenue at
  risk from 1,655 churned customers.
- One-year contracts account for $14,118.45 from 166 churned customers.
- Two-year contracts account for $4,165.30 from 48 churned customers.
- Month-to-month contracts contribute approximately 86.85% of the total
  monthly revenue at risk.

Although longer-term contract customers have higher average monthly charges,
they contribute less to the total monthly revenue at risk because fewer
customers in those groups churn.
*/

/*
===============================================================================
OVERALL EDA SUMMARY
===============================================================================

1. OVERALL CHURN
   - Overall churn rate: 26.54%.
   - 1,869 out of 7,043 customers have churned.

2. CUSTOMER DEMOGRAPHICS
   - Senior citizens have a higher churn rate (41.68%)
     than non-senior citizens (23.61%).
   - Customers without partners and without dependents
     also exhibit higher churn rates.

3. CUSTOMER TENURE
   - Customers with 0-12 months of tenure have the
     highest overall churn rate (47.44%).
   - Churn generally declines as tenure increases.

4. CONTRACT TYPE
   - Month-to-month customers have the highest churn
     rate (42.71%).
   - Two-year customers have the lowest churn rate (2.83%).

5. CUSTOMER SERVICES
   - Customers without OnlineSecurity (41.77%) and
     TechSupport (41.64%) have particularly high churn rates.

6. PAYMENT METHOD
   - Electronic check customers have the highest
     churn rate (45.29%).

7. REVENUE AT RISK
   - Churned customers account for $139,130.85 in
     combined monthly charges.
   - Month-to-month customers account for approximately
     86.85% of this amount.

OVERALL BUSINESS IMPLICATION:
Retention efforts could prioritise early-tenure customers,
month-to-month subscribers and customer segments with
particularly high observed churn rates.

These findings are descriptive associations and should
not be interpreted as proof of causation.
===============================================================================
*/  
  
  
/*
===============================================================================
END OF EXPLORATORY DATA ANALYSIS
===============================================================================
*/
