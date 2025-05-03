-- Write an SQL view that gives information about the most recently sold
-- properties.

create or replace view Q1(date,price,type) as
select p.sold_date, p.sold_price, p.ptype
from Properties p
where p.sold_date is not null and p.sold_price is not null
order by p.sold_date desc, p.sold_price asc
;