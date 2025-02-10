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

bucket AS (
	-- Create 30-day buckets based on days taken to upgrade
	SELECT 
		FLOOR((annual.annual_date - trial.trial_date) / 30) AS avg_days_to_upgrade
	FROM trial_plan AS trial
	JOIN annual_plan AS annual
		ON trial.customer_id = annual.customer_id
)
  
SELECT 
	CONCAT(
		avg_days_to_upgrade * 30, 
		' - ', 
		(avg_days_to_upgrade + 1) * 30 - 1, 
		' days'
	) AS bucket, 
	COUNT(*) AS num_of_customers
FROM bucket
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;