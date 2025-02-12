WITH trial_plan AS (
	SELECT
		customer_id,
		start_date AS trial_date
	FROM subscriptions
	WHERE plan_id = 0
),

annual_plan AS (
	SELECT
		customer_id,
		start_date AS annual_date
	FROM subscriptions
	WHERE plan_id = 4
),

-- create and assign a bucket index to each customer
-- the index corresponds to a specifc range
-- say idx = 0, range = 1-30 days
bucket AS (
	SELECT
		FLOOR((annual_date - trial_date) / 30) AS bucket_idx
	FROM trial_plan AS trial
	JOIN annual_plan AS annual
		ON trial.customer_id = annual.customer_id
)

SELECT
	CONCAT(
		bucket_idx * 30, -- start range (index starts at 0, hence day 0)
		' - ',
		(bucket_idx + 1) * 30 - 1 -- end range [(multiple of 30) - 1]
	) AS day_range,
	COUNT(*) AS customers_count
FROM bucket
GROUP BY bucket_idx
ORDER BY bucket_idx;