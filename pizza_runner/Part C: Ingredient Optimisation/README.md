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
			MAX(LENGTH(toppings) - LENGTH(REPLACE(REPLACE(toppings, ' ', ''), ',', '')) + 1)
		FROM
			pizza_recipes
	)
),

topping_idexing AS (
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
	topping_idexing AS tpi
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

***

**3. What was the most common exclusion?**

***

**4. Generate an order item for each record in the customers_orders table in the format of one of the following:**

- **```Meat Lovers```**
- **```Meat Lovers - Exclude Beef```**
- **```Meat Lovers - Extra Bacon```**
- **```Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers```**

***

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients**

- **For example: ```"Meat Lovers: 2xBacon, Beef, ... , Salami"```**

***

**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
