## Project Overview

Bystack is a retail banking institution that offers both transactional and investment services to its customers. With digital banking adoption increasing and competition rising, understanding customer behavior has become crucial.

This project analyzes customer account performance, transaction patterns, and investment activity over a 22-year period (2000–2022). The goal is to uncover insights that support customer segmentation, product optimization, and revenue strategy. 

The findings will serve key stakeholders including the Marketing Department, Customer Insight Teams, and Finance Executives to guide data-driven decision-making.


## Business Objectives

This analysis aims to:

- Identify high-value customers for premium offerings and retention planning.
- Analyze customer financial activity based on transaction and account usage behavior.
- Understand investment patterns to uncover product opportunity areas.
- Study long-term transaction volume trends to support capacity planning and policy formulation.

---

## Data Structure Overview

The dataset consists of nine interconnected tables reflecting core banking operations.  
Only **four tables** were required to answer the business questions defined in this project.

| Table Name        | Used in Analysis | Purpose |
|------------------|------------------|---------|
| `FB.Customers`   | ✔ | Stores customer demographic and profile details. |
| `FB.Accounts`    | ✔ | Contains account financial metadata including account type, balance, and ownership. |
| `FB.Transactions`| ✔ | Records transactional activities including deposits, withdrawals, payments, and transfers. |
| `FB.Investments` | ✔ | Logs investment activity including investment type and capital amount. |
| `FB.Branches`    | ✖ | Branch identification and location data. |
| `FB.Employees`   | ✖ | Employee and staffing details. |
| `FB.CreditCards` | ✖ | Credit card product usage and associated limits. |
| `FB.Loans`       | ✖ | Loans issued to customers including interest rate and balance. |
| `FB.Payments`    | ✖ | Card-based and bill payment processing data. |

Tables not used were excluded due to irrelevance to the analytical scope.

## ER Diagram
---<img width="1536" height="857" alt="Screenshot 2025-11-24 225952" src="https://github.com/user-attachments/assets/c87113c2-4d4c-49a1-a962-5970d822d46d" />

## Tools & Technology
Microsoft SQL Server (SSMS) — for writing and running SQL queries
Excel  — for reviewing dataset structure and data cleaning

## Executive Summary

The analysis examined Bystack Bank’s customer account, transaction, and investment data (2011 – 2023) to identify high-value customers, measures account activity, and investment engagement. The analysis uses customer, accounts, transactions and investments tables.
Key Findings
- Top 63 customers hold 38% of total value — losing them would materially impact revenue.
- 49 of 63 (77.8%) top customers hold more than 1 distinct investment type — ideal for premium advisory upsell.
- 39% of registered users have zero balance and no recorded transactions — indicating dormant accounts or onboarding drop-off.
- Yearly transaction volume fluctuates, peaking in 2020 with a noticeable decline in 2015 and 2018-2019, and stabilization during 2021-2022

Together, these findings indicate a high dependence on a small set of sophisticated investors while a large inactive cohort remains untapped. This implies immediate opportunities for targeted retention and activation programs.

Bystack can benefit by assigning dedicated relationship managers and introducing tiered premium services to reduce churn risk. Also, redundant accounts can be reduced by offering personalized investment advisory and consolidation services


---

## Insights Summary

### Business Question 1 
**Objective:**
Identify the top 10% high-value customers based on total sales

