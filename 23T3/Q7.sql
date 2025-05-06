-- A
-- If Inserting/updating into R, should check FKs exist

create or replace function check_R_fks()
returns trigger as $$
begin
    perform 1 from S where id = NEW.s_ref;
    if not found then
        raise exception 'Invalid foreign key';
    end if;

    perform 1 from T where id = NEW.t_ref;
    if not found then
        raise exception 'Invalid foreign key';
    end if;

    return NEW;
end;
$$ language plpgsql;

create trigger trigger_check_R_fks()
before insert or update
for each row
execute function check_R_fks();

-- B
-- No need to check. Deleting a tuple in R would not cause any foreign key
-- constraint problems.