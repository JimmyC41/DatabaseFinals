-- Write a PLpgSQL function that gives the average winnings for horses given 
-- by a partial name.

create or replace view total_winnings(id, name, total) as
select h.id, h.name, sum(ra.prize)
from Horses h
join Runners as ru on ru.horse = h.id
join Races as ra on ra.id = ru.race
where ru.finished = 1
group by h.id, h.name
;

create or replace view no_of_races(id, races) as 
select h.id, count(ra.prize)
from Horses h
join Runners as ru on ru.horse = h.id
join Races as ra on ra.id = ru.race
group by h.id
;

create or replace function q4(_input)
    return setof horse_winnings
as $$
declare
    tup horse_winnings;
begin
    for tup in
        select tw.name, tw.total / nr.races
        from total_winnings tw
        join no_of_races as nr on nr.id = tw.id
        where tw.name ~* _input
    loop
        return next tup
    end loop;
end;
$$ language plpgsql;