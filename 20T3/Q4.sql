create type SongCounts as ( "group" text, nshort integer, nlong integer );

create or replace function q4()
    returns setof SongCounts
as $$
declare
    r1 record;
    r2 record;
    nshort integer;
    nlong integer;
    res SongCounts;
begin
    for r1 in
        select id, name
        from Groups
        order by name
    loop
        res."group" := r1.name;
        nshort := 0;
        nlong := 0;

        for r2 in
            select s.length as song_length
            from Groups g
            join Albums as a on a.made_by = g.id
            join Songs as s on s.on_album = a.id
            where g.id = r1.id
        loop
            if r2.song_length < 180 then
                nshort := nshort + 1;
            end if;

            if r2.song_length > 360 then
                nlong := nlong + 1;
            end if;
        end loop;

        res.nshort := nshort;
        res.nlong := nlong;
        return next res;
    end loop;
end;
$$ language plpgsql;

/*
create or replace view short_songs(id, nshort) as
select g.id, count(*)
from Group g
join Albums as a on a.made_by = g.id 
join Songs as s on s.on_album = a.id
where s.length < 180
group by g.id
;

create or replace view long_songs(id, nlong) as
select g.id, count(*)
from Group g
join Albums as a on a.made_by = g.id 
join Songs as s on s.on_album = a.id
where s.length > 360
group by g.id
;

create or replace view song_infos(group, nshort, nlong)
select g.name, s.nshort, l.nlong
from Group g
left join short_songs as s on s.id = g.id
left join long_songs as l on l.id = g.id
order by g.name
;
*/