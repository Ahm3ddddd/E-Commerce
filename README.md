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
