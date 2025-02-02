# Part D: Pricing and Ratings

## Questions and solutions

**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

```sql
WITH delivered_pizzas AS (
	SELECT
		co.pizza_id,
		pn.pizza_name
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
	JOIN pizza_names AS pn
		ON pn.pizza_id = co.pizza_id
	WHERE
		ro.distance > 0 AND ro.distance IS NOT NULL
		AND ro.duration > 0  AND ro.duration IS NOT NULL
		AND ro.cancellation IS NULL
)

SELECT
	SUM(
		CASE
			WHEN pizza_name = 'Meatlovers'
				THEN 12
			WHEN pizza_name = 'Vegetarian'
				THEN 10
			ELSE
				0
			END
	) AS total_revenue
FROM
	delivered_pizzas;
```

- Create a CTE ```delivered_pizzas``` to store all records of delivered pizzas.
- Use ```SUM``` and ```CASE WHEN``` to calculate the total revenue from selling the Meatlovers and Vegetarian pizzas.

**Answer:**

|total_revenue|
|-------------|
|138          |

- The total revenue is $138.

***

**2. What if there was an additional $1 charge for any pizza extras?**

- **Add cheese is $1 extra**

There are 2 possiblw solutions:

**Solution A:**

```sql
WITH delivered_pizzas AS (
	SELECT
		co.order_id,
		co.pizza_id,
		pn.pizza_name,
		extras,
		exclusions,
		CASE
			WHEN extras IS NOT NULL
				THEN LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
			WHEN exclusions IS NOT NULL
				THEN (LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')) + 1) * -1
			ELSE 0
			END
		AS changes_made
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
	JOIN pizza_names AS pn
		ON pn.pizza_id = co.pizza_id
	WHERE
		ro.distance > 0 AND ro.distance IS NOT NULL
		AND ro.duration > 0  AND ro.duration IS NOT NULL
		AND ro.cancellation IS NULL
)

SELECT
	SUM(
		CASE
			WHEN pizza_name = 'Meatlovers'
				THEN 12 + changes_made * 1
			WHEN pizza_name = 'Vegetarian'
				THEN 10 + changes_made * 1
			ELSE
				0
			END
	) AS total_revenue
FROM
	delivered_pizzas;
```

- This solution adds $1 for every extra topping and subtracts $1 for every excluded topping.
- Create a CTE that stores the changes made to every delivered pizza.
- Each extra is counted as +$1 and exclusions as -$1.
- Use ```SUM``` and ```CASE WHEN``` to calculate from all orders the total revenue by adding up:
	- the base price for each pizza
	- the price increase/decrease for modifications.

**Answer:**

|total_revenue|
|-------------|
|139          |

- The total revenue is $139.

**Solution B:**

```sql
WITH delivered_pizzas AS (
	SELECT
		co.order_id,
		co.pizza_id,
		pn.pizza_name,
		extras,
		CASE
			WHEN extras IS NOT NULL
				THEN LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1
			ELSE 0
			END
		AS extra_added
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
	JOIN pizza_names AS pn
		ON pn.pizza_id = co.pizza_id
	WHERE
		ro.distance > 0 AND ro.distance IS NOT NULL
		AND ro.duration > 0  AND ro.duration IS NOT NULL
		AND ro.cancellation IS NULL
)

SELECT
	SUM(
		CASE
			WHEN pizza_name = 'Meatlovers'
				THEN 12 + extra_added * 1
			WHEN pizza_name = 'Vegetarian'
				THEN 10 + extra_added * 1
			ELSE
				0
			END
	) AS total_revenue
FROM
	delivered_pizzas;
```

- This solution only takes into account the extra charges from the additional toppings. No price change is applied to exclusions.
- The steps are rather similar, as we just exclude the part where we count exclusions as -$1.

**Answer:**

|total_revenue|
|-------------|
|142          |

- The total revenue is $142.

***

**3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**

***

**4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**

- **```customer_id```**
- **```order_id```**
- **```runner_id```**
- **```rating```**
- **```order_time```**
- **```pickup_time```**
- **Time between order and pickup**
- **Delivery duration**
- **Average speed**
- **Total number of pizzas**

***

**5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**

```sql
WITH delivered_pizzas AS (
	SELECT
		co.pizza_id,
		pn.pizza_name,
		ro.distance
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
	JOIN pizza_names AS pn
		ON pn.pizza_id = co.pizza_id
	WHERE
		ro.distance > 0 AND ro.distance IS NOT NULL
		AND ro.duration > 0  AND ro.duration IS NOT NULL
		AND ro.cancellation IS NULL
)

SELECT
	ROUND(
		SUM(
			CASE
				WHEN pizza_name = 'Meatlovers'
					THEN 12.
				WHEN pizza_name = 'Vegetarian'
					THEN 10
				ELSE
					0
				END
		) - (SUM(delivered_pizzas.distance) * 0.30), 2)
	AS profit
FROM
	delivered_pizzas;
```

- Recycle the solution from question 1 to first calculate the ```total_revenue``` without delivery fees.
- Update the main query: 
	```sql
	SUM(total_revenue) - SUM(delivered_pizzas.distance) * 0.30
	```
- The updated main query subtracts the delivery fee from the ```total_revenue``` to calculate the profit. (delivery fee = ```total distance travelled * $0.30```).
- Use ```ROUND``` to format the results to 2 decimal places.

**Answer:**

|profit|
|------|
|73.38 |

- The profit (after subtracting delivery fees) is $73.38.

***

Part D ends here. Click **[here to continue to Part E](https://github.com/nacht29/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Part%20C%3A%20Bonus%20Questions)**.