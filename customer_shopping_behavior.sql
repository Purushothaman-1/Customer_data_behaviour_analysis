show databases
use customer
select * from customer limit 20

-- Total revenue genarated by male vs female customers
SELECT gender , SUM(purchase_amount) from customer GROUP BY gender;

-- Which customers used a discount but still spent more than the average purchase amount
SELECT customer_id, purchase_amount FROM customer 
WHERE discount_applied = 'Yes' and purchase_amount>= (select avg(purchase_amount) from customer)

-- Which are the top 5 products with the highest average review rating
SELECT item_purchased as product, round(avg(review_rating),2) as Average_rating FROM customer
group by item_purchased order by avg(review_rating) desc limit 5

-- Compare the average Purcahse amount between standard and Express shipping
SELECT shipping_type, Round(AVG(purchase_amount),2)as Average from customer
Where shipping_type in ('Standard','Express')
group by shipping_type

-- Do Subscribed customer spend more? Compare average spend and total revenue between subscribers and non subscribers

SELECT subscription_status as subscribed,
count(customer_id) as total_customers,
round(avg(purchase_amount),2) as Average_spent,
sum(purchase_amount) as Total_revenue from customer
GROUP BY subscription_status

-- Which 5 products have the highest percentage of purchases with discounts applies

SELECT item_purchased, round(100*sum( CASE
 WHEN discount_applied ='Yes' THEN 1
 ELSE 0
 END)/count(*),2) as discount_rate 
from customer
group by item_purchased
order by discount_rate desc limit 5

-- Segemnt customers into New Returning and loyal based on their total number of previous purchases and show the count of each segment .
WITH customer_type as (
SELECT customer_id, previous_purchases, CASE
WHEN previous_purchases = 1 THEN 'New'
WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
ELSE 'Loyal'
END as customer_segment from customer
)
SELECT customer_segment, count(*) as 'Number of Customers' from customer_type GROUP  BY customer_segment

-- Top 3 most purchase products within each category

WITH item_counts as(
SELECT category, item_purchased, 
count(customer_id) as total_orders,
 ROW_NUMBER() over(partition by category order by count(customer_id) DESC)as item_rank from customer 
 group by category, item_purchased)

SELECT category,item_purchased,total_orders,item_rank from item_counts
WHERE item_rank <= 3 

-- Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe ?

SELECT subscription_status,count(*) as repeat_buyers  from customer where previous_purchases > 5 group by subscription_status

-- what is the revenue contribution of each age group

SELECT age_group,sum(purchase_amount) as Total_revenue from customer 
group by age_group 
order by Total_revenue desc