--задание 1
--в total нахожу сумму продаж по категориям, в product сумму продаж по продуктам
--в основном запросе джойню таблички по product_category и далее фильтрую, находя максимальную сумму по продуктам в подзапросе из product
with total as(
select products_3.product_category, sum(order_ammount) as sum_category
from orders_2 
join products_3 on products_3.product_id = orders_2.product_id  
group by products_3.product_category
order by sum_category desc
),
product as (select product_name, product_category, sum(order_ammount) as sum_product
from orders_2 
join products_3 on products_3.product_id = orders_2.product_id 
group by product_name, product_category
order by sum_product desc)

select total.product_category, total.sum_category, prod.product_name
from total 
join product prod
on total.product_category = prod.product_category
where prod.sum_product in (select max(sum_product) from product where product_category = total.product_category )
order by total.sum_category desc
