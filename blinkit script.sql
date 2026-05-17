CREATE TABLE orders(
order_id VARCHAR(50),
customer_id VARCHAR (50),
order_date DATE,
promised_delivery_time TIMESTAMP,
actual_delivery_time TIMESTAMP,
delivery_status VARCHAR(50),
order_total NUMERIC(10,2),
payment_method VARCHAR(50),
delivery_partner_id VARCHAR(50),
store_id VARCHAR(50),
delivery_delay_mins NUMERIC(10,2),
order_month VARCHAR(20)
)



CREATE TABLE products (
product_id VARCHAR (50),
product_name VARCHAR(100),
category VARCHAR(50),
brand VARCHAR(50),
price NUMERIC(10,2),
mrp NUMERIC(10,2),
margin_percentage NUMERIC(10,2),
shelf_life_days INT,
min_stock_level INT,
max_stock_level INT,
discount_percentage NUMERIC(10,2)
)

CREATE TABLE order_item (
order_id VARCHAR(50),
product_id VARCHAR (50),
quantity INT,
unit_price NUMERIC(10,2),
total_item_value NUMERIC(10,2)
)


CREATE TABLE customers (
customer_id VARCHAR (50),
customer_name VARCHAR(100),
email VARCHAR(100),
phone VARCHAR(20),
address TEXT,
area VARCHAR(100),
pin_code VARCHAR(20),
registration_date DATE,
customer_segment VARCHAR(50),
total_orders INT,
average_order_value  NUMERIC(10,2),
customer_value_category VARCHAR(50)
)

CREATE TABLE inventory(
product_id VARCHAR(50),
date DATE,
stock_received INT,
damaged_stock INT,
damaged_stock_percentage NUMERIC(10,2)
)


SELECT * FROM orders
SELECT * FROM products
SELECT * FROM order_item
SELECT * FROM customers
SELECT * FROM inventory


SELECT MIN(order_date) AS first_order,
MAX(order_date)AS last_order
FROM orders
#Revenue by month
SELECT order_month,
COUNT(order_id) AS total_orders,
ROUND(SUM(order_total),2) AS total_revenue
FROM orders
GROUP BY order_month
ORDER BY MIN(order_date)


#Delivery Performace
SELECT delivery_status,
COUNT(order_id) AS total_orders,
ROUND(COUNT(order_id)*100/SUM(COUNT(order_id)) OVER(),2) AS Percentage
FROM orders
GROUP BY delivery_status
ORDER BY total_orders DESC


#TOP 10 products by revenue 
SELECT p.product_name,
p.category,
SUM(oi.total_item_value) AS total_revenue,
SUM(oi.quantity) AS total_units_sold
FROM order_item oi
JOIN products p 
ON oi.product_id= p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10

 #Revenue by category
 SELECT p.category,
 COUNT( DISTINCT oi.order_id) AS total_orders,
 SUM(oi.quantity) AS total_units_sold,
 ROUND(SUM(oi.total_item_value),2) AS total_revenue,
 ROUND(AVG(p.margin_percentage),2) AS avg_margin
 FROM order_item oi
 JOIN products p 
 ON oi.product_id = p.product_id
 GROUP BY p.category
 ORDER BY total_revenue DESC

#Payment method analysis
SELECT payment_method,
COUNT(order_id) AS total_orders,
ROUND(SUM(order_total),2) AS total_revenue,
ROUND(AVG(order_total),2)AS avg_order_value,
ROUND(COUNT(order_id)*100/SUM(COUNT(order_id)) OVER(),2) AS percentage
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC

#Customer Segment analysis
SELECT customer_segment,
COUNT(customer_id) AS total_customers,
ROUND(AVG(average_order_value),2) AS avg_order_value,
ROUND(AVG(total_orders),2) AS avg_order_per_customer,
ROUND(COUNT(customer_id)*100/ SUM(COUNT(customer_id)) OVER(),2) AS percentage
FROM customers
GROUP BY customer_segment
ORDER BY avg_order_value DESC

#Area wise customer analysis
SELECT area,
COUNT(customer_id) AS total_customers,
ROUND(AVG(average_order_value),2) AS avg_order_value,
ROUND(AVG(total_orders),2) AS avg_orders,
SUM( CASE WHEN customer_segment= 'Premium' 
THEN 1 ELSE 0 END) AS premium_customers
FROM customers
GROUP BY area
Order BY total_customers DESC

#INVENTORY DAMAGE ANALYSIS BY CATEGORY

SELECT p.category,
ROUND(AVG(i.damaged_stock_percentage),2) AS avg_damage_percentage,
SUM(i.damaged_stock) AS total_damaged_units,
SUM(i.stock_received) AS total_stock_received,
ROUND(SUM(i.damaged_stock)*100/SUM(i.stock_received),2) AS overall_damage_rate
FROM inventory i
JOIN products p 
ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY overall_damage_rate DESC

#Discount Analysis by Category
SELECT category,
ROUND(AVG(discount_percentage),2) AS avg_discount,
ROUND(AVG(margin_percentage),2) AS avg_margin,
ROUND(AVG(margin_percentage)- AVG(discount_percentage),2) AS net_margin,
COUNT(product_id) AS total_products
FROM products
GROUP BY  category
ORDER BY net_margin DESC

#top 10 customers
SELECT customer_name, area, customer_segment, total_orders,  average_order_value,
ROUND(total_orders* average_order_value,2) AS estimated_lifetime_value
FROM customers
ORDER BY estimated_lifetime_value DESC
LIMIT 10

#Delivery_partner_id 
SELECT delivery_partner_id,
COUNT(order_id) AS total_deliveries,
ROUND(AVG(delivery_delay_mins),2)AS avg_delay_mins,
SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
ROUND(SUM(CASE WHEN delivery_status = 'On Time'
THEN 1 ELSE 0 END )*100/ COUNT(order_id),2) AS on_time_percentage
FROM orders
GROUP BY delivery_partner_id
ORDER BY on_time_percentage DESC
LIMIT 10
#STORE PERFORMANCE
SELECT store_id,
COUNT(order_id) AS total_orders,
ROUND(SUM(order_total),2)AS total_revenue,
ROUND(AVG(order_total),2) AS avg_order_value,
SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries,
ROUND(SUM(CASE WHEN delivery_status = 'On Time'
THEN 1 ELSE 0 END )*100/ COUNT(order_id),2) AS on_time_percentage
FROM orders
GROUP BY store_id
ORDER BY total_revenue DESC

