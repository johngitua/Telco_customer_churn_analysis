
/*
===========================================================
PROJECT: TELCO CUSTOMER CHURN ANALYSIS
AUTHOR:John Gitua
DATABASE: Customer_churn
TOOL: MySQL Workbench

OBJECTIVE:
To explore and clean the Telco Customer Churn dataset
before conducting exploratory data analysis and building
a customer churn dashboard in Power BI.

SCRIPT: DATA EXPLORATION AND CLEANING
===========================================================
*/


-- =========================================================
-- SECTION 1: DATABASE SETUP AND STAGING
-- Objective: Create a working copy of the original dataset
-- =========================================================

CREATE DATABASE IF NOT EXISTS Customer_churn;

USE Customer_churn;

-- Create a staging table from the original dataset

DROP TABLE IF EXISTS customer_churn_staging;

CREATE TABLE customer_churn_staging
LIKE telco_customer_churn;

INSERT INTO customer_churn_staging
SELECT *
FROM telco_customer_churn;


-- =========================================================
-- SECTION 2: INITIAL DATA EXPLORATION
-- Objective: Understand the dataset structure and size
-- =========================================================

-- 2.1 Inspect the table structure

DESCRIBE customer_churn_staging;


-- 2.2 Determine the total number of records

SELECT COUNT(*) AS total_records
FROM customer_churn_staging;


-- 2.3 Preview the first 10 records

SELECT *
FROM customer_churn_staging
LIMIT 10;


-- =========================================================
-- SECTION 3: DATA QUALITY ASSESSMENT
-- Objective: Identify missing values, duplicates,
-- inconsistencies and unexpected numerical values
-- =========================================================

-- 3.1 Identify missing values in key columns

SELECT
    COUNT(*) AS total_records,
    SUM(customerID IS NULL) AS missing_customerID,
    SUM(gender IS NULL) AS missing_gender,
    SUM(tenure IS NULL) AS missing_tenure,
    SUM(MonthlyCharges IS NULL) AS missing_MonthlyCharges,
    SUM(TotalCharges IS NULL) AS missing_TotalCharges,
    SUM(Churn IS NULL) AS missing_Churn
FROM customer_churn_staging;


-- 3.2 Identify blank values in TotalCharges

SELECT
    COUNT(*) AS blank_totalcharges
FROM customer_churn_staging
WHERE TotalCharges IS NULL
   OR TRIM(TotalCharges) = '';

/*FINDING:
          Missing TotalCharges values were associated with
          customers whose tenure was zero.
          After investigation, these values were replaced with zero.*/

-- 3.3 Identify duplicate customer IDs

SELECT
    customerID,
    COUNT(*) AS occurrences
FROM customer_churn_staging
GROUP BY customerID
HAVING COUNT(*) > 1;

-- 3.4 Count customer IDs appearing more than once

SELECT COUNT(*) AS duplicate_customer_ids
FROM (
    SELECT customerID
    FROM customer_churn_staging
    GROUP BY customerID
    HAVING COUNT(*) > 1
) AS duplicates;

-- FINDING:
-- There are no duplicate customer IDs in the original data

-- 3.5 Examine unique categorical values

SELECT DISTINCT gender
FROM customer_churn_staging;

SELECT DISTINCT Contract
FROM customer_churn_staging;

SELECT DISTINCT InternetService
FROM customer_churn_staging;

SELECT DISTINCT PaymentMethod
FROM customer_churn_staging;

SELECT DISTINCT Churn
FROM customer_churn_staging;

SELECT DISTINCT PaperlessBilling
FROM customer_churn_staging;

SELECT DISTINCT SeniorCitizen
FROM customer_churn_staging;

SELECT DISTINCT Partner
FROM customer_churn_staging;

SELECT DISTINCT Dependents
FROM customer_churn_staging;

SELECT DISTINCT PhoneService
FROM customer_churn_staging;

SELECT DISTINCT MultipleLines
FROM customer_churn_staging;

SELECT DISTINCT OnlineSecurity
FROM customer_churn_staging;

SELECT DISTINCT OnlineBackup
FROM customer_churn_staging;

SELECT DISTINCT DeviceProtection
FROM customer_churn_staging;

SELECT DISTINCT TechSupport
FROM customer_churn_staging;

SELECT DISTINCT StreamingTV
FROM customer_churn_staging;

