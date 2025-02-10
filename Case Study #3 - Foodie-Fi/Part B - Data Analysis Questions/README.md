**1. How many customers has Foodie-Fi ever had?**

```sql
SELECT
	COUNT(DISTINCT customer_id) AS all_customers
FROM subscriptions;
```
- Use ```COUNT DISTINCT``` to calculate the number of unique customers.

**Answer:**

|all_customers|
|-------------|
|1000         |
---

- Foodie-fi has had 1000 customers.

**2. What is the monthly distribution of ```trial``` plan ```start_date``` values for our dataset - use the start of the month as the group by value**

Simply put, the question is asking how many trial users there are monthly.

```sql
SELECT
	MONTH(start_date) AS '',
	MONTHNAME(start_date) AS months,
	COUNT(*) AS trial_usr
FROM subscriptions AS sub
JOIN plans
	ON plans.plan_id = sub.plan_id
WHERE plans.plan_name = 'trial'
GROUP BY
	MONTH(start_date),
	MONTHNAME(start_date)
ORDER BY MONTH(start_date);
```

**Answer:**

|      |months   |trial_usr|
|------|---------|---------|
|1     |January  |88       |
|2     |February |68       |
|3     |March    |94       |
|4     |April    |81       |
|5     |May      |88       |
|6     |June     |79       |
|7     |July     |89       |
|8     |August   |88       |
|9     |September|87       |
|10    |October  |79       |
|11    |November |75       |
|12    |December |84       |

---

**3. What plan ```start_date``` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each ```plan_name```**

In short, show the user count for each subscription plan after the year 2020.

```sql
SELECT
	plans.plan_id,
	plans.plan_name,
	COUNT(sub.customer_id) AS usr_count
FROM subscriptions AS sub
JOIN plans
	ON plans.plan_id = sub.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY
	plans.plan_id,
	plans.plan_name
ORDER BY plans.plan_id;
```

**Answer:**

|plan_id|plan_name    |usr_count|
|-------|-------------|---------|
|1      |basic monthly|8        |
|2      |pro monthly  |60       |
|3      |pro annual   |63       |
|4      |churn        |71       |

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```sql
SELECT
	COUNT(customer_id) AS count,
	ROUND(COUNT(customer_id) / (SELECT COUNT(*) FROM subscriptions) * 100, 1) AS 'percentage(%)'
FROM subscriptions AS sub
JOIN plans
	ON plans.plan_id = sub.plan_id
WHERE plan_name = 'churn'
GROUP BY
	plans.plan_id,
	plans.plan_name
ORDER BY plans.plan_id;
```

**Answer:**

|count|percentage(%)|
|-----|-------------|
|307  |11.6         |

---

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

```sql
WITH plan_sequence AS (
	SELECT
		sub.customer_id,
		sub.plan_id,
		sub.start_date,
		ROW_NUMBER() OVER (
			PARTITION BY sub.customer_id
			ORDER BY sub.start_date
		) AS plan_order
	FROM subscriptions AS sub
)

SELECT
	COUNT(customer_id) AS churned,
	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM plan_sequence) * 100, 2) AS churn_rate
FROM plan_sequence
WHERE plan_id = 4 AND plan_order = 2;
```

---

If we want to strictly adhere to the question:

```sql
WITH plan_sequence AS (
	SELECT
		sub.customer_id,
		sub.plan_id,
		sub.start_date,
		ROW_NUMBER() OVER (
			PARTITION BY sub.customer_id
			ORDER BY sub.start_date
		) AS plan_order
	FROM subscriptions AS sub
),

first_plans AS (
	SELECT
		ps1.customer_id,
		ps1.plan_id AS first_plan,
		ps2.plan_id AS second_plan
	FROM plan_sequence ps1
	LEFT JOIN plan_sequence ps2
		ON ps2.customer_id = ps1.customer_id
	WHERE
		ps1.plan_order = 1 AND ps2.plan_order = 2
)

SELECT
	COUNT(*) AS churned,
	ROUND(COUNT(*) / (SELECT COUNT(*) FROM first_plans) * 100, 2) AS churn_rate
FROM first_plans
WHERE first_plan = 0 AND second_plan = 4;
```

**Answer:**

|churned|churn_rate|
|-------|----------|
|92     |9.20      |

---

**6. What is the number and percentage of customer plans after their initial free trial?**

This question aims to calculate the conversion rate of customers from free trials to one of the paid plans (or disontinuing their subscription after the trials, aka churn).

```sql
WITH plan_sequence AS (
	SELECT
		sub.customer_id,
		sub.plan_id,
		sub.start_date,
		ROW_NUMBER() OVER (
			PARTITION BY sub.customer_id
			ORDER BY sub.start_date
		) AS plan_order
	FROM subscriptions AS sub
),

conversion AS (
	SELECT
		plan_id,
		customer_id
	FROM plan_sequence
	WHERE plan_order > 1
)

SELECT
	plan_id,
	COUNT(customer_id) AS converted,
	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 2) AS conversion_rate
FROM conversion
GROUP BY plan_id
ORDER BY plan_id;
```

