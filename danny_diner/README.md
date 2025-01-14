# 🍜 Case Study #1: Danny's Diner

<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Task Summary](#task-summary)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Questions and Solutions](#questions-and-solutions)
- [Bonus Questions and Solutions](#bonus-questions-and-solutions)

### Task Summary
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

### Entity Relationship Diagram
![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

### Questions and Solutions
**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT 
	sales.customer_id, 
	SUM(menu.price) AS total_sales
FROM
	sales
LEFT JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY
	sales.customer_id
ORDER BY
	sales.customer_id ASC;
````

**Steps:**
- Use ```JOIN``` to merge ````sales```` table and ````menu````table since we need ````sales.customer_id```` and ````menu.price```` to show and count the amount each customer spent.
- Use ````SUM```` to total up the sales contributed by each customer.
- Use ````GROUP```` to calculate contribution by each customer separately, then arrange the results with ````sales.customer````_id in ascending order.

**Answer:**

| customer_id | total_sales |
|-------------|-------------|
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT
	sales.customer_id,
	COUNT(DISTINCT order_date) as number_of_visits
FROM
	sales
GROUP BY
	sales.customer_id;
````

**Steps:**
- Use ````COUNT(DISTINCT order_date)```` to count the unique number of visit by each customer.
- The ````DISTINCT```` keyword is highly important here as it avoids counting multiple, duplicate visits on the same day. For example, Customer A has 2 visits on date ````"2021-01-01"````. Without the ````DISTINCT```` keyword, 2 separate days will be counted instead of 1.

to test:
````sql
SELECT
	customer_id,
	order_date
FROM
	sales
GROUP BY
	customer_id,
	order_date
HAVING
	COUNT(*) > 1;
````

**Answer:**

|customer_id|number_of_visits|
|-----------|----------------|
|A          |4               |
|B          |6               |
|C          |2               |

- Customer A visited on 4 days.
- Customer B visited on 6 days.
- Customer C visited on 2 days.

***

**3. What was the first item from the menu purchased by each customer?**

````sql
WITH sales_in_order AS (
	SELECT
		sales.customer_id,
		sales.order_date,
		menu.product_name,
	DENSE_RANK() OVER(
		PARTITION BY sales.customer_id
		ORDER BY sales.order_date ASC) AS ranked
	FROM
		sales
	LEFT JOIN menu
		ON menu.product_id = sales.product_id
)

SELECT
	customer_id,
	order_date,
	product_name
FROM
	sales_in_order
WHERE
	ranked = 1
ORDER BY
	customer_id;
````

**Steps:**

- Create a CTE (think of it as a temporary table) that contains ````sales.customer_id````, ````sales.order_date```` and ````menu.product_name```` which we will need to show in the final result.
- Within the CTE, create a column ````ranked```` which shows how early each food was ordered. ````DENSE_RANK()```` assigns the ranking follwoing ````ORDER BY sales.order_date ASC````, hence the earlier food orderd gets ranked higher.
- ````PARTITION BY```` ensures the ranking is done separately for each customer.

**Answer:**

|customer_id|order_date|product_name|
|-----------|----------|------------|
|A          |2021-01-01|curry       |
|A          |2021-01-01|sushi       |
|B          |2021-01-01|curry       |
|C          |2021-01-01|ramen       |

- Customer A ordered both curry and sushi on during their first visit.
- Customer B ordered sushi on their first visit.
- Customer C ordered ramen on their first visit.

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
WITH sales_count AS (
	SELECT
		menu.product_id,
		menu.product_name,
		COUNT(*) AS unit_sold
	FROM
		menu
	LEFT JOIN sales
		ON sales.product_id = menu.product_id
	GROUP BY
		menu.product_id,
		menu.product_name
),

sales_count_ranking AS (
	SELECT
		sales_count.product_id,
		sales_count.product_name,
		sales_count.unit_sold,
		DENSE_RANK() OVER (
			ORDER BY sales_count.unit_sold DESC
		) AS ranking
	FROM
		sales_count
)

SELECT
	product_id,
	product_name,
	unit_sold
FROM
	sales_count_ranking
WHERE
	ranking = 1;
````

**Steps:**
- Create a CTE ````sales_count```` to and calculate how many units each food was sold using ````COUNT````.
- Create another CTE ````sales_count_ranking```` and rank the sales of each food using ````DENSE_RANK()````.
- Use ````ORDER BY sales_count.unit_sold DESC```` so that the food with the higher sales is ranked first.
- This approach accounts for the case where multiple foods share the top-selling spot. For example, both sushi and ramen have 10 unit sold, while curry has 8 units sold.

**Answer:**

|product_id|product_name|unit_sold|
|----------|------------|---------|
|3         |ramen       |8        |

- Ramen is the most popular food, with 8 units sold.

To see the sales for other foods, simply run:

````sql
SELECT * FROM sales_count;
````
Output:

|product_id|product_name|unit_sold|
|----------|------------|---------|
|1         |sushi       |3        |
|2         |curry       |4        |
|3         |ramen       |8        |

***

**5. Which item was the most popular for each customer?**

````sql
WITH orders_by_customer AS (
	SELECT
		sales.customer_id,
		menu.product_name,
		COUNT(*) AS unit_sold
	FROM
		sales
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
	GROUP BY
		sales.customer_id,
		menu.product_name
),

preference_ranking AS (
	SELECT
		customer_id,
		product_name,
		unit_sold,
		DENSE_RANK() OVER (
			PARTITION BY customer_id
			ORDER BY unit_sold DESC
		) AS ranking
	FROM
		orders_by_customer
)

SELECT
	customer_id,
	product_name,
	unit_sold
FROM
	preference_ranking
WHERE
	ranking = 1;
````

**Steps:**
- Create a CTE ````orders_by_customer```` and calculate how many units each food is ordered by each customer using ````COUNT````.
- Create another CTE ````preference_ranking```` and rank the ordering frequency of each food by each customer using ````DENSE_RANK()````.
- Use ````ORDER BY unit_sold DESC```` so that the food with the higher sales is ranked first.

**Answer:**

|customer_id|product_name|unit_sold|
|-----------|------------|---------|
|A          |ramen       |3        |
|B          |curry       |2        |
|B          |sushi       |2        |
|B          |ramen       |2        |
|C          |ramen       |3        |

- Customer A's favourite is ramen.
- Customer B's favourites are curry, sushi and ramen.
- Customer C's favourite is ramen.

To see the preference data for each customer, run:

````sql
SELECT * FROM preference_ranking;
````
Output:

|customer_id|product_name|unit_sold|ranking|
|-----------|------------|---------|-------|
|A          |ramen       |3        |1      |
|A          |curry       |2        |2      |
|A          |sushi       |1        |3      |
|B          |curry       |2        |1      |
|B          |sushi       |2        |1      |
|B          |ramen       |2        |1      |
|C          |ramen       |3        |1      |

***

**6. Which item was purchased first by the customer after they became a member?**

````sql
WITH member_orders AS (
	SELECT
		members.customer_id,
		sales.product_id,
		DENSE_RANK() OVER (
			PARTITION BY members.customer_id
			ORDER BY sales.order_date ASC
		) AS ranked
	FROM
		members
	INNER JOIN sales
		ON sales.customer_id = members.customer_id 
		AND sales.order_date > members.join_date
)

SELECT
	member_orders.customer_id,
	menu.product_name
FROM
	member_orders
INNER JOIN menu
	ON menu.product_id = member_orders.product_id
WHERE
	member_orders.ranked = 1
ORDER BY
	member_orders.customer_id;
````
**Steps:**

- Create a CTE ````member_orders```` to store the ````product_id```` of their order after becoming a member.
- Use ````INNER JOIN```` and````sales.order_date > members.join_date```` to ensure the data stored is order from after the customer joined the membership.

**Answer:**

|customer_id|product_name|
|-----------|------------|
|A          |ramen       |
|B          |sushi       |

- Customer A ordered ramen after becoming a member.
- Customer B ordered sushi after becoming a member.

***

**7. Which item was purchased just before the customer became a member?**

````sql
WITH pre_member_order AS (
	SELECT
		members.customer_id,
		sales.order_date,
		sales.product_id,
		DENSE_RANK() OVER (
			PARTITION BY members.customer_id
			ORDER BY sales.order_date DESC
		) AS rev_ranked
	FROM
		members
	INNER JOIN sales
		ON sales.customer_id = members.customer_id 
		AND sales.order_date < members.join_date
)

SELECT
	pre_member_order.customer_id,
	menu.product_name
FROM
	pre_member_order
INNER JOIN menu
	ON menu.product_id = pre_member_order.product_id
WHERE
	rev_ranked = 1
ORDER BY
	pre_member_order.customer_id ASC;
````

**Steps:**

- Create a CTE ````pre_member_order```` which stores all member's orders before they become a member with ````sales.order_date < members.join_date````.
- Use ````ORDER BY sales.order_date DESC```` so that the latest order for each customer before they became a member is on top.
- Use ````DENSE_RANK()```` to rank the food orders by date as ````rev_ranked````, so that we can coveniently filter and retrieve using ````rev_ranked = 1````.

**Answer:**

|customer_id|product_name|
|-----------|------------|
|A          |sushi       |
|A          |curry       |
|B          |sushi       |

- Customer A ordered both sushi and curry just before becoming a member.
- Customer B ordered sushi just before becoming a member.

***

**8. What is the total items and amount spent for each member before they became a member?**

````sql
WITH pre_member_order AS (
	SELECT
		members.customer_id,
		sales.order_date,
		sales.product_id
	FROM
		members
	INNER JOIN sales
		ON sales.customer_id = members.customer_id 
		AND sales.order_date < members.join_date
)

SELECT
	pre_member_order.customer_id,
	COUNT(*) AS item_purchased,
	SUM(menu.price) AS total_price
FROM
	pre_member_order
JOIN menu
	ON menu.product_id = pre_member_order.product_id
GROUP BY
	pre_member_order.customer_id
ORDER BY
	pre_member_order.customer_id ASC;
````
**Steps:**

- Create a CTE ````pre_member_order```` which stores all member's orders before they become a member with ````sales.order_date < members.join_date````.
- Use ````COUNT(*)```` to count the total number of items ordered.
- Use ````SUM(menu.price)```` to sum up the prices of each order.

**Answer:**

|customer_id|item_purchased|total_price|
|-----------|--------------|-----------|
|A          |2             |25         |
|B          |3             |40         |

- Customer A ordered 2 items for the price of $25 before becoming a member.
- Customer B ordered 3 items for the price of $40 before becoming a member.

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

````sql
SELECT
	sales.customer_id,
	SUM(CASE
		WHEN menu.product_name = "sushi" THEN menu.price * 2
		ELSE menu.price
		END) * 10 AS points
FROM
	sales
INNER JOIN menu
	ON menu.product_id = sales.product_id
GROUP BY
	sales.customer_id;
````

**Steps:**

- Use ````SUM```` to add up the price of all orders for each customer.
- Use ````WHEN menu.product_name = "sushi" THEN menu.price * 2```` since sushi has a 2x multiplier.
- Use ````SUM(...) * 10```` to multiply the sum of prices by 10 as $1 = 10 points.

**Answer:**

|customer_id|points|
|-----------|------|
|A          |860   |
|B          |940   |
|C          |360   |

- Customer A has 860 points.
- Customer B has 940 points.
- Customer C has 360 points.

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

````sql
WITH first_week AS (
	SELECT
		members.customer_id,
		members.join_date,
		DATE_ADD(members.join_date, INTERVAL 6 DAY) AS end_week
	FROM
		members
)

SELECT
	sales.customer_id,
	SUM(
		CASE
			WHEN sales.order_date BETWEEN first_week.join_date AND first_week.end_week
				THEN menu.price * 2
			WHEN menu.product_name = "sushi"
				THEN menu.price * 2
			ELSE
				menu.price
			END
	) * 10 AS points
FROM
	sales
INNER JOIN first_week
	ON first_week.customer_id = sales.customer_id
INNER JOIN menu
	ON sales.product_id = menu.product_id
WHERE
	sales.order_date <= "2021-01-31"
GROUP BY
	sales.customer_id
ORDER BY
	sales.customer_id;
````
**Steps:**
- Create a CTE ````first_week```` to store the start and end of the first week of each customer's membership.
- Use ````DATE_ADD```` and ````INTERVAL 6 DAY```` to calculate the end of the first week of membership, namely 6 days after becoming a member.
- Use ````SUM```` to calculate the amount spent before January 2021, denoted by ````sales.order_date <= "2021-01-31"````. Use ````CASE WHEN```` to apply specific multipliers: 2x for any food within the first week of membership, otherwise only 2x for sushi.

**Answer:**

|customer_id|points|
|-----------|------|
|A          |1370  |
|B          |820   |

- Customer A has 1370 points by the end of January 2021.
- Customer B has 820 points by the end of January 2021.

***

### Bonus Questions and Solutions

**1. Join All The Things**

**Recreate the following table with: customer_id, order_date, product_name, price, member(Y/N)**

````sql
SELECT
	sales.customer_id,
	sales.order_date,
	menu.product_name,
	menu.price,
	CASE
	WHEN sales.order_date >= members.join_date
		THEN 'Y'
	ELSE
		'N'
	END AS member
FROM
	sales
LEFT JOIN members
	ON members.customer_id = sales.customer_id
INNER JOIN menu
	ON menu.product_id = sales.product_id
ORDER BY
	sales.customer_id;
````

- Use ````CASE WHEN sales.order_date >= members.join_date```` to set the ````member```` status columnn to 'Y' if ````order_date```` is at or after ````members.join_date````.
- Otherwise, set ````member```` status to 'N', accounting for cases where the order is made before becoming a member or the customer is never a member.

**Answer:**

|customer_id|order_date|product_name|price|member|
|-----------|----------|------------|-----|------|
|A          |2021-01-01|sushi       |10   |N     |
|A          |2021-01-01|curry       |15   |N     |
|A          |2021-01-07|curry       |15   |Y     |
|A          |2021-01-10|ramen       |12   |Y     |
|A          |2021-01-11|ramen       |12   |Y     |
|A          |2021-01-11|ramen       |12   |Y     |
|B          |2021-01-01|curry       |15   |N     |
|B          |2021-01-02|curry       |15   |N     |
|B          |2021-01-04|sushi       |10   |N     |
|B          |2021-01-11|sushi       |10   |Y     |
|B          |2021-01-16|ramen       |12   |Y     |
|B          |2021-02-01|ramen       |12   |Y     |
|C          |2021-01-01|ramen       |12   |N     |
|C          |2021-01-01|ramen       |12   |N     |
|C          |2021-01-07|ramen       |12   |N     |

***

**2. Rank All The Things**

**Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.**

**Create a table with: customer_id, order_date, product_name, price, member(Y/N), ranking, where ranking is the ranking of food item prices in descendinh order for each customer after joining the loyalty programme**

````sql
WITH customer_data AS (
	SELECT
		sales.customer_id,
		sales.order_date,
		menu.product_name,
		menu.price,
		CASE
		WHEN sales.order_date >= members.join_date
			THEN 'Y'
		ELSE
			'N'
		END AS member
	FROM
		sales
	LEFT JOIN members
		ON members.customer_id = sales.customer_id
	INNER JOIN menu
		ON menu.product_id = sales.product_id
	ORDER BY
		sales.customer_id
)

SELECT
	*,
	CASE
	WHEN member = 'N'
		THEN NULL
	ELSE
		DENSE_RANK() OVER (
			PARTITION BY customer_id, member
			ORDER BY order_date
		)
	END AS ranking
FROM
	customer_data;
````

**Steps:**
- Create a CTE ````customer_data```` that tracks member ship status as ````member````.
- Set ````ranking```` column to ````NULL```` if ````member```` is 'N'.
- Else, for ````member```` is 'Y', rank the order by price using ```` DENSE_RANK()```` to find the most expensive food by each member in the loyalty programme.
- Note: It is important to use ````PARTITION BY customer_id, member```` to avoid ranking rows where ````member```` is ````NULL````.

**Answer:**

|customer_id|order_date|product_name|price|member|ranking|
|-----------|----------|------------|-----|------|-------|
|A          |2021-01-01|sushi       |10   |N     |NULL   |
|A          |2021-01-01|curry       |15   |N     |NULL   |
|A          |2021-01-07|curry       |15   |Y     |1      |
|A          |2021-01-10|ramen       |12   |Y     |2      |
|A          |2021-01-11|ramen       |12   |Y     |3      |
|A          |2021-01-11|ramen       |12   |Y     |3      |
|B          |2021-01-01|curry       |15   |N     |NULL   |
|B          |2021-01-02|curry       |15   |N     |NULL   |
|B          |2021-01-04|sushi       |10   |N     |NULL   |
|B          |2021-01-11|sushi       |10   |Y     |1      |
|B          |2021-01-16|ramen       |12   |Y     |2      |
|B          |2021-02-01|ramen       |12   |Y     |3      |
|C          |2021-01-01|ramen       |12   |N     |NULL   |
|C          |2021-01-01|ramen       |12   |N     |NULL   |
|C          |2021-01-07|ramen       |12   |N     |NULL   |
