SELECT TOP 50 *
FROM Customers;

-- How many countries do customers live in? Exclude NULL.
SELECT COUNT(Country) AS 'Count', COUNT(DISTINCT Country) AS 'Count Distinct'
FROM Customers
WHERE Country IS NOT NULL;

-- What customers are based in Germany, and what is the contact name and phone number for each customer?
SELECT CompanyName, 
	   ContactName, 
	   Phone, 
	   Country
FROM Customers
WHERE Country='Germany';

-- In what countries are the most customers located?
SELECT COUNT(CustomerID) AS customers_by_country, Country
FROM Customers
GROUP BY Country
ORDER BY customers_by_country DESC;

-- What is the address and postal code for all customers in the USA outside of Portland?
SELECT Address,
	   PostalCode,
	   City, 
	   Country
FROM Customers
WHERE (NOT City='Portland') AND Country='USA';

-- Why do certain rows have a NULL value in Region?
SELECT City, Region, Country
FROM Customers
ORDER BY Country;
-- This query shows that only certain countries are split into regions.
-- Countries that are not split into regions have a NULL value with the exception of Cork, Ireland and the U.K.

-- Which contacts have a focus in sales?
SELECT CompanyName, ContactName, ContactTitle, Phone
FROM Customers
WHERE ContactTitle LIKE 'Sales%';


-- What customers have a supplier in the same country?
SELECT * FROM Customers
WHERE Country IN (SELECT Country FROM Suppliers);

SELECT *
FROM Suppliers;

SELECT Customers.Country, Customers.CompanyName	AS 'Customer Name', Customers.Phone, Suppliers.CompanyName AS 'Supplier'
FROM Customers
INNER JOIN Suppliers ON Suppliers.Country=Customers.Country;