**Answer:**

|plan_id|converted|conversion_rate|
|-------|---------|---------------|
|1      |546      |54.60          |
|3      |258      |25.80          |
|4      |307      |30.70          |
|2      |539      |53.90          |

---

**7. What is the customer count and percentage breakdown of all 5 ```plan_name``` values at ```2020-12-31```?**

The question aims to investigate the user count and use rate for each plan by ```2020-12-31```.

```sql
-- rank each customer's latest service by 2020-12-31
WITH latest_plan AS (
	SELECT 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date DESC -- latest date will be ranked first
		) as latest
	FROM subscriptions
	WHERE start_date <= '2020-12-31'
)

SELECT
	plans.plan_name,
	COUNT(customer_id) AS usr_count,
	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100 ,2) AS use_rate
FROM latest_plan
JOIN plans
	ON plans.plan_id = latest_plan.plan_id
WHERE latest = 1 -- select latest plan
GROUP BY plans.plan_name;
```

- Create a CTE to rank each customer's plan in desending order of ```start_date```, hence the latest plan will be on top. Use ```WHERE start_date <= '2020-12-31'``` to rank only the data before ```2020-12-31```.
- Use ```COUNT``` to calculate the number of users for each plan.
- Then, divide the number of user for each plan by the total number of users to calculate the use rate for each plan.
- The ```WHERE``` condition in the main query ensures only the latest plan for each customer by ```2020-12-31``` is taken into acccount.

**Answer:**

|plan_name    |usr_count|use_rate|
|-------------|---------|--------|
|trial        |19       |1.90    |
|basic monthly|224      |22.40   |
|pro monthly  |326      |32.60   |
|pro annual   |195      |19.50   |
|churn        |236      |23.60   |

---

**8. How many customers have upgraded to an annual plan in 2020?**

```sql
SELECT COUNT(DISTINCT customer_id) AS pro_monthly_usr
FROM subscriptions
WHERE plan_id = 3 AND start_date <= '2020-12-31'
```

**Answer:**

|pro_monthly_usr|
|---------------|
|195            |

---

Alternatively, use this to get a full view of the picture
```sql
WITH latest_plan AS (
	SELECT 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date DESC
		) as latest
	FROM subscriptions
	WHERE YEAR(start_date) = '2020'
)

SELECT
	plans.plan_name,
	COUNT(customer_id) AS usr_count,
	ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100 ,2) AS use_rate
FROM latest_plan
JOIN plans
	ON plans.plan_id = latest_plan.plan_id
WHERE latest = 1
GROUP BY plans.plan_name;
```
- The solution is very similar to queestion 7.
- Simply change the ```WHERE``` condition and use ```YEAR``` so that we get the data where the year is '2020'.

**Answer:**

|plan_name    |usr_count|use_rate|
|-------------|---------|--------|
|trial        |19       |1.90    |
|basic monthly|224      |22.40   |
|pro monthly  |326      |32.60   |
|pro annual   |195      |19.50   |
|churn        |236      |23.60   |

---

**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

```sql
WITH earliest_plan AS (
	SELECT 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date ASC
		) as earliest
	FROM subscriptions
)

SELECT
	ROUND(AVG(ep1.start_date - ep2.start_date), 2) AS avg_days
FROM earliest_plan AS ep1
JOIN earliest_plan AS ep2
	ON ep1.customer_id = ep2.customer_id
WHERE 
	ep1.plan_id = 3
	AND ep2.earliest = 1;
```

- Create a CTE that arranges each customer's plan in ascending order of ```start_date``` aka starting date.
- Use ```AVG``` to calculate the average difference, in days, between each customer's earliest plan to the pro annual plan.
- Use ```ROUND``` to format the output to 2 decimal places.

---

Alternatively we can do this:

```sql
WITH pro_annual AS (
	SELECT
		customer_id,
		start_date
	FROM subscriptions
	WHERE plan_id = 3
),

trial AS (
	SELECT
		customer_id,
		start_date
	FROM subscriptions
	WHERE plan_id = 0
)

SELECT
	ROUND(AVG(pa.start_date - tr.start_date) ,2) AS avg_days
FROM pro_annual AS pa
JOIN trial AS tr
	ON pa.customer_id = tr.customer_id;
```

- Create a CTE, ```pro_annual``` to filter and get the data of customers who has upgraded to the pro annual plan.
- Create another CTE, ```trial``` to filter and get the date when each customer joined and used the trial plan.
- Use ```AVG``` to calculate the average difference, in days, between each customer's trial plan to the pro annual plan.
- Use ```ROUND``` to format the output to 2 decimal places.

**Answer:**

|avg_days|
|--------|
|2488.62 |

---

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

First of all, it is important to note that the range 0-30, 31-60, ... is not logical as 0-30 is actually 31 days. A more correct representation would be 0-29, 30-59, ... or 1-30, 31-60, ...

**First approach (0-29, 30-59, ...):**

