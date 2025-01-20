# 🍕 Case Study #2 Pizza Runner

![Image](https://github.com/user-attachments/assets/c3bf086f-7b94-4286-976a-f4f7eb8dce8c)

## 📚 Table of Contents
- [Task Summary](#task-summary)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- Questions and Solutions
	- [Data Cleaning and Transformation](#data-cleaning-and-transformation)
	- A. [Pizza Metrics](#pizza-metrics)
	- B. [Runner and Customer Experience](#runner-and-customer-experience)
	- C. [Ingredient Optimisation](#ingredient-optimisation)
	- D. [Pricing and Ratings](#pricing-and-ratings)
	- E. [Bonus DML Challenges](#bonus-dml-challenges)

## Task Summary
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

### Entity Relationship Diagram
![Pizza Runner](https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/78099a4e-4d0e-421f-a560-b72e4321f530)

## Data Cleaning and Transformation

### Table: ```customer_orders```

**Before:**

- The ```exclusions``` column contains missing/null values.
- The ```extras``` column contains missing/null values.

|order_id|customer_id|pizza_id|exclusions|extras|order_time         |
|--------|-----------|--------|----------|------|-------------------|
|1       |101        |1       |          |      |2020-01-01 18:05:02|
|2       |101        |1       |          |      |2020-01-01 19:00:52|
|3       |102        |1       |          |      |2020-01-02 23:51:23|
|3       |102        |2       |          |NULL  |2020-01-02 23:51:23|
|4       |103        |1       |4         |      |2020-01-04 13:23:46|
|4       |103        |1       |4         |      |2020-01-04 13:23:46|
|4       |103        |2       |4         |      |2020-01-04 13:23:46|
|5       |104        |1       |null      |1     |2020-01-08 21:00:29|
|6       |101        |2       |null      |null  |2020-01-08 21:03:13|
|7       |105        |2       |null      |1     |2020-01-08 21:20:29|
|8       |102        |1       |null      |null  |2020-01-09 23:54:33|
|9       |103        |1       |4         |1, 5  |2020-01-10 11:22:59|
|10      |104        |1       |null      |null  |2020-01-11 18:34:49|
|10      |104        |1       |2, 6      |1, 4  |2020-01-11 18:34:49|

**Cleaning:**

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_customer_order AS
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions IS NULL OR exclusions LIKE 'null'
			THEN ' '
		ELSE
			exclusions
		END AS exclusions,
	CASE
		WHEN extras IS NULL OR extras LIKE 'null'
			THEN ' '
		ELSE
			extras
	END AS extras,
	order_time
FROM
	customer_orders;
```

### Table: ```runner_orders```

**Cleaning:**

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_runner_order AS
SELECT
	order_id,
	runner_id,
	CASE
		WHEN pickup_time IS NULL OR pickup_time LIKE 'null' 
			THEN ' '
		ELSE
			pickup_time
		END AS pickup_time,
	CASE
		WHEN distance IS NULL OR distance LIKE 'null'
			THEN ' '
		WHEN distance LIKE '%km' OR distance LIKE '% km'
			THEN TRIM(TRIM('km' FROM distance))
		ELSE
			distance
		END AS distance,
	CASE
		WHEN duration IS NULL OR duration LIKE 'null'
			THEN ' '
		WHEN duration LIKE '%mins' OR duration LIKE '% mins'
			THEN TRIM(TRIM('mins' FROM duration))
		WHEN duration LIKE '%minute' OR duration LIKE '% minute'
			THEN TRIM(TRIM('minute' FROM duration))
		WHEN duration LIKE '%minutes' OR duration LIKE '% minutes'
			THEN TRIM(TRIM('minutes' FROM duration))
		ELSE
			duration
		END AS duration,
	CASE
		WHEN cancellation IS NULL OR cancellation LIKE 'null'
			THEN ' '
		ELSE
			cancellation
		END AS cancellation
FROM
	runner_orders;
```

**Transformation:**

```sql
ALTER TABLE tmp_runner_order
ALTER COLUMN pickup_time DATETIME,
ALTER distance FLOAT,
ALTER duration INT;
```