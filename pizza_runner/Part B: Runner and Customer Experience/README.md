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
- Use ```AVG``` and ```GROUP BY``` to calculate the average distance travelled for each customer sepatately.
- Use ```ROUND``` to format the results to 2 decimal places.

**Answer:**

|customer_id|average_distance|
|-----------|----------------|
|101        |20.00           |
|102        |16.73           |
|103        |23.40           |
|104        |10.00           |
|105        |25.00           |

- Customer 101 has an average distance travlled of 20.00 km.
- Customer 102 has an average distance travlled of 16.73 km.
- Customer 103 has an average distance travlled of 23.40 km.
- Customer 104 has an average distance travlled of 10.00 km.
- Customer 105 has an average distance travlled of 25.00 km.

***

**5. What was the difference between the longest and shortest delivery times for all orders?**

```sql
SELECT
	MAX(duration) - MIN(duration) AS time_difference
FROM
	tmp_runner_order
WHERE
	distance > 0 AND distance IS NOT NULL
	AND duration > 0 AND duration IS NOT NULL
	AND cancellation IS NULL;
```

- Use ```MAX``` and ```MIN``` to find the longest and shortest delivery time across all orders and calculate their difference to find the range.

|time_difference|
|---------------|
|30             |

- The difference between the longest and shortest delivery times for all orders (aka range) is 30 minutes.

***

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

First, let's create a temporary table to store the values:

```sql
DROP TABLE IF EXISTS runner_avg_speed;
CREATE TEMPORARY TABLE IF NOT EXISTS runner_avg_speed AS
SELECT 
	runner_id,
	order_id,
	distance,
	duration,
	ROUND((distance / duration), 2) AS avg_speed
FROM 
	tmp_runner_order AS tro
WHERE
	distance > 0 
	AND duration > 0
	AND cancellation IS NULL
ORDER BY
	runner_id;
SELECT * FROM runner_avg_speed;
```

**Output:**

|runner_id|order_id|distance|duration|avg_speed|
|---------|--------|--------|--------|---------|
|1        |1       |20.00   |32      |0.63     |
|1        |2       |20.00   |27      |0.74     |
|1        |3       |13.40   |20      |0.67     |
|1        |10      |10.00   |10      |1.00     |
|2        |4       |23.40   |40      |0.59     |
|2        |7       |25.00   |25      |1.00     |
|2        |8       |23.40   |15      |1.56     |
|3        |5       |10.00   |15      |0.67     |

**Visualisation:**

![Image](https://github.com/user-attachments/assets/cf927947-60fe-4d4e-b632-3bc0ec72bb10)

We can draw several insighths from this:

**a. Which runner has the highest average speed?**

```sql
WITH overall_avg_speed AS (
	SELECT
		runner_id,
		ROUND(AVG(avg_speed) ,2) AS overall_speed
	FROM
		runner_avg_speed
	GROUP BY
		runner_id
)

SELECT
	DENSE_RANK() OVER(
		ORDER BY overall_speed DESC
	) AS ranking,
	runner_id
FROM
	overall_avg_speed;
```

**Output:**

|ranking|runner_id|
|-------|---------|
|1      |2        |
|2      |1        |
|3      |3        |

- Runner 2 is ranked first in average speed, meaning he/she is the top performer.
- Runner 1 is ranked second.
- Runner 3 is ranked last, meaning he/she us the most underperforming runner.

**Trend visualisation:**

![Image](https://github.com/user-attachments/assets/9cc640c9-7762-48fe-aa7b-86ecbc4bf772)

This can answer the following questions:

**b. Do runners slow down with larger orders or longer distances?**
- For Runner 1, the trend shows a visible decrease in average speed as distance increases.
- For Runner 2, his/her trend is very inconsistent, having a drastic gap in average speed for the same distance, as well as a significant spike in average speed as the distance increases.
- For Runner 3, he/she only has one successful delivery, hence it is hard to tell the trend for this runner.

**c. Which runner is the most consistent?**
- Runner 3, as he/she only has 1 delivery.

For more insights:

**d. Are there significant differences between runners, or is the performance fairly uniform?**

First, we need to calculate the overall average speed each runner:

```sql
WITH overall_avg_speed AS (
	SELECT
		runner_id,
		ROUND(AVG(avg_speed) ,2) AS overall_speed
	FROM
		runner_avg_speed
	GROUP BY
		runner_id
)

SELECT * FROM overall_avg_speed;
```

**Output:**

|runner_id|overall_speed|
|---------|-------------|
|1        |0.76         |
|2        |1.05         |
|3        |0.67         |

Then, we will calculate the percentage difference between the range and standard deviation:

```py
avg_speed = np.array(df['runner_id'])
std_dev = np.std(avg_speed)
data_range = max(avg_speed) - min(avg_speed)
print(f'Range: {data_range}')
print(f'Standard deviation: {std_dev}')
print(f'Difference in percentage: {((data_range - std_dev) / data_range * 100):.2f}%')
```

**Output:**
```
Range: 2
Standard deviation: 0.816496580927726
Difference in percentage: 59.18%
```

**Answer:**

- Since the difference in percentage between the range and standard deviation of the data is relatively large at 59.18%, the performance between runners can be comsidered not uniform.

**Visualisation:**

![Image](https://github.com/user-attachments/assets/0e04ec57-7ba3-4388-af2e-528cc5630c90)

Check out the **[Python code here](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/pizza_runner/Part%20B%3A%20Runner%20and%20Customer%20Experience/python-visualisation/partB.ipynb)**.

***

**7. What is the successful delivery percentage for each runner?**

```sql
WITH delivery_record AS (
	SELECT
		tco.order_id,
		tro.runner_id,
		CASE
			WHEN (duration > 0 AND duration IS NOT NULL 
			AND distance > 0 AND distance IS NOT NULL
			AND cancellation IS NULL)
				THEN 'Y'
			ELSE
				'N'
		END AS success
	FROM
		tmp_customer_order AS tco
	LEFT JOIN tmp_runner_order AS tro
		ON tco.order_id = tro.order_id
)

SELECT
	runner_id,
	ROUND(SUM(CASE WHEN success = 'Y' THEN 1 ELSE 0 END) / COUNT(*) * 100 ,2) AS del_percentage
FROM
	delivery_record
GROUP BY
	runner_id;
```

**Answer:**

|runner_id|del_percentage|
|---------|--------------|
|1        |100.00        |
|2        |83.33         |
|3        |50.00         |

***

Part B ends here. Click **[here to continue to Part C](https://github.com/nacht29/8-Week-SQL-Challenge/tree/main/pizza_runner/Part%20C%3A%20Ingredient%20Optimisation)**.