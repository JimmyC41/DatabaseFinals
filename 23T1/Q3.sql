-- Write a SQL view that gives a list of branches where every customer who holds
-- an account at that branch, also lives in the suburb where the branch is located.

-- All customers less customers who live in the suburb = NULL

create or replace customers_info(c_id, c_lives_in, b_id) as
select c.id, c.lives_in, b.id
from Customers c
join Held_by as hb on hb.customer = c.id
join Accounts as a on a.id = hb.account
join Branches as b on b.id = a.held_at
;

create or replace view q3(branch) as
select b.name
from Branches b
where not exists(
    (select * from customers_info res1 where res1.b_id = b.id)
    except
    (select * from customers_info res2 where res2.b_id = b.id
                                        and res2.c_lives_in = b.location)
)
;