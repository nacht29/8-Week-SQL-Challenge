WITH RECURSIVE idx AS (
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1 
	FROM idx
	WHERE n < (
		SELECT 
			MAX(LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1)
		FROM std_customer_order
		WHERE
			extras IS NOT NULL 
	)
),

split_extras AS (
	SELECT 
		TRIM(
			SUBSTRING_INDEX(
				SUBSTRING_INDEX(extras, ',', n), 
				',', 
				-1
			)
		) AS extras_id
	FROM std_customer_order
	CROSS JOIN idx n
	WHERE 
		extras IS NOT NULL
		AND n <= LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
),

extras_count AS (
	SELECT
		*,
		COUNT(*) AS times_added
	FROM
		split_extras
	GROUP BY
		extras_id
)

SELECT
	pt.topping_id,
	pt.topping_name,
	extras_count.times_added
FROM
	pizza_toppings AS pt
JOIN extras_count
	ON extras_id = pt.topping_id
WHERE
	extras_count.times_added = (SELECT MAX(times_added) FROM extras_count);