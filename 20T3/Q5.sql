-- Write a PLpgSQL function that produces a list of groups and all of the music
-- genres they have recorded albums in.

create type GroupGenres as ("group" text, genres text);

create or replace function q5() returns
    setof GroupGenres
as $$
declare
    r1 record;
    r2 record;
    album_genres text;
    res GroupGenres;
begin
    for r1 in
        select id, name
        from Groups
    loop
        res."group" = r1.name;
        album_genres := '';

        for r2 in
            select g.id, distinct(a.genre) as genre
            from Groups g
            join Albums as a on a.made_by = g.id
            group by g.id
            where g.id = r1.id
        loop
            if album_genres = '' then
                almbum_genres := r2.genre;
            else
                album_genres := album_genres || ', '|| r2.genre;
            end if;
        end loop;

        res.genres := album_genres
        return next res;
    end loop;
end;
$$ language plpgsql;