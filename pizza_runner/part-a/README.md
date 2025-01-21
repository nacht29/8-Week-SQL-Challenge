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

- Use ```COUNT```  to calcute the number of entries for succesful entries

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
	pizza.pizza_name;
```
**Answer:**

|customer_id|pizza_name|ordered|
|-----------|----------|-------|
|101        |Meatlovers|2      |
|102        |Meatlovers|2      |
|102        |Vegetarian|1      |
|103        |Meatlovers|3      |
|103        |Vegetarian|1      |
|104        |Meatlovers|3      |
|101        |Vegetarian|1      |
|105        |Vegetarian|1      |
