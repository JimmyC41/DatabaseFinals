-- Write an SQL view that shows customers who have the same name, and a list of
-- customer ids for eahc person with that name.

create or replace view people(name, ids) as
select given ||' '|| family as name, id
from Customers
order by name
;

create or replace view q2(name, ids) as
select name, string::agg(id::text,',',order by id)
from people
group by name
having count(id) > 1
;