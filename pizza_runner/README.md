# 🍕 Case Study #2 Pizza Runner

<img src="https://user-images.githubusercontent.com/81607668/127271856-3c0d5b4a-baab-472c-9e24-3c1e3c3359b2.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Task Summary](#task-summary)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- Questions and Solutions
	- Data Cleaning and Transformation
	- A. [Pizza Metrics](pizza-metrics)
	- B. [Runner and Customer Experience](runner-and-customer-experience)
	- C. [Ingredient Optimisation](ingredient-optimisation)
	- D. [Pricing and Ratings](pricing-and-ratings)
	- E. [Bonus DML Challenges](bonus-dml-challenges)

## Task Summary
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

### Entity Relationship Diagram
![Pizza Runner](https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/78099a4e-4d0e-421f-a560-b72e4321f530)

## Questions and Solutions

#### Table: ```customer_orders```

**Before:**

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

The ```customer_orders``` contains 