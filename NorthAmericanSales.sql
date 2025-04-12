SELECT * FROM Sales_Retail

SELECT * FROM DimCustomers

--To create a DIMcustomer table from the Sales_retail dataset.



SELECT * INTO DimCustomers
FROM
	(SELECT Customer_ID,Customer_Name,Segment FROM Sales_Retail)
AS DimCustomers

SELECT * FROM DimCustomers;

--TO remove duplicate from DImcustomer table--

WITH CTE_DimCustomers
AS
	(SELECT Customer_ID,Customer_Name,Segment,ROW_NUMBER ()OVER(PARTITION BY Customer_ID,Customer_Name,Segment ORDER BY Customer_ID ASC) AS Rownum
	FROM DimCustomers
	)
DELETE FROM CTE_DimCustomers
WHERE Rownum >1

---To create Dimlocation--

SELECT * INTO DimLocation
FROM
	(SELECT Postal_Code,Country,State,City,Region
	FROM Sales_Retail)
	AS DimLocation
--Delete Duplicate from Dimlocation--

WITH CTE_DimLocation
AS
	(SELECT Postal_Code,Country,State,City,Region, ROW_NUMBER () OVER (PARTITION BY Postal_Code,Country,State,City,Region ORDER BY Postal_Code ASC)
	AS Rownumber
	FROM DimLocation
	)

DELETE FROM CTE_DimLocation 
WHERE Rownumber >1

SELECT * FROM DimLocation

---Create Table for Products DImproducts--

SELECT *FROM Sales_Retail

SELECT * INTO DimProducts
FROM
	(SELECT Product_ID,Category,SUb_Category,Product_Name
	FROM Sales_Retail) AS DimProducts

--TO remove duplicate by assigning rownumber to the primarykey of the table

WITH CTE_DimProducts
AS
	(SELECT Product_ID,Category,SUb_Category,Product_Name, ROW_NUMBER () OVER (PARTITION BY Product_ID,Category,SUb_Category,Product_Name ORDER BY Product_ID ASC)
	AS Rownumbe
	FROM DimProducts
	)
DELETE FROM CTE_DimProducts
WHERE Rownumbe >1

SELECT * FROM Sales_Retail
--To create Fact tables--- Note that the query wont work without the ALAIS

SELECT * INTO Fact_table
FROM
	(SELECT Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Postal_Code,Retail_Sales_People,Product_ID,Returned,Sales,Quantity,Discount,Profit
	FROM Sales_Retail)
	AS Fact_table
SELECT * FROM Fact_table

--Remove duplicate from Order_ID using CTE

WITH CTE_Fact_table
	AS
	(SELECT *,ROW_NUMBER () OVER (PARTITION BY Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Postal_Code,Retail_Sales_People,Product_ID,Returned,Sales,Quantity,Discount,Profit
	ORDER BY Order_ID)
	AS Rownumber 
	FROM Fact_table
	)

	DELETE FROM CTE_Fact_table
	WHERE Rownumber>1

---To create a new column for DimProduct (Surrogate key) and use as the primary key because we noticed a two different are assigned to same product ID

Alter Table DimProducts
ADD ProductKey INT IDENTITY (1,1) Primary key

SELECT * FROM DimProducts
--Add the new columns to the Fact_table becuase its the new primary key in Dimproducts table

Alter Table Fact_table
ADD ProductKey INT

---Link the productkey in Dimproduct to Fact_table

UPDATE Fact_table
SET ProductKey=DimProducts.ProductKey
FROM Fact_table
JOIN DimProducts
ON
Fact_table.Product_ID=DimProducts.Product_ID

SELECT * FROM Fact_table
---Drop Product_ID in Dimproducts and Fact_table

ALTER TABLE DimProducts
DROP COLUMN Product_ID

ALTER TABLE Fact_table
DROP COLUMN Product_ID

--To alter because there is duplicate in the column.

Alter Table Fact_table
ADD Row_ID INT IDENTITY (1,1)

--Analysis--

--1. What was the average delivery day for different product category?
SELECT * FROM Fact_table
SELECT * FROM DimProducts

SELECT SUb_Category,AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS Average_Delivery_Days
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
GROUP BY SUb_Category

/*It takes an average of 32 days for Chairs and Bookcases sub-category,
34 days for Furnishings sub category
and 36 days for tables sub-category to be delivered.*/

--2. What was the average delivery date for each segment?
SELECT * FROM DimCustomers
SELECT * FROM Fact_table

SELECT Segment,AVG(DateDiff(Day,Order_Date,Ship_Date)) AS AverageDeliveryDate
FROM Fact_table
RIGHT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
GROUP BY Segment
ORDER BY AverageDeliveryDate DESC

/*It takes an average of 35  days to deliver to corporate customer's segment, 
34 delivery days to consumer segment &
31 delivery days to Home Office Segment */

--3. What are the top 5 fastest delivered product and Top 5 slowest delivered product?

SELECT TOP 5(Product_Name),DATEDIFF(Day,Order_Date,Ship_Date) AS DeliveryDays
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
ORDER BY DeliveryDays ASC;

/*Top 5 Fastest Delivered Product which takes 0 days are
Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak 
*/

SELECT TOP 5(Product_Name),DATEDIFF(Day,Order_Date,Ship_Date) AS DeliveryDays
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
ORDER BY DeliveryDays DESC;

/*Top 5 Slowest delivered Days which take 214 days are
Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock */

--4. Which Product Sub-Category generate the most profit?

SELECT Top 1(SUb_Category),ROUND(SUM(Profit),2) AS TotalProfit
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
WHERE Profit >0
GROUP BY SUb_Category
--OR
SELECT (SUb_Category),ROUND(SUM(Profit),2) AS TotalProfit
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
WHERE Profit >0
GROUP BY SUb_Category
ORDER BY TotalProfit DESC
--Chairs generates the most profit of 36471.1--

-- 5. Which Segment generate the most profit?
SELECT Segment,Round(Sum(Profit),2) AS Total_Profit
FROM Fact_table
LEFT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
WHERE Profit >0
GROUP BY Segment
ORDER BY 2 DESC

/*The Consumer segment generates the most profit of 35427.03 While the Home Office generate the least of 13657.04 */

--6. Which Top 5 customers made the most profit?--

SELECT TOP 5(Customer_Name),Round(Sum(Profit),2) AS Total_Profit
FROM Fact_table
LEFT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
WHERE Profit >0
GROUP BY Customer_Name
ORDER BY 2 DESC

/*The customers that generated highest profit
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi
*/


--7. What is the total Number of Products by Subcategory?

SELECT SUb_Category,Count(SUb_Category) AS Total_Product
FROM DimProducts
GROUP BY SUb_Category
--OR
SELECT SUb_Category,Count(Product_Name) AS Total_Product
FROM DimProducts
GROUP BY SUb_Category

--Total Products for each sub-category are 48,87,186,34 for Bookcases, Chairs, Furnishings and Tables respectively.--






