-- intermediate questions
--the total revenue per seller
select seller_id, sum(price) as total_revenue
from order_items 
group by 1 order by sum(price) desc;

--the number of orders per customer
select customer_id, count(order_id) as order_count
from orders
group by customer_id
order by count(order_id) desc;

--the top 5 most frequently purchased product categories
select p.product_category_name, count(oi.product_id) as product_count
from products p
join order_items oi on oi.product_id = p.product_id
group by 1 
order by count(oi.product_id) desc
limit 5;

--the average freight cost per order status
select o.order_status, sum(oi.freight_value)
from orders o
join order_items oi on oi.order_id = o.order_id
group by 1
order by sum(oi.freight_value) desc;

--the customers who have spent more than the average order value
select o.customer_id, sum(oi.price) as order_value
from orders o
join order_items oi on oi.order_id = o.order_id
group by 1
having sum(oi.price) > (select avg(oi.price))
order by sum(oi.price) desc;

--the sellers whose average product price is above the overall average product price
with average_product_price as (
select seller_id, avg(price) over(partition by(seller_id)) as avg_product_price_per_seller
from order_items
)
select seller_id, avg_product_price_per_seller
from average_product_price
group by 1,2
having avg_product_price_per_seller>(select avg(price) from order_items)
order by 2 desc;

--Determine the percentage of positive reviews (score >= 4) for each seller

select oi.seller_id, count(case when ore.review_score>= 4 then 1 end)*100  / count(ore.review_score)
from order_reviews ore
join order_items oi on oi.order_id = ore.order_id
group by 1;

--the top 3 customers who have spent the most, including their cities
select c.customer_id, c.customer_city, sum(op.payment_value) as total_spent
from customers c
join orders o on o.customer_id = c.customer_id
join order_payments op on op.order_id = o.order_id
group by 1, 2
order by sum(op.payment_value) desc
limit 3;

--the most popular payment method and how many times it was used
select payment_type, count(payment_type) ,rank() over(order by count(payment_type)desc)
from order_payments
group by 1
limit 1;

--customers who placed multiple orders but had at least one late delivery
with multiple_orders as (
select customer_id, count(order_id) as order_count, order_status, order_delivered_customer, order_estimated_delivery_date
from orders
where order_delivered_customer > order_estimated_delivery_date
group by 1,3,4,5
)
select customer_id, order_count, order_status
from multiple_orders
where order_count > 1
group by 1,2,3;


--stored procedure(getting order details)
CREATE OR REPLACE PROCEDURE order_details(IN order_id TEXT)
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
--testing the stored procedure
call order_details('e481f51cbdc54678b7cc49136f2d6af7');


--stored function(average seller's score)
create or replace function average_seller_score(seller_id_input text)
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
-- testing function
select average_seller_score('001cca7ae9ae17fb1caed9dfb1094831');


-- categorizing orders based on delivery time
select order_id, order_delivered_customer, order_estimated_delivery_date,
case
    when order_estimated_delivery_date > order_delivered_customer then 'early'
	when order_estimated_delivery_date < order_delivered_customer then 'late'
	when order_estimated_delivery_date = order_delivered_customer then 'on time'
	else 'unkown'
	end as delivery_status
from orders;

--creating a trigger that denies negative payments
create or replace function preventNegativePyments()
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

--Determine different customers from the same city
select c1.customer_id as customer_1,
    c2.customer_id as customer_2
	c1.customer_city as city
from customers c1
join customers c2 on c1.customer_city = c2.customer_city and c1.customer_id <> c2.customer_city
order by c1.customer_city;


