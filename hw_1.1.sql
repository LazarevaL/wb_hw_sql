--задание 1
select city, age, count(*) as buyers
from users 
group by city, age
order by buyers desc

--доп задание 1
select city, 
count(CASE WHEN age between 0 and 20 THEN 'young'
            WHEN age between 21 and 49 THEN 'adult'
            ELSE 'old'
       end)
from users 
group by city, age

--задание 2
select category, round(avg(price), 2)  as avg_price
from products 
where name like 'Hair%' or name like 'Home%'
group by category

