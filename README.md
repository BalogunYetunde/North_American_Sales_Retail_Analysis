# North_American_Sales_Retail_Analysis

## Project Overview
North American Retail is a major retail company operating in multiple cities in United States. The company offers a wide ranges of products 
which includes Bookcases, Tables, Chairs and Furnishing. They focus on excellent customer service and a smooth shopping experience.
As a data Analyst, my job is to analyse their sales data to determine key insights on the business performance, profitablity, 
products performance, effective ship mode, customer behaviour and more.
I worked with dataset that contain details on products, customers, sales, profits, orders, ship mode. The insights generated unable me to
identify the business performance, areas of improvement and suggested strategies to improve company's sales performance, profitablity.

## Data Source
The dataset used was Retail-Supply-Chain-Sales-Analysis.csv and Calendar Date.csv

## Tools used
- SQL

## Data Cleaning and Preparation
1. Data Importation and Inspection
2. Data Spliting into Dimension and Fact tables
3. Create an ERD
4. Remove Duplicate from Dimension tables

## Analysis Goals
1. What was the average delivery day for different product category?
2. What was the average delivery date for each segment?
3. What are the top 5 fastest delivered product and Top 5 slowest delivered product?
4. Which Product Sub-Category generate the most profit?
5. Which Segment generate the most profit?
6. Which Top 5 customers made the most profit?
7. What is the total Number of Products by Subcategory?

## Data Analysis
### 1. What was the average delivery days for different product category?
```sql
SELECT * FROM Fact_table
SELECT * FROM DimProducts

SELECT SUb_Category,AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS Average_Delivery_Days
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
GROUP BY SUb_Category
```
*It takes an average of 32 days for Chairs and Bookcases sub-category,
34 days for Furnishings sub category
and 36 days for tables sub-category to be delivered.*
### 2. What was the average delivery date for each segment?
```sql
SELECT * FROM DimCustomers
SELECT * FROM Fact_table

SELECT Segment,AVG(DateDiff(Day,Order_Date,Ship_Date)) AS AverageDeliveryDate
FROM Fact_table
RIGHT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
GROUP BY Segment
ORDER BY AverageDeliveryDate DESC
```
*It takes an average of 35  days to deliver to corporate customer's segment, 
34 delivery days to consumer segment &
31 delivery days to Home Office Segment*

### 3. What are the top 5 fastest delivered product and Top 5 slowest delivered product?
```sql
SELECT TOP 5(Product_Name),DATEDIFF(Day,Order_Date,Ship_Date) AS DeliveryDays
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
ORDER BY DeliveryDays ASC;
```
*Top 5 Fastest Delivered Product which takes 0 days are
-Sauder Camden County Barrister Bookcase, Planked Cherry Finish
-Sauder Inglewood Library Bookcases
-O'Sullivan 2-Shelf Heavy-Duty Bookcases
-O'Sullivan Plantations 2-Door Library in Landvery Oak
-O'Sullivan Plantations 2-Door Library in Landvery Oak*
```sql
SELECT TOP 5(Product_Name),DATEDIFF(Day,Order_Date,Ship_Date) AS DeliveryDays
FROM Fact_table
LEFT JOIN DimProducts
ON
Fact_table.ProductKey=DimProducts.ProductKey
ORDER BY DeliveryDays DESC;
```
*Top 5 Slowest delivered Days which take 214 days are
-Bush Mission Pointe Library
-Hon Multipurpose Stacking Arm Chairs
-Global Ergonomic Managers Chair
-Tensor Brushed Steel Torchiere Floor Lamp
-Howard Miller 11-1/2" Diameter Brentwood Wall Clock*
### 4. Which Product Sub-Category generate the most profit?
```sql
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
```
*Chairs generates the most profit of 36471.1*
### 5. Which Segment generate the most profit?
```sql
SELECT Segment,Round(Sum(Profit),2) AS Total_Profit
FROM Fact_table
LEFT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
WHERE Profit >0
GROUP BY Segment
ORDER BY 2 DESC
```
*The Consumer segment generates the most profit of 35427.03 While the Home Office generate the least of 13657.04 *
### 6. Which Top 5 customers made the most profit?
```sql
SELECT TOP 5(Customer_Name),Round(Sum(Profit),2) AS Total_Profit
FROM Fact_table
LEFT JOIN DimCustomers
ON
Fact_table.Customer_ID=DimCustomers.Customer_ID
WHERE Profit >0
GROUP BY Customer_Name
ORDER BY 2 DESC
```
*The customers that generated highest profit
-Laura Armstrong
-Joe Elijah
-Seth Vernon
-Quincy Jones
-Maria Etezadi*
### 7. What is the total Number of Products by Subcategory?
```sql
SELECT SUb_Category,Count(SUb_Category) AS Total_Product
FROM DimProducts
GROUP BY SUb_Category
--OR
SELECT SUb_Category,Count(Product_Name) AS Total_Product
FROM DimProducts
GROUP BY SUb_Category
```
*Total Products for each sub-category are 48,87,186,34 for Bookcases, Chairs, Furnishings and Tables respectively.*

## Findings
- Product
North American Retail has three product subcategory which are Bookcases, Chairs, Tables and Furnishing but chairs generates the most profit 
while Table generate the least profit for the company.
- Customer
The company's customer are segemented into three parts. We have the Consumer, Home office and Corporate segment.
Consumer's customer tends to generate the most profit of 35427.03 While the Home Office generate the least of 13657.04.
- Location
The company focused on only one country which is United State but spread across the whole states, regions and city in the United state.
California generates the most profit and Virginia state generate the least profit.

## Recommendations
- Improve Shipping efficiency
Considering the average delivery days in the findings which is very high. North American Retail should push more so orders can get to customer as soon as possible.
Also consider partnering with shipping company to improve the distribution channels. For products that requires same day delivery or customer wants same day delivery
The compnay should ensure shipping modes promise matches the actual delivery time and advise customer on the appropriate ship mode when neccessary.
- To improve Sales in States with low Profit
North American Retail should invest more on advertising and other promotional strategies like Buy 2 get one free, free complimentary gift inorder to attract more customers 
in the low sales city and state like Virginia, Michigan and Washington.
For Product with low profit, advertising and other promotional straegies would be recommend.
Community engagement would also attract company's brands to customer in the regions and offering easy shopping experience like quick home delivery.
- Explore International Market Expansion
The company currently serves only United State which limit the growth potential. The company should make market research and identify like 2 or 3 countries
then tap into the market. The market expansion would be a great opportunities for the company to tap into international demands which would improve the profit margins.

