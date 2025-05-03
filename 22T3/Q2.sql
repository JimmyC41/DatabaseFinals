-- Write an SQL view that finds race that only have mares running in them.

create or replace view q2(name, course, date) as
select ra.name, rc.name, m.run_on
from Horses h
join Runners as ru on ru.horse = h.id
join Races as ra on ra.id = ru.race
join Meetings as m on m.id = ra.part_of
join Racecourses as rc on rc.id = m.run_at
where h.gender = 'M'
;
