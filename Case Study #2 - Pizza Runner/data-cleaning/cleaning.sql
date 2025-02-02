 -- clean customer_orders table
-- exclusions/extras are toppings to remove/add to pizzas
DROP TABLE IF EXISTS std_customer_order;
CREATE TABLE std_customer_order (
	order_id INT,
	customer_id INT,
	pizza_id INT,
	exclusions VARCHAR(50),
	extras VARCHAR(50),
	order_time DATETIME
) AS 
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions IS NULL OR exclusions LIKE 'null' OR exclusions = ''
			THEN NULL
		ELSE
			exclusions
		END AS exclusions,
	CASE
		WHEN extras IS NULL OR extras LIKE 'null' OR extras = ''
			THEN NULL
		ELSE
			extras
	END AS extras,
	order_time
FROM
	customer_orders;


-- clean runner_orders table
-- double TRIM to handle cases of % min and %min
--		e.g. 13 min$ -> 13 $ -> 13$
DROP TABLE IF EXISTS std_runner_order;
CREATE TABLE std_runner_order (
	order_id INT,
	runner_id INT,
	pickup_time DATETIME,
	distance DECIMAL(10,2),
	duration INT,
	cancellation VARCHAR(50)
) AS
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time IS NULL OR pickup_time LIKE 'null'  OR pickup_time LIKE ''
			THEN NULL
		ELSE
			CAST(pickup_time AS DATETIME)
		END AS pickup_time,
	CASE
		WHEN distance IS NULL OR distance LIKE 'null' OR distance LIKE ''
			THEN NULL
		WHEN distance LIKE '%km' OR distance LIKE '% km'
			THEN TRIM(TRIM('km' FROM distance))
		ELSE
			distance
		END AS distance,
	CASE
		WHEN duration IS NULL OR duration LIKE 'null' OR duration LIKE ''
			THEN NULL
		WHEN duration LIKE '%mins' OR duration LIKE '% mins'
			THEN TRIM(BOTH ' ' FROM TRIM('mins' FROM duration))
		WHEN duration LIKE '%minute' OR duration LIKE '% minute'
			THEN TRIM(BOTH ' ' FROM TRIM('minute' FROM duration))
		WHEN duration LIKE '%minutes' OR duration LIKE '% minutes'
			THEN TRIM(BOTH ' ' FROM TRIM('minutes' FROM duration))
		ELSE
			duration
	END AS duration,
	CASE
		WHEN cancellation IS NULL OR cancellation LIKE 'null' OR cancellation LIKE ''
			THEN NULL
		ELSE
			cancellation
	END AS cancellation
FROM
	runner_orders;

SELECT * FROM std_customer_order;
SELECT * FROM std_runner_order;