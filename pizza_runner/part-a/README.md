# A. Pizza Metrics

## Questions and Solutions

**1. How many pizzas were ordered?**

```sql
SELECT
	COUNT(*) AS pizza_ordered
FROM tmp_customer_order;
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
	tmp_customer_order;
```
- Use ```COUNT``` and ```DISTINCT``` to filter and count how many unique ```customer_id``` entries there are.
- Each distinct customer has a unique id -- ```customer_id```.

**Answer:**

|unique_order|
|------------|
|5           |

- There were 5 unique customer orders.

**3. How many successful orders were delivered by each runner?**

```sql
SELECT
	runner_id,
	COUNT(*) AS successful_delivery
FROM
	tmp_runner_order
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
	tmp_customer_order AS tco
JOIN pizza_names AS pizza
	ON pizza.pizza_id = tco.pizza_id
JOIN tmp_runner_order AS tro
	ON tco.order_id = tro.order_id
    AND tro.distance > 0 AND tro.distance IS NOT NULL
	AND tro.distance > 0 AND tro.duration IS NOT NULL
	AND tro.cancellation IS NULL
GROUP BY
	pizza.pizza_name;
```

- Use ```COUNT```  to calcute the number of entries for succesful deliveries.
- Filter out unsuccessful deliveries, use ```JOIN``` to combine ```tmp_customer_order``` (aliased as ```tco```) and ```tmp_runner_order``` (aliased as ```tro```) where both the delivery ```distance``` and ```duration``` are not missing and are larger than 0. Also, ```cancellation``` needs to be NULL, which means the delivery did not get scheduled.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of successful deliveries for each pizza seperately.


**Solution 2:**

```sql
WITH delivery AS (
	SELECT
		tmp_runner_order.order_id,
		tmp_customer_order.pizza_id
	FROM
		tmp_runner_order
	JOIN tmp_customer_order
		ON tmp_runner_order.order_id = tmp_customer_order.order_id
		AND (tmp_runner_order.distance > 0 AND tmp_runner_order.distance IS NOT NULL)
		AND (tmp_runner_order.duration > 0 AND tmp_runner_order.duration IS NOT NULL)
		AND (tmp_runner_order.cancellation IS NULL)
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
	tco.customer_id,
	pizza.pizza_name,
	COUNT(pizza.pizza_name) AS ordered
FROM
	tmp_customer_order AS tco
JOIN pizza_names AS pizza
	ON pizza.pizza_id = tco.pizza_id
WHERE
	pizza.pizza_name = 'Meatlovers' OR pizza.pizza_name = 'Vegetarian'
GROUP BY
	tco.customer_id,
	pizza.pizza_name
ORDER BY
	tco.customer_id;
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

**6. What was the maximum number of pizzas delivered in a single order?**

```sql
WITH pizza_per_order AS (
	SELECT
		tmp_customer_order.order_id,
		COUNT(*) AS pizza_delivered
	FROM
		tmp_customer_order
	JOIN tmp_runner_order
		ON tmp_customer_order.order_id = tmp_runner_order.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
	GROUP BY
		tmp_customer_order.order_id
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
		tmp_customer_order.order_id,
		COUNT(*) AS pizza_delivered
	FROM
		tmp_customer_order
	JOIN tmp_runner_order
		ON tmp_customer_order.order_id = tmp_runner_order.order_id
		AND (distance > 0 AND distance IS NOT NULL)
		AND (duration > 0 AND duration IS NOT NULL)
		AND (cancellation IS NULL)
	GROUP BY
		tmp_customer_order.order_id
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
