WITH trial_plan AS (
	-- Get customers subscribed to the trial plan
	SELECT 
		customer_id, 
		start_date AS trial_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 0
),

annual_plan AS (
	-- Get customers subscribed to the pro annual plan
	SELECT 
		customer_id, 
		start_date AS annual_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3
),

buckets AS (
	-- Create 30-day buckets based on days taken to upgrade
	SELECT 
		FLOOR((annual.annual_date - trial.trial_date - 1) / 30) AS bucket_index
	FROM trial_plan AS trial
	JOIN annual_plan AS annual
		ON trial.customer_id = annual.customer_id
)
  
SELECT 
	CONCAT(
		bucket_index * 30 + 1,  -- Start of the bucket
		'-', 
		(bucket_index + 1) * 30, -- End of the bucket
		' days'
	) AS bucket, 
	COUNT(*) AS num_of_customers
FROM buckets
GROUP BY bucket_index
ORDER BY bucket_index;