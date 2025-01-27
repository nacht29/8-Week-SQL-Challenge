# Part B: Runner and Customer Experience

## Questions and Solutions

**1. How many runners signed up for each 1 week period? (i.e. week starts ```2021-01-01```)**

```sql
SELECT
	WEEK(registration_date) + 1 AS registration_week,
	COUNT(*) AS registration_count
FROM
	runners
GROUP BY
	registration_week;
```

- Use ```WEEK``` to separate the registration entries by week. Note the ```+ 1``` as the count starts with week 0.
- Use ```COUNT``` and ```GROUP BY``` to calculate the number of registrations for each separate week.

**Answer:**

|registration_week|registration_count|
|-----------------|------------------|
|1                |1                 |
|2                |2                 |
|3                |1                 |

- The first week had 1 runner signing up.
- The second week had 2 runners signing up.
- The third week had 1 runner signing up.

***

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

```sql
SELECT
	tro.runner_id,
	ROUND(
		AVG(
			TIMESTAMPDIFF(MINUTE, tco.order_time, tro.pickup_time)) ,2) AS avg_pickup_time
FROM
	tmp_runner_order AS tro
JOIN tmp_customer_order AS tco
	ON tco.order_id = tro.order_id
	AND tro.distance > 0 AND tro.distance IS NOT NULL
	AND tro.duration > 0 AND tro.duration IS NOT NULL
	AND tro.cancellation IS NULL
GROUP BY
	tro.runner_id;
```

- Use ```AVG``` and ```TIMESTAMPDIFF``` to calculate the average time for each runner to arrive (and pick up) their orders at the Pizza Runner HQ. The time taken is calculated by the difference between the time when the order is placed (```order_time```), to the time it is picked up (```pickup_time```).
- Use ```ROUND``` to change the result to two decimal places.
- Use ```GROUP BY``` to do the calculation for each separate runner.

**Answer:**

|runner_id|avg_pickup_time|
|---------|---------------|
|1        |15.33          |
|2        |23.40          |
|3        |10.00          |

- Runner 1 takes 15.33 minutes on average to pickup his orders for delivery.
- Runner 2 takes 23.40 minutes on average to pickup his orders for delivery.
- Runner 3 takes 10.00 minutes on average to pickup his orders for delivery.

***

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

```sql
WITH order_volume_and_prep_time AS (
	SELECT
		tco.order_id,
		COUNT(*) AS order_volume,
		TIMESTAMPDIFF(
			MINUTE,
			MIN(tco.order_time),
			MAX(tro.pickup_time)
		) AS total_prep_time
	FROM
		tmp_customer_order AS tco
	JOIN tmp_runner_order AS tro
		ON tco.order_id = tro.order_id
		AND tro.distance > 0 AND tro.distance IS NOT NULL
		AND tro.duration > 0 AND tro.duration IS NOT NULL
		AND tro.cancellation IS NULL
	GROUP BY
		tco.order_id
)

SELECT
	order_volume,
	ROUND(AVG(total_prep_time) ,2) AS avg_prep_time
FROM
	order_volume_and_prep_time
GROUP BY
	order_volume;
```
- Create a CTE that stores:
	- ```order_id```
	- number of orders per ```order_id``` as ```order_volume```
	- total preparation time for each ```order_id``` as ```total_prep_time```.
- ```total_prep_time``` is the total time taken to prepare all items ordered per ```order_id```. Use ```TIMESTAMPDIFF``` to calculate the difference, in minutes, for the earliest ```order_time``` and the latest ```pickup_time```. This calculates the time difference between the first item ordered to the last item prepared for delivery for each order entry.
- In the main query, use ```AVG``` to calculate the average time taken to produce different amounts of pizzas in a single order.

**Answer:**

|order_volume|avg_prep_time|
|------------|-------------|
|1           |12.00        |
|2           |18.00        |
|3           |29.00        |

- The average time taken to prepare 1 pizza is 12 minutes.
- The average time taken to prepare 2 pizzas is 18 minutes.
- The average time taken to prepare 3 pizzas is 29 minutes.
- Hence, we can conclude that, the higher the number of pizzas demanded per order entry, the longer time taken to prepare the order.

***

**4. What was the average distance travelled for each customer?**

```sql
SELECT
	tco.customer_id,
	ROUND(AVG(tro.distance), 2) AS average_distance
FROM
	tmp_customer_order AS tco
JOIN tmp_runner_order AS tro
	ON tco.order_id = tro.order_id
	AND tro.distance > 0 AND tro.distance IS NOT NULL
	AND tro.duration > 0 AND tro.duration IS NOT NULL
	AND tro.cancellation IS NULL
GROUP BY
	tco.customer_id;

```

***

**5. What was the difference between the longest and shortest delivery times for all orders?**

```sql
SELECT
	MAX(duration) - MIN(duration) AS time_difference
FROM
	tmp_runner_order
WHERE
	cancellation IS NULL;
```

***

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

We can draw several insighths from this question:

- Which runner has the highest average speed?

- Do runners slow down with larger orders or longer distances?

- Which runner is the most consistent (lowest variance in speed)?

- Are there significant differences between runners, or is the performance fairly uniform?
	- For this, we can calculate the standard deviation in average speed across all runners.

- Are there specific runners who improve or decline over time?

***

**7. What is the successful delivery percentage for each runner?**