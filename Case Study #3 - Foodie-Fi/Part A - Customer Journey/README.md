# Part A - Customer Journey

## Questions and solutions

**1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.**

```sql
SELECT 
	sub.customer_id,
	plans.plan_name,
	sub.start_date
FROM subscriptions AS sub
JOIN plans
	ON plans.plan_id = sub.plan_id
WHERE customer_id <= 8;
```

|customer_id|plan_name    |start_date|
|-----------|-------------|----------|
|1          |trial        |2020-08-01|
|1          |basic monthly|2020-08-08|
|2          |trial        |2020-09-20|
|2          |pro annual   |2020-09-27|
|3          |trial        |2020-01-13|
|3          |basic monthly|2020-01-20|
|4          |trial        |2020-01-17|
|4          |basic monthly|2020-01-24|
|4          |churn        |2020-04-21|
|5          |trial        |2020-08-03|
|5          |basic monthly|2020-08-10|
|6          |trial        |2020-12-23|
|6          |basic monthly|2020-12-30|
|6          |churn        |2021-02-26|
|7          |trial        |2020-02-05|
|7          |basic monthly|2020-02-12|
|7          |pro monthly  |2020-05-22|
|8          |trial        |2020-06-11|
|8          |basic monthly|2020-06-18|
|8          |pro monthly  |2020-08-03|

**Trend visualisation:**
