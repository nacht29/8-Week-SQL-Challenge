# Part A: Pizza Metrics

## Questions and Solutions

**1. How many pizzas were ordered?**

```sql
SELECT
	COUNT(*) AS pizza_ordered
FROM std_customer_order;
```

- Use ```COUNT``` to calculate the number of entries, as each entry is meant for 1 pizza.

**Answer:**

|pizza_ordered|
|-------------|
|14           |

- There were 14 pizzas ordered.

***

**2. How many unique customer orders were made?**

```sql
SELECT
	COUNT(DISTINCT customer_id) AS unique_order
FROM
	std_customer_order;
```
- Use ```COUNT``` and ```DISTINCT``` to filter and count how many unique ```customer_id``` entries there are.
- Each distinct customer has a unique id -- ```customer_id```.

**Answer:**

|unique_order|
|------------|
|5           |

- There were 5 unique customer orders.

***

**3. How many successful orders were delivered by each runner?**

```sql
SELECT
	runner_id,
	COUNT(*) AS successful_delivery
FROM
	std_runner_order
WHERE
	(distance > 0 AND distance IS NOT NULL)
	AND (duration > 0 AND duration IS NOT NULL)
	AND (cancellation IS NULL)
GROUP BY
	runner_id;
```

- Use ```COUNT``` to count the number of entries of successful deliveries.
- Use the ```WHERE``` clause to define a successful delivery: where both the delivery ```distance``` and ```duration``` are not missing and are larger than 0. Also, ```cancellation``` needs to be NULL, which means the delivery did not get scheduled.
- Use ```GROUP BY``` to calculate the number of successful deliveries for each runner separately, differentiated by their unique ```runner_id```.

**Answer:**

|runner_id|successful_delivery|
|---------|-------------------|
|1        |4                  |
|2        |3                  |
|3        |1                  |

- Runner 1 had 4 successful deliveries.
- Runner 2 had 3 successful deliveries.
- Runner 3 had 1 successful delivery.

***

**4. How many of each type of pizza was delivered**

There are more than one solution for this question:

**Solution 1:**

```sql
SELECT
	pizza.pizza_name,
	COUNT(*) AS successful_delivery
FROM
	std_customer_order AS co
JOIN pizza_names AS pizza
	ON pizza.pizza_id = co.pizza_id
JOIN std_runner_order AS ro
	ON co.order_id = ro.order_id
	AND ro.distance > 0 AND ro.distance IS NOT NULL
	AND ro.distance > 0 AND ro.duration IS NOT NULL
	AND ro.cancellation IS NULL
GROUP BY
	pizza.pizza_name;
```

- Use ```COUNT```  to calcute the number of entries for succesful deliveries.
- Filter out unsuccessful deliveries, use ```JOIN``` to combine ```std_customer_order``` (aliased as ```co```) and ```std_runner_order``` (aliased as ```ro```) where both the delivery ```distance``` and ```duration``` are not missing and are larger than 0. Also, ```cancellation``` needs to be NULL, which means the delivery did not get scheduled.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of successful deliveries for each pizza seperately.


**Solution 2:**

```sql
WITH delivery AS (
	SELECT
		std_runner_order.order_id,
		std_customer_order.pizza_id
	FROM
		std_runner_order
	JOIN std_customer_order
		ON std_runner_order.order_id = std_customer_order.order_id
		AND (std_runner_order.distance > 0 AND std_runner_order.distance IS NOT NULL)
		AND (std_runner_order.duration > 0 AND std_runner_order.duration IS NOT NULL)
		AND (std_runner_order.cancellation IS NULL)
)

SELECT
	pizza_names.pizza_name,
	COUNT(*) AS successful_delivery
FROM
	delivery
JOIN pizza_names
	ON pizza_names.pizza_id = delivery.pizza_id
GROUP BY
	pizza_names.pizza_name;
```

