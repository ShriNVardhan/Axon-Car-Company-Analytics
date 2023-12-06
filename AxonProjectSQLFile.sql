USE classicmodels;

SELECT * from customers;
desc customers;
SELECT * from employees;
desc employees;
SELECT * from offices;
desc offices;
SELECT * from orderdetails;
desc orderdetails;
SELECT * from orders;
desc orders;
SELECT * from payments;
desc payments;
SELECT * from productlines; 
desc productlines;
SELECT * from products;
desc products;

SELECT * FROM orders
order by status;

#Removing the duplicates first and foremost

SELECT * FROM customers;

SELECT orderNumber, COUNT(orderNumber) AS count
FROM orderdetails
GROUP BY orderNumber
HAVING COUNT(orderNumber) > 1;

SELECT orderNumber, COUNT(orderNumber) AS count
FROM orders
GROUP BY orderNumber
HAVING COUNT(orderNumber) > 1;

SELECT checkNumber, count(checkNumber) as count
from payments
GROUP BY checkNumber
HAVING count(checkNumber) >1;


/* ORder Analysis: Order Status Year Wise list*/

SELECT YEAR(orderDate) AS Year,
    COUNT(CASE WHEN status = 'Shipped' THEN 1 END) AS ShippedOrderCount,
    COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) AS CancelledOrderCount,
    COUNT(CASE WHEN status = 'Disputed'THEN 1 END) AS DisputedOrderCount,
	COUNT(CASE WHEN status = 'In Process'THEN 1 END) AS InProcessOrderCount,
	COUNT(CASE WHEN status = 'OnHold'THEN 1 END) AS HoldOrderCount,
	COUNT(CASE WHEN status = 'Resolved'THEN 1 END) AS ResolvedOrderCount
FROM orders
WHERE status IN ('Shipped', 'Cancelled','Disputed', 'In Process', 'On Hold', 'Resolved')
GROUP BY Year;

/*Sales Analysis: Total Sales + Trends over time*/

SELECT * from orders, orderDetails;

SELECT YEAR(orderDate) AS Year,
	MONTHNAME(orderDate) AS Month, 
    SUM(quantityOrdered * priceEach) AS MonthlySales
FROM orders AS o
JOIN orderdetails AS od
USING (orderNumber)
GROUP BY (orderDate); 

/*Sales Analysis: Best Selling Products:*/

Select * FROM products;
Select * FROM productlines;
SELECT * FROM orders;
SELECT * FROM orderdetails;


SELECT productCode, 
	productName, 
    productLine, 
    quantityInStock,
    SUM(od.quantityOrdered) AS 'TotalQuantityOrdered'
FROM products AS p
JOIN orderdetails AS od
USING (productCode)
JOIN orders AS o
USING (orderNumber)
GROUP BY p.productCode
ORDER BY TotalQuantityOrdered desc;

/*Customer Analysis: Top Customers*/

SELECT * FROM customers, orders, orderdetails;

SELECT c.customerName,
	c.customerNumber,
    SUM(quantityOrdered) AS "QuantityOrdered",
    SUM(priceEach * quantityOrdered) AS "TotalSales"
FROM customers AS c
JOIN orders AS o
USING (customerNumber)
JOIN orderDetails AS od
USING (orderNumber)
GROUP BY c.customerName, c.customerNumber
ORDER BY TotalSales desc;


SELECT 
	od.productCode,
    c.customerNumber,
    c.customerName,
    c.country, 
    od.quantityOrdered,
    od.priceEach,
    SUM(quantityOrdered*priceEach) as Sales
FROM orders AS o
JOIN customers AS c 
USING (customerNumber)
JOIN orderdetails AS od 
USING (orderNumber)
GROUP BY c.customerNumber, c.country, od.productCode, od.quantityOrdered, od.priceEach;


/*Customer AnalysisL: Segment customers based on demographics*/

SELECT c.customerNumber,
	od.orderNumber,
    od.productCode,
    p.productLine,
    c.contactFirstName, 
    c.contactlastName,
    c.city,
    c.country
FROM customers AS c
JOIN orders as o
USING (customerNumber)
JOIN orderdetails as od
USING (orderNumber)
JOIN products as p
USING (productCode);

/*Customers Analysis: High Value, At Risk customers*/ 

SELECT * from customers;
select * FROM orders;

SELECT YEAR(orderDate) AS Year,
	MONTHNAME(orderDate) AS Month,
    COUNT(DISTINCT customerNumber) AS DistinctCustomers
FROM orders AS o
GROUP BY Year, Month;


/*Product Analysis*/

SELECT * FROM products;
SELECT * FROM orders, orderdetails;

