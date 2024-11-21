--задание 1
--задание решила без оконных функций, через группировку и агрегатную функцию
select s."SHOPNUMBER", s."CITY", s."ADDRESS",
    sum(sa."QTY") AS SUM_QTY,
    sum(sa."QTY" * g."PRICE") AS SUM_QTY_PRICE
from shops s
join sales sa on s."SHOPNUMBER" = sa."SHOPNUMBER" 
join goods g on sa."ID_GOOD" = g."ID_GOOD" 
where sa."DATE" = '2016-01-02'
group by s."SHOPNUMBER" , s."CITY" , s."ADDRESS" 

--задание 2
--доля продаж на дату считается как сумма смтоимости товаров категории чистота на дату делить сумма по сумме по датам
--это реализовано через оконную функцию и через джойны всех 3 таблиц 
select sa."DATE" as DATE_, s."CITY" ,
    sum(g."PRICE" * sa."QTY") / sum(sum(g."PRICE" * sa."QTY")) over (PARTITION BY sa."DATE") as SUM_SALES_REL
from sales sa
join shops s on sa."SHOPNUMBER" = s."SHOPNUMBER" 
join goods g on sa."ID_GOOD" = g."ID_GOOD" 
where g."CATEGORY" = 'ЧИСТОТА'
group by sa."DATE" , s."CITY" 

--задание 3
--в cte с помощью рангов присваиваю записям ранги по сумме кол-ва проданных товаров в каждом магазине и в каждую дату 
--затем в оснвоном запросе получаю необходимые стобцы и фильтрую по рангам топ-3
with cte as (
    select sa."DATE" as DATE_, sa."SHOPNUMBER" as SHOPNUMBER, sa."ID_GOOD" as ID_GOOD,
        ROW_NUMBER() OVER (PARTITION BY sa."DATE", sa."SHOPNUMBER" order by sum(sa."QTY") desc) as rank
from sales sa
join goods g on sa."ID_GOOD" = g."ID_GOOD"
join shops s on sa."SHOPNUMBER" = s."SHOPNUMBER" 
group by sa."DATE" , sa."SHOPNUMBER", sa."ID_GOOD"
)
select 
    DATE_,
    SHOPNUMBER,
    ID_GOOD
from cte
where rank <= 3

--задание 4
--поскольку у нас всего 3 уникальных даты покупок, то в самой наименьшей - 2016.01.01 будут проставлены нули
--также, так как нельзя использовать оконную функцию в другой, запрос будет состоять из cte, где считаются суммарные продажи по магазину и категории в СПб
--а в оснвоном запросе будет реализована фкнкция с временным лагом 1 и значением 0, которое используется если предыдущих данных нет
   
 with cte as (select s."DATE" as DATE_,
    s."SHOPNUMBER" ,
    g."CATEGORY" ,
    sum(sum(s."QTY" * g."PRICE")) OVER (PARTITION BY s."SHOPNUMBER" , g."CATEGORY" ORDER BY s."DATE") as SALES
from sales s
join shops sh on s."SHOPNUMBER" = sh."SHOPNUMBER" 
join goods g on s."ID_GOOD" = g."ID_GOOD" 
where sh."CITY" = 'СПб'
group by DATE_, s."SHOPNUMBER" , g."CATEGORY" 
)
 select DATE_, cte."SHOPNUMBER", cte."CATEGORY",
lag(cte.SALES, 1, 0) OVER (PARTITION BY cte."SHOPNUMBER", cte."CATEGORY" ORDER BY DATE_) as PREV_SALES
from cte
order by DATE_

    
