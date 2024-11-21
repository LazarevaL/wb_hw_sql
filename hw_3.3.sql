INSERT INTO query (searchid," year"," month"," day"," userid"," devicetype"," deviceid"," query","ts") VALUES
	 ('1','2024','10','23','1','android','1','куп','10/23/2024 10:11'),
	 ('2','2024','10','23','1','android','1','купить','10/23/2024 10:11'),
	 ('3','2024','10','23','1','android','1','купить джинсы','10/23/2024 10:11'),
	 ('4','2024','10','25','3','android','2','ру','10/23/2024 23:12'),
	 ('5','2024','10','25','3','android','2','рубаш','10/23/2024 23:12'),
	 ('6','2024','10','25','3','android','2','рубашка','10/23/2024 23:12'),
	 ('7','2024','10','25','3','android','2','сум','10/23/2024 23:17'),
	 ('8','2024','10','26','4','android','6','за','10/26/2024 23:17'),
	 ('9','2024','10','26','4','android','6','зар','10/26/2024 23:17'),
	 ('10','2024','10','26','4','android','6','зарядк','10/26/2024 23:17');
INSERT INTO query (searchid," year"," month"," day"," userid"," devicetype"," deviceid"," query","ts") VALUES
	 ('11','2024','10','26','4','android','6','usb','10/26/2024 23:20'),
	 ('12','2024','10','27','7','android','3','ла','10/27/2024 11:20'),
	 ('13','2024','10','27','7','ios','3','ламп','10/27/2024 11:20'),
	 ('14','2024','10','27','7','ios','3','лампочка','10/27/2024 11:21'),
	 ('15','2024','10','27','7','ios','3','лампа','10/27/2024 11:21'),
	 ('16','2024','10','23','1','android','1','ке','10/23/2024 23:45'),
	 ('17','2024','10','23','1','android','1','кеп','10/23/2024 23:46'),
	 ('18','2024','10','23','1','android','1','кепка','10/23/2024 23:46');



--в подзапросе queries сопоставляю каждой записи поля query и ts следующей записи по юзеру и девайсу
with queries as (
 select *, 
lead(ts) over (PARTITION BY query." userid" , query." deviceid"  order by ts) as next_ts,
lead(query." query") over (PARTITION BY query." userid", query." deviceid" order by ts) as next_query
from query
),
--в подзапросе count_diffs считаю разницу между временем текущей записи и следующей в секундах, а также разницу длины запроса
count_diffs as (
select *, coalesce (EXTRACT(epoch from (next_ts - ts)),0) as diff_seconds,
coalesce((LENGTH(next_query) - LENGTH(queries." query")),0) as diff_query
from queries),
--в подзапросе final генерирую поле is_final по логике из задания: 1 если следующий записи не существует (она null) и при этом разница в секундах 0,
-- то есть это последний запрос
-- также 1 если разница в секундах между текущим и следующим запросом больше 180 секунд
-- 2 если разница в секндах больше 60 И следующий запрос короче, то есть diff_query < 0
 final as (select searchid, count_diffs." year", count_diffs." month", count_diffs." day" ,
 count_diffs." userid", ts, count_diffs." devicetype", count_diffs." deviceid", count_diffs." query" ,
 case 
 when next_ts is null and diff_seconds = 0 then 1 
 when  diff_seconds > 180 then 1 
 when (diff_seconds > 60 and diff_query < 0) then 2  
 else 0 
 end as is_final
 from 
    count_diffs)
 --в освноном запросе выбираю все записи и фильтрую по знаечниям типа девйса и поля is_final
  select * from final
    where final." devicetype" = 'android' and is_final = 1 or is_final = 2