`` SQL Query ``
```
-- Retrieves TotalBalance, TotalInvestment, and TotalValue per customer
With CustomerTotalValue AS ( 
SELECT 
A.CustomerID, 
CONCAT(C.FirstName,' ', C.lastName) AS FullName,
ISNULL(SUM(A.Balance),0) AS TotalBalannce,
ISNULL(SUM(I.Amount),0) AS TotalInvestment,
(ISNULL(SUM(A.Balance),0)+ ISNULL(SUM(I.Amount), 0)) AS TotalValue
FROM FB.Accounts A 
LEFT JOIN FB.Investments I 
	ON A.CustomerID = I.CustomerId
LEFT JOIN FB.Customers C
	ON A.CustomerID = C.CustomerID
GROUP BY A.CustomerID,CONCAT(C.FirstName,' ', C.lastName)
),
-- Ranks the customer i
RankedValue AS (
SELECT CT.CustomerID, 
CT.FullName,
CT.TotalValue,
NTILE(10) OVER ( ORDER BY TotalValue DESC) AS Ranks
FROM CustomerTotalValue CT
)
--gives result
SELECT *
FROM RankedValue RV
WHERE RV.RankS = 1;
```
``Result``

<img width="926" height="415" alt="Screenshot 2025-11-26 020144" src="https://github.com/user-attachments/assets/f069fe71-03b8-496e-9fc0-861a6c4f1e6b" />

- Analysis revels that only 6% (63 out of 1,000) constitute the top 10% by total value. Despite this small proportion, they hold 38% of the total customer value, reflecting a high concentration of financial value. Losing one or more of these customers would cause a great negative effect.
- The top 10% customers have an average total value nearly 4 times higher than the general customer base. This confirms the strong concentration of financial value held by this segment of customers.
- 84% of the high value customers hold more that one investment account, indicating high engagement. However, only 78% invest in more than one distinct type of investment type. This suggest that majority of the high-value customers invest in multiple assets rather than concentrating on one, showing high financial knowledge and long-term investment planning.





---

### **	Business Question 2 **
**Objective:**
Summarize customer account activities including deposits, withdrawals, and remaining balance.

`` SQL Query ``
```

SELECT c.CustomerID, 
ISNULL(SUM(A.Balance),0) AS Balance,
SUM(CASE WHEN T.TransactionType = 'Deposit' THEN T.Amount ELSE 0 END ) AS TotalDeposit,
SUM(CASE WHEN T.TransactionType = 'Withdrawal' THEN T.Amount ELSE 0 END ) AS TotalWithdrawal
FROM FB.Customers C
LEFT JOIN FB.Accounts A
	ON C.CustomerID = A.CustomerID
LEFT JOIN FB.Transactions T
	ON A.AccountID = T.AccountID
GROUP BY C.CustomerID
;

```
``Result``

<img width="727" height="430" alt="Screenshot 2025-11-26 020553" src="https://github.com/user-attachments/assets/144476e0-2a29-4338-b4b0-9601730267f0" />

Analysis shows that 39% of the company’s registered customers hold a zero-account balance and have no recorded transactions (deposits or withdrawals).
This pattern suggests the presence of newly onboarded but inactive customers, abandoned sign-ups, or dormant accounts with limited engagement.

While these users do not contribute to financial activity, they represent a high-potential segment for conversion, particularly if barriers during onboarding or product understanding exist.

---

### **Business Question 3 **
**Objective:**
Retrieve total investment value and types per customer.

`` SQL Query ``
```
-- Step 1: Aggregate total investment per customer
WITH TotalInvestments AS (
    SELECT 
        C.CustomerID,
        ISNULL(SUM(I.Amount),0) AS TotalInvestmentAmount
    FROM FB.Customers C
    LEFT JOIN FB.Investments I
    ON C.CustomerID = I.CustomerID
    GROUP BY C.CustomerID
),
-- Step 2: Get distinct investment types per customer
DistinctTypes AS (
    SELECT DISTINCT
        C.CustomerID,
        I.InvestmentType
    FROM FB.Customers C
    INNER JOIN FB.Investments I
        ON C.CustomerID = I.CustomerID
)
-- Step 3: Combine total amount with aggregated types
SELECT 
    T.CustomerID,    
    ROUND(T.TotalInvestmentAmount,2) AS TotalInvestmentAmount,
    STRING_AGG(D.InvestmentType, ', ') 
        WITHIN GROUP (ORDER BY D.InvestmentType ASC) AS InvestmentTypes
FROM TotalInvestments T
LEFT JOIN DistinctTypes D
    ON T.CustomerID = D.CustomerID
GROUP BY T.CustomerID,TotalInvestmentAmount
ORDER BY T.TotalInvestmentAmount DESC;

```
``Result``

