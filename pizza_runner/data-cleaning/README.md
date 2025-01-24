# 🛠️ Data Cleaning and Transformation

## 📊 Table: ```customer_orders```

### Before

- The ```exclusions``` column contains missing/null values.
- The ```extras``` column contains missing/null values.
- The ```exclusions``` and ```extras``` are toppings to remove/add for pizzas.

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

***

### Cleaning

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_customer_order (
	order_id INT,
	customer_id INT,
	pizza_id INT,
	exclusions VARCHAR(50),
	extras VARCHAR(50),
	order_time DATETIME
) AS 
```

- Create a temporary table ```tmp_customer_order``` to store the cleaned and transformed data from the ```customer_orders``` table. Temporary tables exists until the session ends, and is able to be queried like a normal table without altering the data in the original table. A session is started when a client connects to the SQL server, and is terminated when either the client explicitly disconnects or a connection timeout occurs. 
- Cast the columns to their supposed data type, such as ```order_time``` is supposed to be a ```DATETIME``` data type as it stores the date and time an order is placed, as opposed to ```VARCHAR```.

```sql
SELECT
	order_id,
	customer_id,
	pizza_id,
	CASE
		WHEN exclusions IS NULL OR exclusions LIKE 'null' OR exclusions = ''
			THEN NULL
		ELSE
			exclusions
		END AS exclusions,
	CASE
		WHEN extras IS NULL OR extras LIKE 'null' OR extras = ''
			THEN NULL
		ELSE
			extras
	END AS extras,
	order_time
FROM
	customer_orders;
```

- Use ```CASE WHEN``` statement to clean the data for the ```exclusions``` column. Standardise all missing values to NULL.
- Apply the same cleaning method for the ```extras``` column.
- As per the creation of the temporary table, ```exclusions``` and ```extras``` columns will be casted to the ```INT``` data type, and ```order_date``` to ```DATETIME```.

***

### After

|order_id|customer_id|pizza_id|exclusions|extras|order_time         |
|--------|-----------|--------|----------|------|-------------------|
|1       |101        |1       |NULL      |NULL  |2020-01-01 18:05:02|
|2       |101        |1       |NULL      |NULL  |2020-01-01 19:00:52|
|3       |102        |1       |NULL      |NULL  |2020-01-02 23:51:23|
|3       |102        |2       |NULL      |NULL  |2020-01-02 23:51:23|
|4       |103        |1       |4         |NULL  |2020-01-04 13:23:46|
|4       |103        |1       |4         |NULL  |2020-01-04 13:23:46|
|4       |103        |2       |4         |NULL  |2020-01-04 13:23:46|
|5       |104        |1       |NULL      |1     |2020-01-08 21:00:29|
|6       |101        |2       |NULL      |NULL  |2020-01-08 21:03:13|
|7       |105        |2       |NULL      |1     |2020-01-08 21:20:29|
|8       |102        |1       |NULL      |NULL  |2020-01-09 23:54:33|
|9       |103        |1       |4         |1, 5  |2020-01-10 11:22:59|
|10      |104        |1       |NULL      |NULL  |2020-01-11 18:34:49|
|10      |104        |1       |2, 6      |1, 4  |2020-01-11 18:34:49|


***

## 📊 Table: ```runner_orders```

### Before

- There are missing/null values in the ```pickup_time```, ```distance```, ```duration``` and ```cancellation``` columns.
- Data is unstandardised in the ```distance``` and ```duration``` columns. For example, the unit used for ```duration``` has several variations, including "minutes", "minute" and "mins", and they have inconsistent delimiters (some are separated by space while some are not).
The ```distance``` column also has unstandardised specifiers.
-  It is also worth mentioning having units is redundant in this case as the data will be forced to be stored as ```VARCHAR```.

|order_id|runner_id|pickup_time        |distance|duration  |cancellation           |
|--------|---------|-------------------|--------|----------|-----------------------|
|1       |1        |2020-01-01 18:15:34|20km    |32 minutes|                       |
|2       |1        |2020-01-01 19:10:54|20km    |27 minutes|                       |
|3       |1        |2020-01-03 00:12:37|13.4km  |20 mins   |NULL                   |
|4       |2        |2020-01-04 13:53:03|23.4    |40        |NULL                   |
|5       |3        |2020-01-08 21:10:57|10      |15        |NULL                   |
|6       |3        |null               |null    |null      |Restaurant Cancellation|
|7       |2        |2020-01-08 21:30:45|25km    |25mins    |null                   |
|8       |2        |2020-01-10 00:15:02|23.4 km |15 minute |null                   |
|9       |2        |null               |null    |null      |Customer Cancellation  |
|10      |1        |2020-01-11 18:50:20|10km    |10minutes |null                   |

***

### Cleaning

```sql
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_runner_order (
	order_id INT,
	runner_id INT,
	pickup_time DATETIME,
	distance DECIMAL(10,2),
	duration INT,
	cancellation VARCHAR(50)
) AS
```

- Create a temporary table ```tmp_runner_order```. Cast ```pickup_time``` as ```DATETIME```, ```distance``` as ```DECIMAL``` and ```duration``` as ```INT```. The use of ```DECIMAL``` instead of ```FLOAT``` is to ensure accuracy and consistency and to avoid futher rounding of the numerical data.

```sql
CASE
	WHEN pickup_time IS NULL OR pickup_time LIKE 'null'  OR pickup_time LIKE ''
		THEN NULL
	ELSE
		CAST(pickup_time AS DATETIME)
	END AS pickup_time,
