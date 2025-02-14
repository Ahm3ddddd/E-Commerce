# E-Commerce Data analysis using PostgreSQL

# Project overview
- This project explores an e-commerce database using PostgreSQL, showcasing various SQL skills such as joins, stored procedures, triggers, transactions, and analytical queries. The dataset includes different tables such as customers, orders, payments, reviews, products, and sellers, allowing for in-depth analysis of customer behavior, sales trends, and order fulfillment.
# SQL Techniques used
**Data extraction and analysis:**
- Used JOINs (inner joins, self joins, CTEs, subqueries) to analyze customer behavior and spending
- Implemented CASE WHEN to classify orders based on delivery performance
**Stored procedures and functions:**
- Created a stored procedure to retrieve orders details
- Developed a stored function to calculate the average review score per seller
**Triggers and data integrity:**
- Implemented a trigger to prevent negative payments from being inserted into the database

# Database schema
The database consists of the following tables:
- **Customers:** Customer details (ID, city, state, etc.)
- **Orders:** Order information (status, purchase date, delivery info)
- **Order_items:** Products purchased in each order
- **Order_payments:** Payment details (type, amount, installments)
- **Order_reviews:** Customer reviews for orders
- **Products:** Product information (category, dimensions, weight)
- **Sellers:** Seller details (location, ID)

# SQL Queries
Self Join: Finding Customers in the Same City
- SELECT c1.customer_id AS customer_1, 
       c2.customer_id AS customer_2, 
       c1.customer_city
FROM customers c1
JOIN customers c2 
    ON c1.customer_city = c2.customer_city 
    AND c1.customer_id <> c2.customer_id
ORDER BY c1.customer_city;

CASE WHEN: Classifying Orders by Delivery Time:
- SELECT order_id,
       order_delivered_customer,
       order_estimated_delivery_date,
       CASE 
           WHEN order_delivered_customer < order_estimated_delivery_date THEN 'Early'
           WHEN order_delivered_customer = order_estimated_delivery_date THEN 'On Time'
           WHEN order_delivered_customer > order_estimated_delivery_date THEN 'Late'
           ELSE 'Unknown'
       END AS delivery_status
FROM orders;

Stored Procedure that gets order details:
- CREATE OR REPLACE PROCEDURE order_details(IN order_id TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    order_status TEXT;
    order_purchase_date DATE;
    payment_type TEXT;
    total_value NUMERIC;
BEGIN
    SELECT o.order_status, o.order_purchase_date, p.payment_type, SUM(p.payment_value)
    INTO order_status, order_purchase_date, payment_type, total_value
    FROM orders o
    JOIN order_payments p ON p.order_id = o.order_id
    GROUP BY o.order_id, o.order_status, o.order_purchase_date, p.payment_type;

    RAISE NOTICE 'Order ID: %, Status: %, Date: %, Payment: %, Total: %',
                 order_id, order_status, order_purchase_date, payment_type, total_value;
END;
$$;

Trigger that Prevents Negative Payment Values

- create or replace function preventNegativePyments()
returns trigger
language plpgsql
as $$
begin
    if new.payment_value < 0 then
	raise exception 'Payment value cannot be negative';
	end if;
	return new;
end;
$$;

create trigger PreventNegativePaymentTrigger
before insert on order_payments
for each row
execute function preventNegativePyments();

Stored Fuction that gets average seller's score

- create or replace function average_seller_score(seller_id_input text)
returns decimal(3,2)
language plpgsql
as $$
declare
    avg_score decimal(3,2);
begin
    select  avg(ore.review_score)
	into avg_score
	from order_items oi
	join order_reviews ore on oi.order_id = ore.order_id
	where oi.seller_id = seller_id_input;
	
    return avg_score;
end;
$$;

And other sql queries that uses (joins , cte , subqueries , 

