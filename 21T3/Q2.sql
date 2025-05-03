create or replace view q2(suburb,ptype,nprops) as
select s.suburb, p.ptype, count(*)
from Streets s
join Properties as p on p.street = s.id
where p.sold_date is null
group by s.suburb, p.ptype
;