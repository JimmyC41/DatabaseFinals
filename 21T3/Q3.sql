-- Write an SQL view that gives the cheapest unsold house(s).

create or view properties(id,price,street,suburb) as
select p.id, p.list_price, s.name, s.suburb
from Streets s
join Properties as p on p.street = s.id
join Suburbs as su on su.id = s.suburb
where p.sold_date is null
;

create or view q3(id, price, street, suburb) as
select *
from view_properties v1
where price = (select min(price)
                from view_properties v2)
;