- Create a CTE ```delivery``` which holds data of successful deliveries, containing the ```order_id``` and ```pizza_id``` of the order. Check the second point of the solution above for the definition of a successful delivery.
- Match the ```pizza_name``` to the ```pizza_id``` of the successful deliveries.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of successful deliveries for each pizza seperately.

**Answer:**

|pizza_name|successful_delivery|
|----------|-------------------|
|Meatlovers|9                  |
|Vegetarian|3                  |

- Meatlovers pizzas were successfully delivered 9 times.
- Vegetarian pizzas were successfully delivered 3 times.

***

**5. How many Vegetarian and Meatlovers were ordered by each customer?**

```sql
SELECT
	co.customer_id,
	pizza.pizza_name,
	COUNT(pizza.pizza_name) AS ordered
FROM
	std_customer_order AS co
JOIN pizza_names AS pizza
	ON pizza.pizza_id = co.pizza_id
WHERE
	pizza.pizza_name = 'Meatlovers' OR pizza.pizza_name = 'Vegetarian'
GROUP BY
	co.customer_id,
	pizza.pizza_name
ORDER BY
	co.customer_id;
```

- Use ```COUNT``` and ```GROUP BY``` to calculate the number of orders for each pizza separately. The ```GROUP BY``` clause also ensures the calculation is done for each customer with a unique ```customer_id``` separately.
- Use ```WHERE``` to specify the calculation for Meatlovers and Vegetarian pizzas only.

**Answer:**

|customer_id|pizza_name|ordered|
|-----------|----------|-------|
|101        |Meatlovers|2      |
|101        |Vegetarian|1      |
|102        |Meatlovers|2      |
|102        |Vegetarian|1      |
|103        |Meatlovers|3      |
|103        |Vegetarian|1      |
|104        |Meatlovers|3      |
|105        |Vegetarian|1      |

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizzas.
- Customer 105 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.

***

**6. What was the maximum number of pizzas delivered in a single order?**

```sql
WITH pizza_per_order AS (
	SELECT
		std_customer_order.order_id,
		COUNT(*) AS pizza_delivered
	FROM
		std_customer_order
	JOIN std_runner_order
		ON std_customer_order.order_id = std_runner_order.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
	GROUP BY
		std_customer_order.order_id
)

SELECT
	MAX(pizza_delivered) AS most_delivered_per_order
FROM
	pizza_per_order;
```

- Create a CTE ```pizza_per_order``` and use ```COUNT``` to caclulate the number of pizzas delivered per ```order_id```.
- Use ```pizza_delivered DESC``` to arrange the data in descending order of ```pizza_delivered```. The ```order_id``` with the most pizzas delivered will be on top.
- Use ```MAX``` to select the maximum value of ```pizza_delivered```.

**Answer:**

|most_delivered_per_order|
|------------------------|
|3                       |

- The maximum number of pizzas delivered in a single order is 3.

**To locate specific orders that contributed the most pizza delivered in a single order:**

```sql
WITH pizza_per_order AS (
	SELECT
		std_customer_order.order_id,
		COUNT(*) AS pizza_delivered
	FROM
		std_customer_order
	JOIN std_runner_order
		ON std_customer_order.order_id = std_runner_order.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
	GROUP BY
		std_customer_order.order_id
),

pizza_per_order_ranked AS (
	SELECT
		*,
		DENSE_RANK() OVER(
			ORDER BY pizza_delivered DESC
		) AS delivery_ranking
	FROM
		pizza_per_order
)

SELECT
	order_id,
	pizza_delivered
FROM
	pizza_per_order_ranked
WHERE
	delivery_ranking = 1;
```

**Output:**

|order_id|pizza_delivered|
|--------|---------------|
|4       |3              |


***

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
WITH delivered AS (
	SELECT
		co.customer_id,
		CASE
			WHEN exclusions IS NULL AND extras IS NULL
				THEN 'N'
			ELSE
				'Y'
			END AS changed
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
)

