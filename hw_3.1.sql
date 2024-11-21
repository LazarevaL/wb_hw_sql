--задание 1
--в моем понимании задача звучит как вывести ВСЕХ острудников, указав для каждого имя самого высокооплачваемого по отделу
--максимальная зп в отделе, запрос без использования оконных функций. сначала в cte находим макс зп по отделу
--в основном запросе выбираем имя самого высокооплачиваемого сотрудника с помощью подзапроса
--лимит 1 добавлен на случай если есть несколько сотрудников с одинаковой максимальной зп
with cte as (
select industry, max(salary) as max_salary
from salary
group by industry
)
select s.first_name, s.last_name, s.salary, s.industry, 
       (select first_name
        from salary
        where industry = s.industry and salary = cte.max_salary
        limit 1) as name_ighest_sal
from salary s
join cte on cte.industry = s.industry

--минимальная зп в отделе идентично 
with cte as (
select industry, min(salary) as min_salary
from salary
group by industry
)
select s.first_name, s.last_name, s.salary, s.industry,
       (select first_name
        from salary
        where industry = s.industry and salary = cte.min_salary
        limit 1) as name_ighest_sal
from salary s
join cte on cte.industry = s.industry where s.industry = 'Architecture'

--максимальная зп по отделу с использованием first_value
--с оконной функцией запрос уменьшился в несколько раз, при выводе также добавилась сортировка 
select first_name, last_name, salary, industry,
first_value (first_name) over (partition by industry order by salary desc) as name_ighest_sal
from salary

--минимальная зп по отделу с использованием last_value почти полностью идентично, но в документации указано про параметры окна для, поэтому указываю 
--ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING - сравнивать  все значения в диапазоне группы по полю из partition by
select first_name, last_name, salary, industry,
last_value (first_name) over (partition by industry order by salary desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as name_ighest_sal
from salary
