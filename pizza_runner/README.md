# 🍕 Case Study #2 Pizza Runner

<img src="https://github.com/user-attachments/assets/c3bf086f-7b94-4286-976a-f4f7eb8dce8c" alt="Image" width="500" height="520">

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

To read the full script, please click **[here]([https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/78099a4e-4d0e-421f-a560-b72e4321f530](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/pizza_runner/cleaning.sql))**.

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

***

**Cleaning:**

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

- Create a temporary table ```tmp_customer_order``` to store the cleaned and transformed data from the ```customer_orders``` table. Temporary tables exists until the session ends, and is able to be queried like a normal table without altering the data in the original table. A session is started when a client connects to the SQL server, amd is terminated when either the client explicitly disconnects or a connection timeout occurs. 
- Due to syntax reasons in **MySQL**, data types need to be specified during the creation of temporary tables instead of using ```ALTER``` or ```MODIFY``` later.
- Hence, note that ```order_date``` is casted to ```DATETIME``` prior to modifying and inserting data into the temporary table.

```sql
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

- Use ```CASE WHEN``` statement to clean the data for the ```exclusions``` column. Replace NULL values (either the ```NULL``` data type or "null" string) with and empty space ' '. Else, keep the data for  ```exclusions``` column as is.
- Apply the same cleaning method for the ```extras``` column.
- As per the creation of the temporary table, ```exclusions``` and ```extras``` columns will be casted to the ```INT``` data type, and ```order_date``` to ```DATETIME```.

***

**After:**

|order_id|customer_id|pizza_id|exclusions|extras|order_time         |
|--------|-----------|--------|----------|------|-------------------|
|1       |101        |1       |          |      |2020-01-01 18:05:02|
|2       |101        |1       |          |      |2020-01-01 19:00:52|
|3       |102        |1       |          |      |2020-01-02 23:51:23|
|3       |102        |2       |          |      |2020-01-02 23:51:23|
|4       |103        |1       |4         |      |2020-01-04 13:23:46|
|4       |103        |1       |4         |      |2020-01-04 13:23:46|
|4       |103        |2       |4         |      |2020-01-04 13:23:46|
|5       |104        |1       |          |1     |2020-01-08 21:00:29|
|6       |101        |2       |          |      |2020-01-08 21:03:13|
|7       |105        |2       |          |1     |2020-01-08 21:20:29|
|8       |102        |1       |          |      |2020-01-09 23:54:33|
|9       |103        |1       |4         |1, 5  |2020-01-10 11:22:59|
|10      |104        |1       |          |      |2020-01-11 18:34:49|
|10      |104        |1       |2, 6      |1, 4  |2020-01-11 18:34:49|


***

### Table: ```runner_orders```

**Before:**

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

**Cleaning:**

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
	WHEN pickup_time IS NULL OR pickup_time LIKE 'null' 
		THEN 0
	ELSE
		pickup_time
	END AS pickup_time,
```

-  Replace null/missing values in the ```pickup_time``` column with integer ```0```. When casted to ```DATETIME```, it will be shown as an empty space. If an empty space (' ') is used instead an error will arise during casting.
- This has to do with how the computer, and in this case **MySQL** tracks ```DATETIME``` values as serial numbers, counting since a [specific date](#trivia).
- Else, keep ```pickup_time``` as is. 
- As per the creation of the temporary table, the ```pickup_time``` column is casted to ```DATETIME``` data type.

```sql
CASE
	WHEN distance IS NULL OR distance LIKE 'null'
		THEN 0
	WHEN distance LIKE '%km' OR distance LIKE '% km'
		THEN TRIM(TRIM('km' FROM distance))
	ELSE
		distance
	END AS distance,
```

- Replace null/missing values in the ```distance``` column with integer ```0```. Again, this is to prevent raising errors.
- If the data in ```distance``` contains units such as "km", use ```TRIM``` to trim away the unit, then use ```TRIM``` again trim away any empty spaces.
- Example (The "\$" is to show the end of the string):
	- ```13 km$ ->TRIM unit-> 13 $ ->TRIM space-> 13$```
- Else, keep the data for ```distance``` as is.
- As per the creation of the temporary table, ```distance``` is casted to ```DECIMAL(10,2)```, with 2 decimal points to ensure consistency.

```sql
	CASE
		WHEN duration IS NULL OR duration LIKE 'null'
			THEN 0
		WHEN duration LIKE '%mins' OR duration LIKE '% mins'
			THEN TRIM(TRIM('mins' FROM duration))
		WHEN duration LIKE '%minute' OR duration LIKE '% minute'
			THEN TRIM(TRIM('minute' FROM duration))
		WHEN duration LIKE '%minutes' OR duration LIKE '% minutes'
			THEN TRIM(TRIM('minutes' FROM duration))
		ELSE
			duration
		END AS duration,
```
- Replace null/missing values in the ```duration``` column with integer ```0```. This is to avoid error during casting.
- If the data in ```duration``` contains units such as "minutes" or "mins", use ```TRIM``` to trim away the unit, then use ```TRIM``` again trim away any empty spaces.
- Repeat the trimming process for all existing unit variations, including "minutes", "mins" and "minute".
- Else, keep the data for ```duration``` as is.
- As per the creation of the temporary, ```duration``` is casted to the ```INT``` data type.

```sql
CASE
	WHEN cancellation IS NULL OR cancellation LIKE 'null'
		THEN ' '
	ELSE
		cancellation
	END AS cancellation
```
- Replace null/missing values in the ```cancellation``` column with an empty space.
- Else, keep the data for ```cancellation``` as is.

***

**After:**

|order_id|runner_id|pickup_time|distance|duration|cancellation       |
|--------|---------|-----------|--------|--------|-------------------|
|1       |1        |2020-01-01 18:15:34|20      |32      |                   |
|2       |1        |2020-01-01 19:10:54|20      |27      |                   |
|3       |1        |2020-01-03 00:12:37|13.4    |20      |                   |
|4       |2        |2020-01-04 13:53:03|23.4    |40      |                   |
|5       |3        |2020-01-08 21:10:57|10      |15      |                   |
|6       |3        |           |        |        |Restaurant Cancellation|
|7       |2        |2020-01-08 21:30:45|25      |25      |                   |
|8       |2        |2020-01-10 00:15:02|23.4    |15      |                   |
|9       |2        |           |        |        |Customer Cancellation|
|10      |1        |2020-01-11 18:50:20|10      |10      |                   |

***

### Trivia - DATETIME
Unix, which is the backbone of many modern operating systems like macOS, Android, iOS, and Linux, counts time as the number of seconds that have passed since midnight UTC on January 1, 1970.

Hence, casting an empty space (' ') cannot to ```DATETIME`` will raise errors in this case as empty space cannot be counted like a serial number.
