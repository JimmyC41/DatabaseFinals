-- Write an SQL view that gives information about the album(s) with the longest
-- total running time (sum of length of songs on the album).

create or replace album_times("group",album,year,total_time) as
select g.name, a.name, a.year, sum(s.length)
from Groups g
join Albums as a on a.made_by = g.id
join Songs as s on s.on_album = a.id
group by g.name, a.name. a.year
;

create or replace view Q1("group",album,year) as
select a1."group", a1.album, a1.year
from album_times a1
where a1.total_time = (select max(a2.total_time) from album_times a2)
;