<img width="579" height="429" alt="Screenshot 2025-11-26 021204" src="https://github.com/user-attachments/assets/946a09f0-a801-41ad-ac8d-0b79769b09e6" />


- The analysis indicates that 38% of customers have not participated in any investment products offered by the bank. This suggests possible gaps in awareness, perceived complexity, or limited confidence in investment services.

- Among the active investors, Stocks and ETFs account for 49% of investment activity, indicating a strong preference for well-known financial instruments. Additionally, 24% of investors participate in multiple investment types, reflecting a smaller segment with higher financial literacy or engagement.

---

### **Business Question 4**
**Objective:**
Calculate transaction volume by month and transaction type from 2011–2023

`` SQL Query ``
```
SELECT 
YEAR(TransactionDate) AS Year, 
MONTH(TransactionDate) AS Month,
TransactionType,
ROUND(ISNULL(SUM(Amount),0),2) AS TotalTransactionVolume
FROM FB.Transactions
WHERE TransactionDate >= '2011-01-01' AND TransactionDate < '2024-01-01'
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate),TransactionType;
```
``Result``

<img width="439" height="425" alt="Screenshot 2025-11-26 021317" src="https://github.com/user-attachments/assets/beafaf23-d17e-4953-b232-34ec0c6bfa31" />

-	The transaction distribution shows a balanced activity, with no  sector overwhelming the system. Payments accounts for the largest share at 27.45%, followed closely by Transfers (25.93%), while deposits (23.88%), and withdrawals (22.74%) make up the remaining share. There exists only a small volume gap between the highest transaction and lowest transaction. Indicating diverse usage of banking services by customers.

-	Yearly trend analysis shows a fluctuating performance rather than a steady growth. Between 2011 and 2013, transaction volumes were relatively stable. A noticeable drop occurred in 2015(about -12.6%), after which volumes increased to its highest level in 2020 marking peak transaction activity. The last two years shows a stabilization stage phase with little changes. 


##  Recommendations

Based on findings across all business questions, the following strategic actions are suggested:

###  1. 

- Implement loyalty or tiered premium programs (e.g., Gold / Platinum / Signature membership).
-	Offer customers in this segment personalized incentives and starter investment to further engage these customers.
-	Assign dedicated relationship managers to provide tailored support and advisory service to top clients.
-	Provide priority access to customer support and fast-track service channels for this segment


###  2. 

-	Implement automated onboarding reminders and guided tutorials to encourage first-time deposits and activity.
-	Customer support should review potential onboarding issues and assist affected customers to reduce abandonment rates.
-	Consider promotional strategies such as welcome bonuses to drive initial engagement.


###  3. 

-	Provide simplified financial education resources and product comparisons to reduce knowledge barriers.
-	Introduce limited-time bonuses or reduced fees to encourage new investor participation.
-	Highlight benefits of alternative products (e.g., bonds, mutual funds) to move customers from single-product to multi-product engagement.


###  4. 

-Investigate growth years (2016,2017, and 2020). Identify factors behind performance spikes. – such as marketing campaigns, service upgrades, and externals.
-	Analyze Decline periods (2015, 2018-2019: Pinpoint possible operational bottlenecks and customer dissatisfaction that might have caused the reduction in transaction activity.
-	Introduce cashback incentives of recurring payments to strengthen retention in the highest volume category

---

##  Final Note

This project demonstrates how SQL-driven data exploration can deliver actionable business intelligence for strategic planning in the banking sector.  
With further integration into BI tools (Power BI / Tableau), trends can be visualized and automated for real-time decision-support systems.

---

```
 Author: *Akinfisoye Erioluwa*  
 Year: 2025  
 Tools Used: **SQL Server**
