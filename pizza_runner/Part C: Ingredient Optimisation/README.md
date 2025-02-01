# Part C: Ingredient Optimisation

## Questions and Solutions

**1. What are the standard ingredients for each pizza?**

```sql
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

split_topping AS (
	SELECT 
		pr.pizza_id,
		pn.pizza_name,
		CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pr.toppings, ',', n), ',', -1)) AS UNSIGNED) AS topping_id
	FROM
		pizza_recipes AS pr
	CROSS JOIN idx AS n
	JOIN pizza_names AS pn
		ON pr.pizza_id = pn.pizza_id
	WHERE 
		n <= (LENGTH(pr.toppings) - LENGTH(REPLACE(pr.toppings, ',', '')) + 1)
	ORDER BY
		pr.pizza_id,
		topping_id
)

SELECT
	tpi.*,
	pt.topping_name
FROM
	split_topping AS tpi
JOIN pizza_toppings AS pt
	ON tpi.topping_id = pt.topping_id
ORDER BY
	tpi.pizza_id,
	tpi.topping_id;
```

**Answer:**

|pizza_id|pizza_name|topping_id|topping_name|
|--------|----------|----------|------------|
|1       |Meatlovers|1         |Bacon       |
|1       |Meatlovers|2         |BBQ Sauce   |
|1       |Meatlovers|3         |Beef        |
|1       |Meatlovers|4         |Cheese      |
|1       |Meatlovers|5         |Chicken     |
|1       |Meatlovers|6         |Mushrooms   |
|1       |Meatlovers|8         |Pepperoni   |
|1       |Meatlovers|10        |Salami      |
|2       |Vegetarian|4         |Cheese      |
|2       |Vegetarian|6         |Mushrooms   |
|2       |Vegetarian|7         |Onions      |
|2       |Vegetarian|9         |Peppers     |
|2       |Vegetarian|11        |Tomatoes    |
|2       |Vegetarian|12        |Tomato Sauce|

***

**2. What was the most commonly added extra?**

**[Click to read full script](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/pizza_runner/Part%20C%3A%20Ingredient%20Optimisation/scripts/q2.sql)**

**A. Calculate the highest number of ```extras``` (extra topping) to be added to a pizza.**

```sql
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
```

This creates a table column of indices for each extra added:

|n|
|-|
|1|
|2|

- The maximmum ```extras``` is 2. This table also allows us to index and extract data properly later on.

**B. Split the ```extras``` into individual columns**

```sql
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
```

This will result in:

|extra_id|
|--------|
|1       |
|1       |
|5       |
|1       |
|4       |
|1       |

- The extras, represented by their ids, are split into different columns.

**C. Calculate the times each topping, represented by their id, is added.**

```sql
extras_count AS (
	SELECT
		*,
		COUNT(*) AS times_added
	FROM
		split_extras
	GROUP BY
		extras_id
)
```

Finally,

```sql
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
```

- Select the row where the count for extra toppings is maximum.

**Answer:**

|topping_id|topping_name|times_added|
|----------|------------|-----------|
|1         |Bacon       |4          |

- Bacon is the most common extra (additional topping).

***

**3. What was the most common exclusion?**

**[Click to read full script](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/pizza_runner/Part%20C%3A%20Ingredient%20Optimisation/scripts/q3.sql)**

- The steps are very similiar to question 2. Just replace ```extras``` with ```exclusions```.

**Answer:**
|topping_id|topping_name|times_added|
|----------|------------|-----------|
|4         |Cheese      |4          |


***

**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

**[Click to read full script](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/pizza_runner/Part%20C%3A%20Ingredient%20Optimisation/scripts/q6.sql)**

**Answer:**

|topping_name|quantity|
|------------|--------|
|Bacon       |12      |
|Mushrooms   |11      |
|Cheese      |10      |
|Beef        |9       |
|Chicken     |9       |
|Pepperoni   |9       |
|Salami      |9       |
|BBQ Sauce   |8       |
|Onions      |3       |
|Peppers     |3       |
|Tomatoes    |3       |
|Tomato Sauce|3       |