```

-  Standardise missing/null values in the ```pickup_time``` column as NULL.
- Else, keep ```pickup_time``` as is. 
- As per the creation of the temporary table, the ```pickup_time``` column is casted to ```DATETIME``` data type.

```sql
CASE
	WHEN distance IS NULL OR distance LIKE 'null' OR distance LIKE ''
		THEN NULL
	WHEN distance LIKE '%km' OR distance LIKE '% km'
		THEN TRIM(TRIM('km' FROM distance))
	ELSE
		distance
	END AS distance,
```

- Standardise missing/null values in the ```distance``` column with as NULL.
- If the data in ```distance``` contains units such as "km", use ```TRIM``` to trim away the unit, then use ```TRIM``` again trim away any empty spaces.
- Example (The "\$" is to show the end of the string):
	- ```13 km$ ->TRIM unit-> 13 $ ->TRIM space-> 13$```
- Else, keep the data for ```distance``` as is.
- As per the creation of the temporary table, ```distance``` is casted to ```DECIMAL(10,2)```, with 2 decimal points to ensure consistency.

```sql
CASE
	WHEN duration IS NULL OR duration LIKE 'null' OR duration LIKE ''
		THEN NULL
	WHEN duration LIKE '%mins' OR duration LIKE '% mins'
		THEN TRIM(BOTH ' ' FROM TRIM('mins' FROM duration))
	WHEN duration LIKE '%minute' OR duration LIKE '% minute'
		THEN TRIM(BOTH ' ' FROM TRIM('minute' FROM duration))
	WHEN duration LIKE '%minutes' OR duration LIKE '% minutes'
		THEN TRIM(BOTH ' ' FROM TRIM('minutes' FROM duration))
	ELSE
		duration
```
- Standardise the missing/null values in the ```duration``` as NULL.
- If the data in ```duration``` contains units such as "minutes" or "mins", use ```TRIM``` to trim away the unit, then use ```TRIM``` again trim away any empty spaces.
- Repeat the trimming process for all existing unit variations, including "minutes", "mins" and "minute".
- Else, keep the data for ```duration``` as is.
- As per the creation of the temporary, ```duration``` is casted to the ```INT``` data type.

```sql
CASE
	WHEN cancellation IS NULL OR cancellation LIKE 'null' OR cancellation LIKE ''
		THEN ' '
	ELSE
		cancellation
	END AS cancellation
```
- Standardise the missing/null values in the ```cancellation``` column as NULL.
- Else, keep the data for ```cancellation``` as is.

***

### After

|order_id|runner_id|pickup_time|distance|duration|cancellation               |
|--------|---------|-----------|--------|--------|---------------------------|
|1       |1        |2020-01-01 18:15:34|20.00   |32      |NULL               |
|2       |1        |2020-01-01 19:10:54|20.00   |27      |NULL               |
|3       |1        |2020-01-03 00:12:37|13.40   |20      |NULL               |
|4       |2        |2020-01-04 13:53:03|23.40   |40      |NULL               |
|5       |3        |2020-01-08 21:10:57|10.00   |15      |NULL               |
|6       |3        |NULL       |NULL    |NULL   |Restaurant Cancellation     |
|7       |2        |2020-01-08 21:30:45|25.00   |25      |NULL               |
|8       |2        |2020-01-10 00:15:02|23.40   |15      |NULL               |
|9       |2        |NULL       |NULL    |NULL   |Customer Cancellation       |
|10      |1        |2020-01-11 18:50:20|10.00   |10      |NULL               |

