WITH RECURSIVE idx AS (
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1 
	FROM idx
	WHERE n < (
		SELECT 
			MAX(LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) + 1)
		FROM customer_orders
		WHERE
			exclusions IS NOT NULL 
	)
),

split_exclusions AS (
	SELECT 
		TRIM(
			SUBSTRING_INDEX(
				SUBSTRING_INDEX(exclusions, ',', n), 
				',', 
				-1
			)
		) AS extra_id
	FROM customer_orders
	CROSS JOIN idx n
	WHERE 
		exclusions IS NOT NULL 
		AND exclusions != 'null'
		AND exclusions != ''
		AND n <= LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) + 1
),

exclusions_count AS (
	SELECT
		*,
		COUNT(*) AS times_added
	FROM
		split_exclusions
	GROUP BY
		extra_id
)

SELECT
	pt.topping_id,
	pt.topping_name,
	exclusions_count.times_added
FROM
	pizza_toppings AS pt
JOIN exclusions_count
	ON extra_id = pt.topping_id
WHERE
	exclusions_count.times_added = (SELECT MAX(times_added) FROM exclusions_count);