SELECT DISTINCT StreamingMovies
FROM customer_churn_staging;


-- 3.6 Examine numerical value ranges

SELECT
    MIN(tenure) AS minimum_tenure,
    MAX(tenure) AS maximum_tenure,
    MIN(MonthlyCharges) AS minimum_monthly_charges,
    MAX(MonthlyCharges) AS maximum_monthly_charges
FROM customer_churn_staging;


-- =========================================================
-- SECTION 4: HANDLING MISSING VALUES
-- Objective: Investigate and appropriately handle
-- missing values in TotalCharges
-- =========================================================

-- 4.1 Investigate missing TotalCharges by customer tenure

SELECT
    tenure,
    COUNT(*) AS missing_count
FROM customer_churn_staging
WHERE TotalCharges IS NULL
   OR TRIM(TotalCharges) = ''
GROUP BY tenure;


-- 4.2 Convert blank TotalCharges values into NULL

UPDATE customer_churn_staging
SET TotalCharges = NULL
WHERE TRIM(TotalCharges) = '';


-- 4.3 Replaced missing charges for zero-tenure customers
--  after confirming that these are newly registered
-- customers with no accumulated charges.

UPDATE customer_churn_staging
SET TotalCharges = '0'
WHERE tenure = 0
AND TotalCharges IS NULL;

-- 4.4 Review any remaining missing TotalCharges values

SELECT
    customerID,
    tenure,
    TotalCharges
FROM customer_churn_staging
WHERE TotalCharges IS NULL;

-- FINDING: There are no missing TotalCharges

-- =========================================================
-- SECTION 5: DATA TYPE CONVERSION
-- Objective: Ensure numerical columns have appropriate
-- data types for calculations and analysis
-- =========================================================

ALTER TABLE customer_churn_staging
MODIFY TotalCharges DECIMAL(10,2) NULL;

ALTER TABLE customer_churn_staging
MODIFY MonthlyCharges DECIMAL(10,2);


-- =========================================================
-- SECTION 6: DATA STANDARDIZATION
-- Objective: Remove unnecessary spaces from categorical
-- values to ensure consistency
-- =========================================================

UPDATE customer_churn_staging
SET
    gender = TRIM(gender),
    Partner = TRIM(Partner),
    Dependents = TRIM(Dependents),
    PhoneService = TRIM(PhoneService),
    MultipleLines = TRIM(MultipleLines),
    InternetService = TRIM(InternetService),
    OnlineSecurity = TRIM(OnlineSecurity),
    OnlineBackup = TRIM(OnlineBackup),
    DeviceProtection = TRIM(DeviceProtection),
    TechSupport = TRIM(TechSupport),
    StreamingTV = TRIM(StreamingTV),
    StreamingMovies = TRIM(StreamingMovies),
    Contract = TRIM(Contract),
    PaperlessBilling = TRIM(PaperlessBilling),
    PaymentMethod = TRIM(PaymentMethod),
    Churn = TRIM(Churn);


-- =========================================================
-- SECTION 7: DATA VALIDATION
-- Objective: Verify that the cleaning process has not
-- introduced errors or inconsistencies
-- =========================================================

-- 7.1 Compare original and staging record counts

SELECT
    (SELECT COUNT(*) FROM telco_customer_churn)
        AS original_records,
    (SELECT COUNT(*) FROM customer_churn_staging)
        AS staging_records;


-- 7.2 Check customer ID uniqueness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customerID) AS unique_customers
FROM customer_churn_staging;


-- 7.3 Check remaining missing TotalCharges values

SELECT COUNT(*) AS missing_totalcharges
FROM customer_churn_staging
WHERE TotalCharges IS NULL;


-- 7.4 Check for invalid tenure values

SELECT *
FROM customer_churn_staging
WHERE tenure < 0
   OR tenure > 72;


-- 7.5 Check for negative charges

SELECT *
FROM customer_churn_staging
WHERE MonthlyCharges < 0
   OR TotalCharges < 0;


-- 7.6 Check valid SeniorCitizen values

SELECT DISTINCT SeniorCitizen
FROM customer_churn_staging;


-- 7.7 Check valid Churn categories

SELECT DISTINCT Churn
FROM customer_churn_staging;

-- SECTION 8: FINAL CLEANED DATASET
-- =========================================================

SELECT *
FROM customer_churn_staging;

-- END OF DATA EXPLORATION AND CLEANING SCRIPT
