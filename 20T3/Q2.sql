-- Write an SQL view that report which group(s) have no albums
-- (at least not in the database).

create or replace view no_albums("group", albums) as
select g.name, count(*)
from Groups g
left join Albums as a on a.made_by = g.id
order by g.name
;

create or replace view Q2("group") as
select "group"
from no_albums
where albums = 0
;