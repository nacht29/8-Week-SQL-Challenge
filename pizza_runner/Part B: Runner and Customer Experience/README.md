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