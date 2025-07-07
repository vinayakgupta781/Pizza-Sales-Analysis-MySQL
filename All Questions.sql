-- Retrieve the total number of orders placed

SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

-- Calculate the toal revenue generated from pizza sales.
 
SELECT 
    SUM(quantity * price) AS total_revenue
FROM
    pizzas t1
        JOIN
    order_details t2 ON t1.pizza_id = t2.pizza_id;

-- Identity the highest-priced pizza

SELECT 
    t2.name, t1.price
FROM
    pizzas t1
        JOIN
    pizza_types t2 ON t1.pizza_type_id = t2.pizza_type_id
ORDER BY price DESC
LIMIT 1;
 
-- Identity the most common pizza size ordered.as

SELECT 
    t1.size, COUNT(*) AS order_count
FROM
    pizzas t1
        JOIN
    order_details t2 ON t1.pizza_id = t2.pizza_id
GROUP BY t1.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    t2.name, SUM(t3.quantity) AS total_quantity
FROM
    pizzas t1
        JOIN
    pizza_types t2 ON t1.pizza_type_id = t2.pizza_type_id
        JOIN
    order_details t3 ON t1.pizza_id = t3.pizza_id
GROUP BY t2.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    category, COUNT(t3.quantity) AS total_quantity
FROM
    pizza_types t1
        JOIN
    pizzas t2 ON t1.pizza_type_id = t2.pizza_type_id
        JOIN
    order_details t3 ON t2.pizza_id = t3.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day. 

SELECT 
    HOUR(order_time) AS hours, COUNT(*) AS order_count
FROM
    orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas. 

SELECT 
    category, COUNT(*)
FROM
    pizza_types
GROUP BY category;


-- group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        order_details t1
    JOIN orders t2 ON t1.order_id = t2.order_id
    GROUP BY order_date) AS t;


-- Determine the top 3 most ordered pizza names based on revenue.  

SELECT 
    t1.name, SUM(t3.quantity * t2.price) AS revenue
FROM
    pizza_types t1
        JOIN
    pizzas t2 ON t1.pizza_type_id = t2.pizza_type_id
        JOIN
    order_details t3 ON t2.pizza_id = t3.pizza_id
GROUP BY t1.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    t1.category,
    ROUND((SUM(t3.quantity * t2.price) / (SELECT 
                    SUM(t2.quantity * t1.price) AS total_sales
                FROM
                    pizzas t1
                        JOIN
                    order_details t2 ON t1.pizza_id = t2.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types t1
        JOIN
    pizzas t2 ON t1.pizza_type_id = t2.pizza_type_id
        JOIN
    order_details t3 ON t2.pizza_id = t3.pizza_id
GROUP BY t1.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.  

select dates, revenue,round(sum(revenue) 
over(order by dates),2) as total_revenue from
(select t4.order_date as dates,
round(sum(quantity*price),2) as revenue from pizza_types t1
join pizzas t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details t3
on t2.pizza_id = t3.pizza_id
join orders t4
on t3.order_id = t4.order_id
group by dates) as t;

-- determine the top 3 most ordered pizza types based on revenue for each pizza category

select categorys,names,revenue,ranks
from 
(select categorys,names,revenue,
rank() over(partition by categorys order by revenue desc) as ranks 
from
(select t1.category as categorys, t1.name as names,
sum(t3.quantity*t2.price) as revenue from pizza_types t1
join pizzas t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details t3
on t2.pizza_id = t3.pizza_id
group by categorys,names) as t) as tt
where ranks<=3;



  
