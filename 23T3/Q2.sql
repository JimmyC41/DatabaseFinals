-- Write an SQL view that shows people who finished events in the fastest time.
-- The view should show all events and, for each event, give the people with the
-- lowest time to reach the final checkpoint. There may be one or more people
-- with the lowest time; if there are multiple fastest people for a given event,
-- show them in order of their names.

create or replace view finishers(event, held_on, person, time) as
select e.name, e.held_on, p.name, r.at_time
from People p
join Participants as pa on pa.person_id = p.id
join Events as e on e.id = pa.event_id
join Checkpoints as c on c.route_id = e.route_id
join Reaches as r on r.partic_id = pa.id and r.chkpt_id = c.id
where c.ordering = (select max(c2.ordering)
                    from Checkpoints c2
                    where c2.route_id = e.route_id)
order by held_on, p.name
;

create or replace q2(event, date, person, time) as
select f1.event, f1.held_on, f1.person, f1.time
from finishers f1
where f1.time = (select min(f2.time)
                from finishers f2
                where f2.event = f1.event and f2.date = f1.date)
;