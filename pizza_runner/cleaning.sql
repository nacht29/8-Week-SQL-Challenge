-- clean customer_orders table
-- exclusions/extras are toppings to remove/add to pizzas
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_customer_order AS
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions IS NULL OR exclusions LIKE 'null'
			THEN ' '
		ELSE
			exclusions
		END AS exclusions,
	CASE
		WHEN extras IS NULL OR extras LIKE 'null'
			THEN ' '
		ELSE
			extras
	END AS extras,
	order_time
FROM
	customer_orders;
-- SELECT * FROM tmp_customer_order;


-- cleam runner_orders table
-- replaces null str and NULL val as ' '
-- double TRIM to trim 'minutes' wtc, then trim the space
--		e.g. 13 minute$ -> 13 $ -> 13$
CREATE TEMPORARY TABLE tmp_runner_order AS
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time IS NULL OR pickup_time LIKE 'null' 
			THEN ' '
		ELSE
			pickup_time
		END AS pickup_time,
	CASE
		WHEN distance IS NULL OR distance LIKE 'null'
			THEN ' '
		WHEN distance LIKE '%km' OR distance LIKE '% km'
			THEN TRIM(TRIM('km' FROM distance))
		ELSE
			distance
		END AS distance,
	CASE
		WHEN duration IS NULL OR duration LIKE 'null'
			THEN ' '
		WHEN duration LIKE '%mins' OR duration LIKE '% mins'
			THEN TRIM(TRIM('mins' FROM duration))
		WHEN duration LIKE '%minute' OR duration LIKE '% minute'
			THEN TRIM(TRIM('minute' FROM duration))
		WHEN duration LIKE '%minutes' OR duration LIKE '% minutes'
			THEN TRIM(TRIM('minutes' FROM duration))
		ELSE
			duration
		END AS duration,
	CASE
		WHEN cancellation IS NULL OR cancellation LIKE 'null'
			THEN ' '
		ELSE
			cancellation
		END AS cancellation
FROM
	runner_orders;
-- SELECT * FROM tmp_runner_order;