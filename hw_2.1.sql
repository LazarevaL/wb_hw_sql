--задание 1
--для расчета разницы между датой заказа и датой доставкии использую cte и также фильтрую по статусу заказа Approved, далее в основном запросе джойню по customer_id и нахожу 
--единственную запись через сортировку и лимит, потому что в задании указано вывести одну запись, хотя пользователей с наибольшим временем ожидания несколько
with cte as (select customer_id, max(shipment_date - order_date) as max_data
from orders_new_3 where order_status = 'Approved' group by customer_id)
select *
from customers_new_3 cn inner join cte on cn.customer_id = cte.customer_id 
order by max_data desc
limit 1

--задание 2
--в cte происходит расчет дополнительных указанных параметров, группируя по customer_id
--затем табличка джойнится к customers_new_3 с условияем выбора максимального заказа
with cte as(SELECT customer_id, avg(shipment_date - order_date) as avg_delivery, 
sum(order_ammount) as sum_ammount, 
count(*) as orders
from orders_new_3 
group by customer_id)

select *
from customers_new_3 cn join cte on cte.customer_id = cn.customer_id
where orders = (select max(orders) from cte)
order by sum_ammount desc

--задание 3
--считаю, что заказы с задержкой 5 дней должны быть в статусе Approved, а отмененные - Cancel
--в двух cte считаю кол-ва заказов и их сумму, затем, используя left_join и coalesce для замены null на 0, присоединяю таблицы к customer и считаю суммарные показатели
with days_5 as(SELECT customer_id,  
sum(order_ammount) as sum_ammount_5days, 
count(*) as orders_5days
from orders_new_3 
where shipment_date - order_date>5 and order_status='Approved'
group by customer_id),

canceled as(SELECT customer_id,  
sum(order_ammount) as sum_ammount_canceled, 
count(*) as orders_canceled
from orders_new_3 
where order_status='Cancel'
group by customer_id)

select name, coalesce(orders_5days, 0) as orders_5days, 
coalesce(orders_canceled,0) as orders_canceled, 
(coalesce(sum_ammount_5days,0) + coalesce(sum_ammount_canceled,0)) as total_sum
from customers_new_3 cn 
left join days_5 on days_5.customer_id = cn.customer_id
left join canceled on canceled.customer_id = cn.customer_id
where orders_5days > 0 or orders_canceled > 0 
order by total_sum desc