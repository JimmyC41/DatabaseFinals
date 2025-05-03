-- Write an SQL view that gives a list performers who play many instruments,
-- and how many instruments they play.

-- Hard!!

create or replace view Q3(performer,ninstruments) as
with
-- Normalised view of performers and their instruments
    normalised as (
        select
            performer,
            case
                when instrument ~* 'guitar' then 'guitar'
                when instrument = 'vocals' then null
                else instrument
            end as instr
        from PlaysOn
    ),
-- Count of distinct instruments
    distinct_instr as (
        select count(distinct instr) as total_instr
        from normalised
        where instr is not null
    ),
-- Filter out performers with more than 1/2 of total
    filtered_performers as (
        select pe.name as performer, count(distinct instr) as ninstruments
        from normalised n
        join Performers as pe on pe.id = n.performer
        where n.instr is not null
        group by pe.name
    )

select fp.performer, fp.ninstruments
from filtered_performers fp
cross join distinct_instr i
where fp.ninstruments * 2 > i.total_instr
;