-- Write an SQL view that finds the horse (or horses) that have won the most
-- Group 1 races.

create or replace view win_info(horse, n_wins) as
select h.name, count(*)
from Horses h
join Runners as ru on ru.horse = h.id
join Races as ra on ra.id = ru.race
where ra.level = 1
;

create or replace view q1(horse) as
select horse
from win_info
where n_wins = (select max(n_wins) from win_info)
;

