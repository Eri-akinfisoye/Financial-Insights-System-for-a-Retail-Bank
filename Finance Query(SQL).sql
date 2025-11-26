
 --Question 1)

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
WHERE RV.RankS = 1
ORDER BY TotalValue;


--Question 2)(37)

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


--question 3) (38)
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
GROUP BY T.CustomerID
ORDER BY T.TotalInvestmentAmount DESC;


--Question 4) 

-- Main query 
SELECT 
YEAR(TransactionDate) AS Year, MONTH(TransactionDate) AS Month,TransactionType,ROUND(ISNULL(SUM(Amount),0),2) AS TotalTransactionVolume
FROM FB.Transactions
WHERE TransactionDate >= '2011-01-01' AND TransactionDate < '2024-01-01'
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate),TransactionType;




--Yearly Trend Analysis
SELECT 
    YEAR(TransactionDate) AS Year,
    ROUND(SUM(Amount),2) AS TotalTransactionVolume
FROM FB.Transactions
WHERE TransactionDate >= '2011-01-01' AND TransactionDate < '2024-01-01'
GROUP BY YEAR(TransactionDate)
ORDER BY Year;

