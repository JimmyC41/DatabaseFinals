-- Write an SQL view that shows the suburbs where the most customers live.
create or replace view suburbs(suburb, ncust) as
select lives_in, count(*)
from Customers
;

create or replace view Q1(suburb, ncust) as
select *
from suburbs
where ncust = (select max(ncust) from suburbs)
;