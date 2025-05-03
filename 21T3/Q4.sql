create or replace view get_property_info(id, unit, street_no, street_name, street_type, suburb, postcode) as
select p.id, p.unit_no, p.street_no, s.name, s.stype, su.name, su.postcode
from Streets s
join Properties as p on p.street = s.id
join Suburbs as su on su.id = s.suburb
;

create or replace function address(propID integer)
    returns text
as $$
declare
    tup record;
begin
    perform 1 from Properties where id = propID;
    if not found then
        return "No such property";
    
    select * into tup from get_property_info where id = propID;

    if tup.unit is null then
        return tup.street_no ||' '|| tup.street_name ||' '|| tup.street_type ||', '|| tup.suburb ||' '|| tup.postcode;
    else
        return tup.unit ||'/'|| tup.street_no ||' '|| tup.street_name ||' '|| tup.street_type ||', '|| tup.suburb ||' '|| tup.postcode;
    end if
end
$$ language plpgsql;
