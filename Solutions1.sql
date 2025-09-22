-- Monday Coffee -- Data Analysis 

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports & Data Analysis

-- Q1. How many sales for each product
-- For each product, how many times was it sold?

SELECT p.product_name, COUNT(s.sale_id) AS total_sales
FROM products p
LEFT JOIN sales s ON s.product_id = p.product_id
GROUP BY p.product_name;


-- Q2. Cities with the most customers
-- Which city has the most customers?

SELECT ci.city_name, COUNT(c.customer_id) AS customer_count
FROM customers c
JOIN city ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY customer_count DESC
LIMIT 1;


-- Q3. Highest Revenue Product
-- Which coffee product generated the most revenue?

SELECT 
    p.product_name,
    SUM(s.total) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 1;


-- product ordered the most times by orders
SELECT 
    p.product_name,
    COUNT(s.sale_id) AS order_count
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY order_count DESC
LIMIT 1;


-- Q4. Total Sales per Year
-- What is the total sales revenue for each year?

SELECT 
    YEAR(sale_date) AS year,
    SUM(total) AS total_revenue
FROM sales
GROUP BY year
ORDER BY year;


-- Q5. Peak Sales Months
-- Which months had the highest total sales?
SELECT 
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    SUM(total) AS total_sales
FROM sales
GROUP BY year, month
ORDER BY total_sales DESC
LIMIT 3;


-- Q6. Top 5 Customers by Spending
-- Who are the top 5 customers by total money spent?

SELECT 
    c.customer_id,
    c.customer_name,
    SUM(s.total) AS total_spent
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;


-- Q7. City with Highest Revenue per Customer
-- Which city has the highest average sales per customer?
SELECT 
    ci.city_name,
    SUM(s.total) / COUNT(DISTINCT c.customer_id) AS avg_sales_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY avg_sales_per_customer DESC
LIMIT 1;


-- Q8. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
    city_name,
    ROUND((population * 0.25)/1000000, 2) AS coffee_consumers_in_millions,
    city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC;


-- -- Q9. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
 
 -- Total Revenue of ALL Cities
    SELECT 
    SUM(total) AS total_revenue
FROM sales
WHERE 
    YEAR(sale_date) = 2023 AND QUARTER(sale_date) = 4;

-- Revenue by City
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c 
	ON s.customer_id = c.customer_id
JOIN city AS ci 
	ON ci.city_id = c.city_id
WHERE 
    YEAR(s.sale_date) = 2023 AND QUARTER(s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;


-- Q10. Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
    p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s 
	ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC;


-- Q11. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND(SUM(s.total)/COUNT(DISTINCT s.customer_id), 2) AS avg_sale_per_customer
FROM sales s
JOIN customers c 
	ON s.customer_id = c.customer_id
JOIN city ci 
	ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;


-- Q12. City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

SELECT 
    ci.city_name,
    ROUND((MAX(ci.population) * 0.25)/1000000, 2) AS estimated_coffee_consumers_million,
    COUNT(DISTINCT c.customer_id) AS unique_customers
FROM city ci
LEFT JOIN customers c ON ci.city_id = c.city_id
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY ci.city_id, ci.city_name;


--  Q13. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders,
        DENSE_RANK() OVER (PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rnk
    FROM sales AS s
    JOIN products AS p ON s.product_id = p.product_id
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, p.product_name
) AS t1
WHERE rnk <= 3;


-- Q14. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_customers
FROM city ci
JOIN customers c 
	ON ci.city_id = c.city_id
JOIN sales s 
	ON s.customer_id = c.customer_id
WHERE s.product_id BETWEEN 1 AND 14
GROUP BY ci.city_name;


-- Q15. Total Sales per Month
-- by each city

SELECT 
    ci.city_name,
    YEAR(s.sale_date) AS year,
    MONTH(s.sale_date) AS month,
    SUM(s.total) AS total_sales
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY ci.city_name, year, month
ORDER BY ci.city_name, year, month;



/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.



