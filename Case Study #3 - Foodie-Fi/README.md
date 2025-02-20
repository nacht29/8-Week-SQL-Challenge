# 🥑 Case Study #3: Foodie-Fi

<img src="https://github.com/user-attachments/assets/c44b890c-c612-4cc5-bf96-edf4a472922a" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Data Analysis Questions](#data-analysis)

***

## Introduction

Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

***

## Entity Relationship Diagram

![Image](https://github.com/user-attachments/assets/e8470e56-d985-43cf-b3ad-f0073593e090)

**Table 1: ```plans```**

![Image](https://github.com/user-attachments/assets/f78b29f0-eff6-4ed1-950c-ccd9d5d61e28)

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their subscription, their plans are set to churn, and the price becomes null. However, their plan before churn remains effencitve until the end of the billing period.

---

**Table 2: ```subscriptions```**

![Image](https://github.com/user-attachments/assets/7724c354-fcde-4270-aabf-837fa31a9b2c)

Customer subscriptions show the exact date where their specific plan_id starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the start_date will be technically the day they decided to cancel their service.

***

<a id="data-analysis"></a>
## Data Analysis Questions

- [View questions and solutions](https://github.com/nacht29/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Data%20Analyst%20Questions/README.md)