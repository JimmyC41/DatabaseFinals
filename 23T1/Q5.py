#! /usr/env/bin python3

# Write a Python3/Psycopg2 script that given a branch location, prints detail
# of all the accounts held at that branch, and checks that the Branches.assets
# is equal to the sum of the balances of all the accounts that are held at
# that branch.

import sys
import psycopg2

if len(sys.argv) != 2:
    print("Usage!")
    sys.exit(1)
input = sys.argv[1]

branch_query = """"
    select id, assets
    from Branches b
    where b.location = %s
"""

acct_query = """
    select a.id, c.given ||' '|| c.family, c.lives_in, a.balance
    from Branches b
    join Accounts as a on a.held_at = b.id
    join Held_by as h on h.account = a.id
    join Customers as c on c.id = h.customer
    where b.id = %s
"""

db = None
try:
    db = psycopg2.connect("dbname=banks")
    cur = db.cursor()

    cur.execute(branch_query, [input])
    res = cur.fetchall()

    if not res:
        print(f"No such branch {input}")
        sys.exit(0)

    branch_id = res[0][0]
    branch_assets = res[0][1]

    print(f"{input} branch ({branch_id}) holds")

    cal_assets = 0
    
    cur.execute(acct_query, [branch_id])
    res = cur.fetchall()
    for tup in res:
        acct_id = tup[0]
        cust_name = tup[1]
        cust_location = tup[2]
        acct_balance = tup[3]
        cal_assets += acct_balance
        print(f"- account {acct_id} owned by {cust_name} from {cust_location} with ${acct_balance}")
    
    print(f"Assets: ${cal_assets}")
    if cal_assets != branch_assets:
        print("Discrepancy between assets and sum of account balances")
except Exception as e:
    print("Error: {e}")
except psycopg2.error as e:
    print("DB Error: {e}")
finally:
    if not db:
        db.close()
sys.exit(0)


