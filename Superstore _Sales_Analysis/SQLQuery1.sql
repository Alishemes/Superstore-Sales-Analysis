
-- 1. CREATE DATABASE + USE DATABASE

CREATE DATABASE SalesProject;
GO

USE SalesProject;
GO

-- 2. EDA

SELECT TOP 10 *
FROM superstore;

SELECT COUNT(*) AS total_rows
FROM superstore;

-- 3. CHECK NULL VALUES

SELECT *
FROM superstore 
WHERE Order_ID IS NULL
   OR Order_Date IS NULL 
   OR Sales IS NULL;

-- 4. DUPLICATES

WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_ID, Product_ID
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM superstore
)
SELECT *
FROM CTE
WHERE rn > 1;



-- 5. DATA CLEANING (REMOVE DUPLICATES)

WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_ID, Product_ID
            ORDER BY Row_ID
        ) AS rn
    FROM superstore
)
DELETE FROM CTE 
WHERE rn > 1;



-- 6. TABLE VIEW 


CREATE OR ALTER VIEW vw_fact_sales AS
SELECT
    Row_ID,
    Order_ID,
    CAST(Order_Date AS DATE) AS Order_Date,
    Customer_ID,
    Product_ID,
    ISNULL(Sales, 0) AS Sales
FROM superstore;
GO


CREATE OR ALTER VIEW vw_dim_products AS
SELECT 
    Product_ID,
    MAX(Product_Name) AS Product_Name,
    MAX(Category) AS Category,
    MAX(Sub_Category) AS Sub_Category
FROM superstore
GROUP BY Product_ID;
GO


CREATE OR ALTER VIEW vw_dim_customers AS
SELECT 
    Customer_ID,
    MAX(Customer_Name) AS Customer_Name,
    MAX(Segment) AS Segment,
    MAX(City) AS City,
    MAX(State) AS State,
    MAX(Region) AS Region
FROM superstore
GROUP BY Customer_ID;
GO

-- 9. BUSINESS ANALYSIS


-- ลฬใวแํ วแใศํฺวส
SELECT 
    SUM(Sales) AS total_sales 
FROM vw_fact_sales;


-- สอแํแ วแใศํฺวส ิๅัํ๐ว
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS month,
    SUM(Sales) AS total_sales 
FROM vw_fact_sales 
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY month;



SELECT 
    FORMAT(Order_Date, 'yyyy') AS YEAR,
    SUM(Sales) AS total_sales 
FROM vw_fact_sales 
GROUP BY FORMAT(Order_Date, 'yyyy')
ORDER BY YEAR;

-- ลฬใวแํ วแใศํฺวส อำศ วแใไุÞษ


SELECT 
    c.Region,
    SUM(f.Sales) AS total_sales
FROM vw_fact_sales f
JOIN vw_dim_customers c
    ON f.Customer_ID = c.Customer_ID
GROUP BY c.Region
ORDER BY total_sales DESC;



-- วแสร฿ฯ ใไ ฺฯใ ๆฬๆฯ ส฿ัวั Ýํ ฬฯๆแ วแฺใแวม
SELECT 
    Customer_ID,
    COUNT(*) AS ฺฯฯ_วแส฿ัวั
FROM vw_dim_customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1
ORDER BY ฺฯฯ_วแส฿ัวั DESC;