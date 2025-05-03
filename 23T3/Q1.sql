-- Write an SQL view that shows the age in years of the oldest participant(s)
-- across all FunRuns. Age is determined relative to the date on which the
-- FunRun is held.

create or replace view all_participants(person, age, event, held_on) as
select p.name, (e.held_on - p.d_o_b) / 365, e.name, e.held_on
from People p
join Participants as pa on pa.person_id = p.id
join Events as e on e.id = pa.event_id
;

create or replace view q1(person, age, event) as
select ap1.person, ap1.substr(age::text,1,4), ap1.held_on ||' '|| ap1.event
from all_participants ap1
where age = (select max(age)
            from all_participants ap2
            where ap2.event = ap1.event)
;