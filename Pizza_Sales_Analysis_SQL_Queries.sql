/* 

KPI's:
1. Total Revenue
2. Average Order value
3. Total Pizzas Sold
4. Total Orders
5. Average Pizzas Per Order

Charts Requirement:
1. Daily Trend for Total Orders
2. Hourly Trend for Total Orders
3. Percentage of Sales by Pizza Category
4. Percentage of Sales by Pizza Size
5. Total Pizzas Sold by Pizza Category
6. Top 3 Best Selling Pizzas
7. Bottom 3 Worst Selling Pizzas
8. Best Selling Pizza in Each Category
9. Month-over-Month Revenue Change

*/
--TOTAL REVENUE
select round(sum(total_price),2)as total_revenue from pizza_sales;

--AVERAGE ORDER VALUE
select round(sum(total_price)/count(distinct order_id),2) as avg_order_value from pizza_sales;

--TOTAL PIZZAS SOLD
select sum(quantity) as total_pizzas_sold from pizza_sales;

--TOTAL ORDERS
select count(distinct order_id) as total_orders from pizza_sales;

--AVERAGE PIZZAS PER ORDER
select cast(sum(quantity) as decimal(10,2))/count(distinct order_id) as avg_pizzas_per_order from pizza_sales;

--DAILY TREND
select datename(dw,order_date) as order_day, count(distinct order_id) as total_orders
from pizza_sales
group by datename(dw,order_date) order by total_orders;

--HOURLY TREND
select datepart(hour,order_time) as order_hours, count(distinct order_id) as total_orders
from pizza_sales
group by datepart(hour,order_time) order by order_hours;

-- % OF SALES BY PIZZA CATEGORY
select pizza_category, sum(total_price)*100 / (select sum(total_price) from pizza_sales) as percentage_of_total_sales
from pizza_sales
group by pizza_category order by percentage_of_total_sales desc;

-- % OF SALES BY PIZZA SIZE
select pizza_size, sum(total_price)*100 / (select sum(total_price) from pizza_sales) as percentage_of_total_sales
from pizza_sales
group by pizza_size order by percentage_of_total_sales desc;

--TOTAL PIZZAS SOLD BY CATEGORY
select pizza_category,sum(quantity) as total_pizzas_sold
from pizza_sales
group by pizza_category order by total_pizzas_sold desc;

--TOP 3 BEST SELLING PIZZAS
select top 3 pizza_name, sum(quantity) as total_pizzas_sold
from pizza_sales
group by pizza_name order by total_pizzas_sold desc;

--BOTTOM 3 WORST SELLING PIZZAS
select top 3 pizza_name, sum(quantity) as total_pizzas_sold
from pizza_sales
group by pizza_name order by total_pizzas_sold;

--BEST SELLING PIZZA IN EACH CATEGORY
with ranked as (
    select pizza_category,
           pizza_name,
           sum(quantity) as total_pizzas_sold,
           rank() over (partition by pizza_category order by sum (quantity) desc) as rnk
    from pizza_sales
    group by pizza_category, pizza_name
)
select pizza_category, pizza_name, total_pizzas_sold
from ranked
where rnk = 1;

--MONTH-OVER-MONTH REVENUE CHANGE

with monthly as (
    select month(order_date) as order_month,
           sum(total_price) as revenue
    from pizza_sales
    group by month(order_date)
)
select order_month,
       round(revenue, 2) as revenue,
       round(revenue - lag(revenue) over (order by order_month), 2) as change_vs_previous_month
from  monthly
order by order_month;