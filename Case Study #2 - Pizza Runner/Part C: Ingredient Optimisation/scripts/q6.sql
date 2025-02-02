WITH RECURSIVE idx AS (
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1
	FROM idx
	WHERE n < (
		SELECT
			MAX(LENGTH(toppings) - LENGTH(REPLACE(toppings, ',', '')) + 1)
		FROM
			pizza_recipes
	)
),

-- get all delivered pizzas
delivered_pizzas AS (
	SELECT
		co.order_id,
		co.pizza_id,
		co.exclusions,
		co.extras
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
	WHERE
		ro.distance > 0 AND ro.distance IS NOT NULL
		AND ro.duration > 0  AND ro.duration IS NOT NULL
		AND ro.cancellation IS NULL
),

-- split all base ingredients for each pizza into individual rows
split_topping AS (
	SELECT
		dp.order_id,
		pr.pizza_id,
		CAST(
			TRIM(
				SUBSTRING_INDEX(
					SUBSTRING_INDEX(pr.toppings, ',', n),
				',', -1)) 
			AS UNSIGNED) AS topping_id
	FROM
		pizza_recipes AS pr
	CROSS JOIN idx AS n
	JOIN pizza_names AS pn
		ON pr.pizza_id = pn.pizza_id
	JOIN delivered_pizzas AS dp
		ON pr.pizza_id = dp.pizza_id
	WHERE 
		n <= (LENGTH(pr.toppings) - LENGTH(REPLACE(pr.toppings, ',', '')) + 1)
	ORDER BY
		pr.pizza_id,
		topping_id
),

-- split all extras into individual rows
split_extras AS (
	SELECT
		order_id,
		pizza_id,
		CAST(
			TRIM(
				SUBSTRING_INDEX(
					SUBSTRING_INDEX(extras, ',', n),
				',', -1))
		AS UNSIGNED) AS topping_id
	FROM
		delivered_pizzas
	CROSS JOIN idx AS n
	WHERE 
		extras IS NOT NULL
		AND n <= LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
),

-- split all exclusions into individual rows
split_exclusions AS (
	SELECT
		order_id,
		pizza_id,
		CAST(
			TRIM(
				SUBSTRING_INDEX(
					SUBSTRING_INDEX(exclusions, ',', n), 
				',', -1))
		AS UNSIGNED) AS topping_id
	FROM
		delivered_pizzas
	CROSS JOIN idx AS n
	WHERE 
		exclusions IS NOT NULL
		AND n <= LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) + 1
),

-- combine all ingredients
all_ingredients AS (
	-- base ingredients
	SELECT
		*,
		1 AS qty
	FROM
		split_topping

	UNION ALL

	-- extras
	SELECT
		*,
		1 AS qty
	FROM
		split_extras

	UNION ALL

	-- exclusions
	SELECT
		*,
		-1 AS qty
	FROM
		split_exclusions
)

SELECT
	pt.topping_name,
	SUM(ai.qty) AS quantity
FROM
	all_ingredients AS ai
JOIN pizza_toppings AS pt
	ON ai.topping_id = pt.topping_id
GROUP BY
	pt.topping_name
ORDER BY
	quantity DESC;