SELECT
	customer_id,
	SUM(CASE WHEN changed = 'Y' THEN 1 ELSE 0 END) AS changes_made,
	SUM(CASE WHEN changed = 'N' THEN 1 ELSE 0 END) AS no_changes
FROM
	delivered
GROUP BY
	customer_id;
```

- Create a CTE ```delivered``` that contains the data for all delivered orders and if the pizzas received any changes for those orders. Change were made if either the ```exlucions``` (remove toppings) or ```extras``` (add toppings) is not NULL.
- Record if any changes were made to the pizzas ordered as 'Y' for 'Yes' and 'N' for 'No'.
- Use ```SUM``` to count the number of 'Y' and 'N' for each customer (made changes vs no changes). Use ```GROUP BY``` to do this for each customer separately.

**Answer:**

|customer_id|changes_made|no_changes|
|-----------|------------|----------|
|101        |0           |2         |
|102        |0           |3         |
|103        |3           |0         |
|104        |2           |1         |
|105        |1           |0         |

- Customer with ```customer_id: 101``` had no pizzas with changes and 2 pizzas with changes delivered.
- Customer with ```customer_id: 102``` had no pizzas with changes and 3 pizzas with changes delivered.
- Customer with ```customer_id: 103``` had 3 pizzas with changes and no pizzas with changes delivered.
- Customer with ```customer_id: 104``` had 2 pizzas with changes and 1 pizza with changes delivered.
- Customer with ```customer_id: 105``` had 1 pizzas with changes and no pizzas with changes delivered.

***

**8. How many pizzas were delivered that had both exclusions and extras?**

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS delivered AS
SELECT
	co.order_id,
	co.exclusions,
	co.extras
FROM
	std_customer_order AS co
JOIN std_runner_order AS ro
	ON co.order_id = ro.order_id
	AND (distance > 0 AND distance IS NOT NULL)
	AND (duration > 0 AND duration IS NOT NULL)
	AND (cancellation IS NULL)
WHERE
	co.exclusions IS NOT NULL
	AND co.extras IS NOT NULL;

-- View the data
SELECT * FROM delivered;

-- Count orders with both exclusions and extras
SELECT
	COUNT(*) AS exclusions_and_extras
FROM
	delivered;

DROP TABLE IF EXISTS delivered;
```

- Create a temporary table ```delivered``` to store the ```order_id```, ```exclusions``` and ```extras``` data for all delivered orders. 
- Filter the data by including only entries that have toppings added (```extras IS NOT NULL```) and removed (```exclusions IS NOT NULL```) for the pizzas delivered.
- A temporary table is used in place of a CTE here as we need to run 2 main ```SELECT``` statements for the same set of data, whereas CTEs only work for a single ```SELECT``` statement.
- The first ```SELECT``` statement is to get an overview of the data, while the second ```SELECT``` statement is to answer the secific question.
- Drop the table after it has served its use.

**Answer:**

|order_id|exclusions|extras|
|--------|----------|------|
|10      |2, 6      |1, 4  |

|exclusions_and_extras|
|---------------------|
|1                    |

- As seen, there is only 1 entry with both ```exclusions``` and ```extras``` applied. The first table is an overview and the second table is the answer.

**Simpler solution:**

```sql
WITH delivered AS (
	SELECT
		co.order_id,
		co.exclusions,
		co.extras
	FROM
		std_customer_order AS co
	JOIN std_runner_order AS ro
		ON co.order_id = ro.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
	WHERE
		co.exclusions IS NOT NULL
		AND co.extras IS NOT NULL
)

SELECT
	COUNT(*) AS exclusions_and_extras
FROM
	delivered;
```

- Above is a more concise solution, which only gives:

|exclusions_and_extras|
|---------------------|
|1                    |

***

**9. What was the total volume of pizzas ordered for each hour of the day?**