SELECT
	p.productLine,
    sum(od.quantityOrdered) as 'TotalQuantity',
    sum(priceEach*quantityOrdered) as 'TotalSales'
FROM products as p
JOIN orderdetails as od
USING (productCode)
JOIN orders as o
USING (orderNumber)
GROUP BY
    p.productLine;


/*Product Analysis*: Best Selling Product Line*/

SELECT 
	p.productCode, 
	p.productLine,
    p.productName,
	SUM(quantityOrdered) AS "Total Quantity Ordered",
    od.priceEach
FROM products AS p
JOIN orderdetails AS od
ON p.productCode = od.productCode
GROUP BY p.productLine, p.productCode, p.productName, od.priceEach;

/*Product Analysis*: Product Revenue Analysis*/

SELECT * FROM orders, products, productlines;

SELECT p.productCode, 
	p.productName, 
    p.productLine, 
    SUM(od.quantityOrdered * priceEach) AS 'TotalRevenue'
FROM products AS p
JOIN orderdetails AS od
USING (productCode)
JOIN orders AS o
USING (orderNumber)
GROUP BY p.productCode
ORDER BY TotalRevenue desc;

/*Order Analysis: Order Fulfillment Analysis*/

SELECT * FROM orders;

SELECT orderNumber,
	orderDate,
    requiredDate,
    shippedDate,    
CASE 
	WHEN DATEDIFF(shippedDate, orderDate) > 0 THEN CONCAT('Delivered ', DATEDIFF(shippedDate, orderDate), ' days earlier')
    WHEN DATEDIFF(shippedDate, orderDate) = 0 THEN "ON TIME"
    ELSE CONCAT('Delivered ', DATEDIFF(shippedDate, orderDate), ' days later')
END AS DeliveryStatus
FROM orders
WHERE status = "Shipped" & "Resolved";


/*Order Analysis*: Payment Analysis*/

SELECT * FROM payments, customers;
SELECT * FROM orderDetails;

SELECT p.customerNumber,
	c.customerName,
    c.contactFirstName,
    c.contactLastName,
    p.checkNumber,
    SUM(p.amount) AS TotalPaymentAmount
FROM payments AS p
JOIN customers AS c
USING (customerNumber)
GROUP BY customerNumber, p.checkNumber     
HAVING TotalPaymentAmount > 0;

/*Order Analysis: Credit Utilization Analysis*/

SELECT * FROM customers, payments; 
SELECT * FROM orders;
SELECT * FROM orderdetails;
SELECT * FROM payments;

SELECT
    c.customerNumber,
    c.customerName,
    c.creditLimit,
    SUM(p.amount) AS TotalOrderAmount,
    (SUM(p.amount) / c.creditLimit) AS CreditUtilization
FROM Customers AS c
LEFT JOIN payments AS p 
ON c.customerNumber = p.customerNumber
JOIN orders as o 
GROUP BY c.customerNumber, c.customerName, c.creditLimit;

/*Employee and Office Analysis: Employee Hierarchy*/

SELECT e1.employeeNumber AS ManagerEmployeeNumber ,
	e1.firstName AS ManagerFirstName,
    e1.lastName AS ManagerLastName,
    e1.jobTitle,
    e2.employeeNumber AS SubordinateNumber,
    e2.firstName AS SubordinateFirstName,
    e2.lastName AS SubordinateLastName,
    e2.jobTitle
FROM employees e1
LEFT JOIN Employees e2 
ON e1.employeeNumber = e2.reportsTo;


/*Employee and Office Analysis: Top Performing Employees*/

SELECT * from offices; 
SELECT * FROM employees; 
SELECT * FROM orders;
SELECT * FROM orderdetails;
SELECT * FROM customers, orders;

SELECT
    e.employeeNumber,
    e.lastName,
    e.firstName,
    e.jobTitle,
    SUM(priceEach * quantityOrdered) AS TotalSales
FROM employees as e
JOIN customers as c 
ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders AS o 
USING (customerNumber)
JOIN orderDetails AS od
USING (orderNumber)
GROUP BY employeeNumber, lastName, firstName, jobTitle
ORDER BY TotalSales DESC;

/*Employee and Office Analysis: Offices Sales*/

SELECT * FROM orders;
SELECT * FROM offices;

SELECT o.officeCode, 
	o.city, 
    o.country, 
    SUM(od.quantityOrdered * od.priceEach) AS TotalSales
FROM offices AS o
JOIN employees AS e 
USING (officeCode)
JOIN customers AS c 
ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders AS odr 
USING (customerNumber) 
JOIN OrderDetails od 
USING (orderNumber)
GROUP BY o.officeCode, o.city, o.country
ORDER BY TotalSales DESC;


    
	










