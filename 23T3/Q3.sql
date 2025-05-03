-- Write a PLpgSQL function that takes an Event ID and gives a list of people
-- who didn't finish the route ("quitters"). For each of these people, show the
-- location of the last checkpoint they reached.

create or replace view final_checkpoints(event_id, position) as
from Events e
join Checkpoints as c on c.route_id = e.route_id
where c.ordering = (select max(c2.ordering)
                    from Checkpoints c2
                    where c2.route_id = c.route_id)
;

create or replace view people_positions(event_id, person_name, chkpt, location) as
select e.id, p.name, c.ordering, c.location
from People p
join Participants as pa on pa.person_id = p.id
join Events as e on e.id = pa.event_id
join Checkpoints as c on c.route_id = e.route_id
join Reaches as r on r.partic_id = pa.id and r.chkpt_id = c.id
;

create or replace function q3(_eventID integer)
    returns setof text
as $$
declare
    _finalchkpt integer;
    _tuple record;
    _quitters integer := 0;
begin
    -- Find the event
    perform 1 from Events where id = _eventID;
    if not found then
        return next "No such event";
        return;
    end if;

    -- Find the final checkpoint for the event
    select position into _finalchkpt
    from final_checkpoints
    where event_id = _eventID;

    -- Find people who gave up
    for _tuple in select * from people_positions
    where event_id = _eventID and chkpt < _finalchkpt
    order by person_name
    loop
        return next _tuple.person_name ||"gave up at"|| _tuple.location;
        _quitters = _quitters + 1;
    end loop;

    -- Check if no of quitters = 0
    if _quitters = 0 then
        return next "Nobody gave up";
    end if;
end;
$$ language plpgsql;