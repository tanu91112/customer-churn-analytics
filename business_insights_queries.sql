-- ============================================
-- Customer Analytics - Business Insights Queries
-- Description: SQL queries to analyze customer behavior,
-- revenue patterns, segmentation, and business insights
-- ============================================


-- Q1: Analyze revenue contribution by gender
SELECT 
    gender, 
    SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;


-- Q2: Identify customers who used discounts but still spent above average
SELECT 
    customer_id, 
    purchase_amount 
FROM customer 
WHERE discount_applied = 'Yes' 
AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);


-- Q3: Top 5 products with highest average review rating
SELECT 
    item_purchased, 
    ROUND(AVG(review_rating::numeric), 2) AS avg_product_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_product_rating DESC
LIMIT 5;


-- Q4: Compare average purchase amount by shipping type
SELECT 
    shipping_type, 
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- Q5: Compare spending behavior of subscribed vs non-subscribed customers
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


-- Q6: Top 5 products with highest discount usage percentage
SELECT 
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 
    2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


-- Q7: Segment customers based on purchase frequency
WITH customer_type AS (
    SELECT 
        customer_id, 
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT 
    customer_segment, 
    COUNT(*) AS number_of_customers
FROM customer_type 
GROUP BY customer_segment;


-- Q8: Top 3 most purchased products within each category
WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT 
    item_rank,
    category, 
    item_purchased, 
    total_orders
FROM item_counts
WHERE item_rank <= 3;


-- Q9: Analyze subscription behavior of repeat buyers
SELECT 
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- Q10: Revenue contribution by age group
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;


-- Q11: Customer retention distribution
SELECT 
    previous_purchases,
    COUNT(*) AS customer_count
FROM customer
GROUP BY previous_purchases
ORDER BY previous_purchases;


-- Q12: Percentage revenue contribution by category
SELECT 
    category,
    SUM(purchase_amount) AS revenue,
    ROUND(
        100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 
    2) AS percentage_contribution
FROM customer
GROUP BY category
ORDER BY revenue DESC;