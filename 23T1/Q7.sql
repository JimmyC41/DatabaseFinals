-- A: Checks transactions is valid

create or replace function txCheckers()
returns trigger as $$
declare
    src_bal integer;
    dest_bal integer;
begin
    -- Check amount
    if (NEW.amount <= 0) then
        raise exception 'Invalid amount';
    end if;

    -- Check customer owns both accts
    perform * from Held_by where customer = NEW.CustomerID and account = NEW.SourceAcct;
    if not found then
        raise exception 'Customer does not own source acct';
    end if;

    perform * from Held_by where customer = NEW.CustomerID and account = NEW.DestAcct;
    if not found then
        raise exception 'Customer does not own dest acct';
    end if;
    
    -- Src
    if (NEW.txtype in ('transfer', 'withdrawal')) then
        -- Get src balance
        select balance into src_bal from Accounts where id = NEW.SourceAcct;
        if not found then
            raise exception 'Invalid account';
        end if;

        -- Check src balance is enough
        if (balance < NEW.amount) then
            raise exception 'Insufficient funds';
        end if;
    end if;

    -- Dest
    if (NEW.txtype in ('transfer', 'deposit')) then
        -- Get dest balance
        select balance into dest_bal from Accoutns where id = NEW.DestAcct;
        if not found then
            raise exception 'Invalid account';
        end if;
    end if;

    return NEW;
end;
$$ language plpgsql;

-- B: Update relevant account and branch assets

create or replace function txupdate()
returns trigger as $$
declare
    branch_id integer;
begin
    if (NEW.txtype in ('transfer', 'withdrawal')) then
        update Accounts set balance = balance - NEW.amount where id = NEW.SourceAcct;
        select held_at into branch_id from Accounts where id = NEW.SourceAcct;
        update Branches set assets = assets - NEW.amount where id = branch_id;
    end if;

    if (NEW.txtype in ('transfer', 'deposit')) then
        update Accounts set balance = balance + NEW.amount where id = NEW.DestAcct;
        select held_at into branch_id from Accounts where id = NEW.DestAcct;
        update Branches set assets = assets + NEW.amount where id = branch_id;
    end if;
end;
$$ language plpgsql;