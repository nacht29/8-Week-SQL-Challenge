CREATE TEMPORARY TABLE IF NOT EXISTS tmp_customer_order AS 
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions IS NULL
		OR LOWER(exclusions) = 'null' 
		OR exclusions = ''
		THEN ' '
		ELSE exclusions
	END AS exclusions,
	CASE
		WHEN extras IS NULL
		OR LOWER(extras) = 'null'
		OR extras = ''
		THEN ' '
		ELSE extras
	END AS extras,
	CAST(order_time AS DATETIME) AS order_time
FROM
	customer_orders;

SELECT * FROM tmp_customer_order;
