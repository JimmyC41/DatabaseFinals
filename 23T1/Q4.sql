-- Write a PLpgSQL function that checks, for a given account, that the balance
-- stored in the Accounts is consistent with the balance that could be
-- calculated via the transaction history on that account.

create or replace view transactions(a_id, ttype, amount, source, destination) as
select a.id, t.ttype, t.amount, t.source, t.destination
from Transactions t
join Accounts as a on a.id = t.source or a.id = t.destination
;

create or replace function q4(_acctID integer)
    returns text
as $$
declare
    actual integer := 0;
    expected integer := 0;
    tup record;
begin
    select balance into expected from Accounts where id = _acctID;
    if (not found) then
        return "No such account";
    end if;

    for tup in select * from transactions where a_id = _acctID
    loop
        if tup.ttype = 'deposit' then
            actual := actual + tup.amount;
        elsif tup.ttype = 'withdrawal' then
            actual := actual - tup.amount;
        elsif tup.ttype = 'transfer' then
            if tup.destination = _acctID then
                actual := actual + tup.amount;
            else
                actual := actual - tup.amount;
            end if;
        end if;
    end loop;

    if actual = expected then
        return 'OK'
    else
        return 'Mistmach: calculated balance '|| actual ||', stored balance' expected;
    end if;
end;
$$ language plpgsql;