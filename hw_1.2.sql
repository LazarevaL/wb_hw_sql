-- задание 1
-- для маркировки poor и rich использовала case как в задании 1.1, в таблице также есть продавцы, которые не подходят под эти категории, они остаются с пустым значением
--для подсчета категорий использую distinct, поскольку у селлера не может быть повторной регистрации в одной и той же категории
select seller_id,
    count(distinct category) as total_categ,
    avg(rating) as avg_rating,
    sum(revenue) as total_revenue,
    (case when (count(distinct category) > 1 and sum(revenue) > 50000) then 'rich'
        when count(distinct category) > 1 then 'poor'
        end) as seller_type
from sellers
where category <> 'Bedding'
group by seller_id
order by seller_id

-- задание 2
--за дату регистрации взяла минимальную дату у селлера независимо от категории поскольку это должна быть его самая первая регистрация на маркетплейсе 
--вычитание даты регистрации из сегодняшней даты и деление на 30 дней выдает результат с оруглением вниз, то есть в полных месяцах, 
--так что дополнительные преобразования не нужны. в задании указано что разница между максимальным и минимальным сроком доставки для всех неудачливы продавцов одна 
-- - ее отбор проходит в cte, далее в основном селекте считаются сроки и проверяется что seller_id входит в список бедных

with cte as (
	select
		seller_id,
		max(delivery_days) as max_delivery,
		min(delivery_days) as min_delivery
	from sellers
	where category <> 'Bedding' 
	group by seller_id
	having count(distinct category) > 1 and sum(revenue) <= 50000
)
select seller_id, 
	(CURRENT_DATE - min(date_reg))/30 as month_from_registration,
	(SELECT max(max_delivery) - min(min_delivery) FROM cte) as max_delivery_difference
from sellers
where seller_id in (select seller_id
        from cte)
group by seller_id
order by seller_id
        
-- задание 3
--в запросе использую встроенные функцию string_agg для соединения категорий, а также extract для фильтрации по году 2022
select seller_id, string_agg(distinct category, ' - ' order by category) as category_pair
from sellers
where extract(year from date_reg) = '2022' 
group by seller_id
having count(distinct category) = 2 and sum(revenue) > 75000