```sql
SELECT 
	HOUR(order_time) AS hour_of_day, 
	COUNT(*) AS pizza_ordered
FROM 
	std_customer_order
GROUP BY 
	hour_of_day
ORDER BY 
	pizza_ordered DESC,
	hour_of_day;
```

- This question is to find out what is the peak ordering time across all days.
- Use ```HOUR``` to group orders into hours of the day. The output follows a 24-hour format: 18 for 6:00 p.m. or 18:00, 23 for 11:00 p.m. or 23:00 and so on.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of pizzas ordered for each hour of the day.
- Use ```ORDER BY``` and ```DESC``` the data in descending order of pizzas ordered.

**Answer:**

|hour_of_day|pizza_ordered|
|-----------|-------------|
|13         |3            |
|18         |3            |
|21         |3            |
|23         |3            |
|11         |1            |
|19         |1            |

- Above is the overview of ordering volume of each hour of day.
- Peak ordering hours are at 13:00, 18:00, 21:00 and 23:00.
- 11:00 and 13:00 had relatively less orders.

**To rank the order volume of each hour of the day:**

```sql
WITH order_by_hour AS (
	SELECT 
		HOUR(order_time) AS hour_of_day, 
		COUNT(*) AS pizza_ordered
	FROM 
		std_customer_order
	GROUP BY 
		hour_of_day
	ORDER BY 
		pizza_ordered DESC,
		hour_of_day
),

order_by_hour_ranked AS (
	SELECT
		*,
		DENSE_RANK() OVER (
			ORDER BY pizza_ordered DESC
		) AS ranking
	FROM
		order_by_hour
)

SELECT * FROM order_by_hour_ranked;
```

- In this case, it gives:

|hour_of_day|pizza_ordered|ranking|
|-----------|-------------|-------|
|13         |3            |1      |
|18         |3            |1      |
|21         |3            |1      |
|23         |3            |1      |
|11         |1            |2      |
|19         |1            |2      |

***

**10. What was the volume of orders for each day of the week?**

```sql
SELECT 
	DAYNAME(order_time) AS day_of_week, 
	COUNT(*) AS pizza_ordered
FROM 
	std_customer_order
GROUP BY 
	day_of_week
ORDER BY 
	pizza_ordered DESC,
	day_of_week;
```

- The solution to question 10 is very similar to question 9, instead of using ```HOUR``` we use ```DAYNAME``` to group orders into days of a week, from "Sunday", "Monday"... etc.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of pizzas ordered for each day of the week.
- This allows us to find out days with peak orders.

**Answer:**

|day_of_week|pizza_ordered|
|-----------|-------------|
|Saturday   |5            |
|Wednesday  |5            |
|Thursday   |3            |
|Friday     |1            |

- Saturdays and Wednesdays have the highest volume of orders.
- Thursdays have the second highest volume of orders.
- Fridays have the lowest volume of orders.

**To rank the order volume of each day of the week:**

```sql
WITH order_by_day AS (
	SELECT 
		DAYNAME(order_time) AS day_of_week, 
		COUNT(*) AS pizza_ordered
	FROM 
		std_customer_order
	GROUP BY 
		day_of_week
	ORDER BY 
		pizza_ordered DESC,
		day_of_week
),

order_by_day_ranked AS (
	SELECT
		*,
		DENSE_RANK() OVER (
			ORDER BY pizza_ordered DESC
		) AS ranking
	FROM
		order_by_day
)

SELECT * FROM order_by_day_ranked;
```
- In this case, it gives:

|day_of_week|pizza_ordered|ranking|
|-----------|-------------|-------|
|Saturday   |5            |1      |
|Wednesday  |5            |1      |
|Thursday   |3            |2      |
|Friday     |1            |3      |

***

Part A ends here. Click **[here to continue to Part B](https://github.com/nacht29/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Part%20B%3A%20Runner%20and%20Customer%20Experience/README.md)**.