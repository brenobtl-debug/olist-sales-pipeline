CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;

CREATE TABLE IF NOT EXISTS customers (
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS orders (
	order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE IF NOT EXISTS order_items (
	order_id VARCHAR(50),
    order_item_id int,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id)
    );
    
    SHOW TABLES;
    
    USE olist_db;
    TRUNCATE TABLE customers;
    
    SET GLOBAL local_infile = 1;
    
    USE olist_db;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
	INTO TABLE customers
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);
    
	TRUNCATE TABLE orders;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
	INTO TABLE orders
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(order_id, customer_id, order_status, 
	@v_order_purchase_timestamp, 
	@v_order_approved_at, 
	@v_order_delivered_carrier_date, 
	@v_order_delivered_customer_date, 
	@v_order_estimated_delivery_date)
	SET 
	order_purchase_timestamp = NULLIF(@v_order_purchase_timestamp, ''),
	order_approved_at = NULLIF(@v_order_approved_at, ''),
	order_delivered_carrier_date = NULLIF(@v_order_delivered_carrier_date, ''),
	order_delivered_customer_date = NULLIF(@v_order_delivered_customer_date, ''),
	order_estimated_delivery_date = NULLIF(@v_order_estimated_delivery_date, '');
    
    TRUNCATE TABLE order_items;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
	INTO TABLE order_items
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);
    

	SELECT COUNT(*) FROM customers;
	SELECT COUNT(*) FROM orders;
	SELECT COUNT(*) FROM order_items;
    
    SELECT DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m') AS order_period, ROUND(SUM(order_items.price), 2) AS product_revenue, ROUND(SUM(order_items.freight_value), 2) AS total_freight, ROUND(SUM(order_items.price + order_items.freight_value), 2) AS total_revenue
	FROM orders
	JOIN order_items 
		ON orders.order_id = order_items.order_id
	WHERE orders.order_status = 'delivered'
	GROUP BY DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m')
	ORDER BY order_period ASC;
    
    SELECT
		DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m') AS order_period,
        COUNT(DISTINCT orders.order_id) AS total_orders,
        ROUND(SUM(order_items.price + order_items.freight_value), 2) AS total_revenue,
        ROUND(SUM(order_items.price + order_items.freight_value) / COUNT(DISTINCT orders.order_id), 2) AS average_ticket
	FROM orders
    JOIN order_items
		ON orders.order_id = order_items.order_id
	WHERE orders.order_status = 'delivered'
    GROUP BY DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m')
    ORDER BY order_period ASC;