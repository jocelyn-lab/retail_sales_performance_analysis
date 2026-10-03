-- Retail Sales Performance Analysis
-- Project 1
-- Tools: SQL Server, Power BI, Python

-- 1. Product Performance
-- Business Question:
-- Which products contribute most to total revenue?
with ProductSales as
(
select Products.ProductID, Products.ProductName, sum(Orders.Quantity) as TotalQuantity,
sum(Orders.Quantity * Products.Price) as TotalSales
from Products inner join Orders on Products.ProductID = Orders.ProductID
group by Products.ProductID, Products.ProductName
),
Revenue as
(
select ProductName, TotalQuantity, TotalSales,
TotalSales * 100.0 / sum(TotalSales) over() as RevenueShare
from ProductSales
)
select ProductName, TotalQuantity, TotalSales, RevenueShare,
rank() over (
order by RevenueShare desc
) as RevenueRank
from Revenue;

-- 2. Customer Performance
-- Business Question:
-- Which customers have the highest total spending? 
with CustomerPerformance as
(
select CustomerID, count(Orders.OrderID) as TotalOrders, sum(Orders.Quantity) as TotalQuantity,
sum(Orders.Quantity * Products.Price) as TotalSales
from Orders inner join Products on Orders.ProductID = Products.ProductID
group by CustomerID
)
select Customers.CustomerName, CustomerPerformance.TotalOrders, CustomerPerformance.TotalQuantity, 
CustomerPerformance.TotalSales,
rank() over (
order by CustomerPerformance.TotalSales desc
) as CustomerRank
from Customers inner join CustomerPerformance on Customers.CustomerID = CustomerPerformance.CustomerID;

-- 3. Customer Revenue Contribution
-- Business Question:
-- What percentage of total revenue does each customer contribute?
with CustomerShare as 
(
select CustomerID, sum(Orders.Quantity * Products.Price) as TotalSales
from Orders inner join Products on Orders.ProductID = Products.ProductID
group by CustomerID
)
select Customers.CustomerName, CustomerShare.TotalSales,
CustomerShare.TotalSales * 100.0 / sum(CustomerShare.TotalSales) over() as RevenueShare
from Customers inner join CustomerShare on Customers.CustomerID = CustomerShare.CustomerID;

-- 4. City Performance
-- Business Question:
-- Which cities generate the highest sales revenue?
with CitySales as
(
select Customers.City, sum(Orders.Quantity) as TotalQuantity, sum(Orders.Quantity * Products.Price) as TotalSales
from Products inner join Orders on Products.ProductID = Orders.ProductID
inner join Customers on Orders.CustomerID = Customers.CustomerID
group by Customers.City
)
select City, TotalQuantity, TotalSales,
rank () over (
order by TotalSales desc
) as CityRank
from CitySales;

-- 5. Unengaged Customers
-- Business Question:
-- Are there customers who have not placed an order?
select Customers.CustomerName, Customers.City
from Customers left join Orders on Customers.CustomerID = Orders.CustomerID
where Orders.ORDERID is null;