- Each customer's upgrade time falls into a specific range, calculated using:
	- ```bucket_index = ⌊(annual_date − trial_date − 1)/30⌋```
	
	The ```bucket_index``` values are mapped to a specific range:

	- 0 --> 0-29
	- 1 --> 30-59
	- 2 --> 60-89
	- 3 --> 90-119

	For example, if we put 40 into the formula, we get 1, hence the second range, which is 31-59.

- We then, we calculate the bucket range as:
	- ```Start = bucket_index × 30```
	- ```End = (bucket_index + 1) × 30 - 1```

**Visualisation:**

| Days Taken to Upgrade| Bucket Index (FLOOR(days / 30))| Start          |End                    |Final bucket|
|----------------------|--------------------------------|----------------|-----------------------|------------|
| 10                   | FLOOR(10 / 30) = 0             |0 * 30 = 0      | (0 + 1) * 30 - 1 = 29 |0-29        |
| 25                   | FLOOR(25 / 30) = 0             |0 * 30 = 0      | (0 + 1) * 30 - 1 = 29 |0-29        |
| 40                   | FLOOR(40 / 30) = 1             |1 * 30 = 30     | (2 + 1) * 30 - 1 = 59 |30-59       |
| 70                   | FLOOR(70 / 30) = 2             |2 * 30 = 60     | (3 + 1) * 30 - 1 = 89 |60-89       |
| 95                   | FLOOR(95 / 30) = 3             |3 * 30 = 90     | (4 + 1) * 30 - 1 = 119|90-119      |

---

**Second apporach (1-30, 31-60, ...):**

- Each customer's upgrade time falls into a specific range, calculated using:
	- ```bucket_index = ⌊(annual_date − trial_date − 1)/30⌋```
	
	This assigns values to specific ranges. For example, if we put 40 into the formula, we get 1, hence the second range, which is 31-60(we start counting from 0).

	Note the ```- 1``` in the formula. This is to prevent this case:

	|Days taken to upgrade|(days / 30) |FLOOR(days / 30)|bucket_index|range|
	|---------------------|------------|----------------|------------|-----|
	|30                   |30/30 = 1.00|FLOOR(1.00) = 1 |1           |31-60|
	|31                   |31/30 = 1.03|FLOOR(1.03) = 1 |1           |31-60|

	The range for value 30 is wrong.

	Now if we add the ```- 1```:

	|Days taken to upgrade|(days - 1 / 30)   |FLOOR(days / 30)|bucket_index|range|
	|---------------------|------------------|----------------|------------|-----|
	|30                   |(30 - 1)/30 = 0.96|FLOOR(0.96) = 0 |0           | 1-30|
	|31                   |(31 - 1)/30 = 1.00|FLOOR(1.00) = 1 |1           |31-60|

- We then, we calculate the bucket range as:
	- ```Start = bucket_index × 30 + 1```
	- ```End = (bucket_index + 1) × 30```

	Note the + 1 in this case as well, because by default the values would be 0-29, 30-59, ... We need to manually increment the values by 1 for the representation that we want.

**Visualisation:**

| Days Taken to Upgrade| Bucket Index (FLOOR((days - 1) / 30))       | Start          |End           | Final Bucket|
|----------------------|---------------------------------------------|----------------|--------------|-------------|
| 10                   | FLOOR((10 - 1) / 30) = FLOOR(9 / 30) =		0| 0 * 30 + 1 = 1 | 1 * 30 = 30  | 1-30 days   |
| 25                   | FLOOR((25 - 1) / 30) = FLOOR(24 / 30) =	0| 0 * 30 + 1 = 1 | 1 * 30 = 30  | 1-30 days   |
| 40                   | FLOOR((40 - 1) / 30) = FLOOR(39 / 30) =	1| 1 * 30 + 1 = 31| 2 * 30 = 60  | 31-60 days  |
| 70                   | FLOOR((70 - 1) / 30) = FLOOR(69 / 30) =	2| 2 * 30 + 1 = 61| 3 * 30 = 90  | 61-90 days  |
| 95                   | FLOOR((95 - 1) / 30) = FLOOR(94 / 30) =	3| 3 * 30 + 1 = 91| 4 * 30 = 120 | 91-120 days |
| 120                  | FLOOR((120 - 1) / 30) = FLOOR(119 / 30) =	3| 3 * 30 + 1 = 91| 4 * 30 = 120 | 91-120 days |

---

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

```sql
WITH latest_plan AS (
	SELECT 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date DESC
		) as latest
	FROM subscriptions
	WHERE YEAR(start_date) = '2020'
),

compare AS (
	SELECT
		lp1.customer_id,
		lp1.latest AS basic,
		lp2.latest AS pro
	FROM latest_plan AS lp1
	JOIN latest_plan AS lp2
		ON lp2.customer_id = lp1.customer_id
	WHERE
		lp1.plan_id = 1
		AND lp2.plan_id = 2
)

SELECT
	COUNT(customer_id) AS downgraded
FROM compare
WHERE pro > basic;
```

**Answer:**

|downgraded|
|----------|
|0         |