#!/usr/bin/env python3

# Write a Python/Psycopg2 script that finds unsold properties matching criteria
# specified on the command line.

# Need to do a left join.

import sys
import psycopg2

if len(sys.argv) != 6:
    print("Usage!")
    sys.exit(0)

input_type = sys.argv[1]
input_price = int(sys.argv[2])
input_bedrooms = int(sys.argv[3])
input_bathrooms = int(sys.argv[4])
input_carspaces = int(sys.argv[5])

if (input_bedrooms == 0):
    input_bedrooms = 100
if (input_bathrooms == 0):
    input_bathrooms = 100
if (input_carspaces == 0):
    input_carspaces = 100

property_query = """
    with
        bedrooms as (
            select property, number
            from Features
            where feature = 'bedrooms'
        ),
        bathrooms as (
            select property, number
            from Features
            where feature = 'bathrooms'
        ),
        carspaces as (
            select property, number
            from Features
            where feature = 'carspaces'
        )
    select
        p.id,
        address(p.id),
        be.number,
        ba.number,
        c.number,
        p.list_price
    from Properties p
    left join bedrooms as be on be.property = p.id
    left join bathrooms as ba on ba.property = p.id
    left join carspaces as c on c.property = p.id
    where p.sold_date is null
    and p.type = %s
    and p.list_price <= %s
    and coalesce(be.number, 0) <= %s
    and coalesce(ba.number, 0) <= %s
    and coalesce(c.number, 0) <= %s
    ;
"""

db = None

try:
    db = psycopg2.connect("dbname=properties")
    cur = db.cursor()
    cur.execute(property_query, [input_type, input_price, input_bedrooms, input_bathrooms, input_carspaces])
    res = cur.fetchall()

    for house in res:
        property_id = house[0]
        address = house[1] # How to acct for units as well ?
        bedroom = house[2]
        bathroom = house[3]
        carspaces = house[4]
        price = house[5]
        print(f"#{property_id}: {address}, {bedroom}br, {bathroom}ba, {carspaces}car, ${price}")

except Exception as e:
    print(f"Error: {e}")
    sys.exit(0)
except psycopg2.Error as e:
    print(f"DB Error: {e}")
    sys.exit(0)
finally:
    if db:
        db.close()
sys.exit(0)