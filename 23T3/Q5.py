#! /usr/bin/env python3

# Write a Python/Psycopg2 script that takes a partial description for an event,
# and produces a list of fastest participants in each age group for that event.

import sys
import psycopg2

def print_info(arr, text):
    print(text)

    if len(arr) == 0:
        print("- no participants in this age group")
        return
    
    best_time = arr[0][2]
    for runner in arr:
        if runner[2] > best_time:
            return
        print(f"- {arr[0]}, {arr[1]}yo, {arr[2]}mins")

if len(sys.argv) != 3:
    print("Usage!")
    sys.exit(1)

input_event = sys.argv[1]
input_year = sys.argv[2]

event_query = """
select e.id, e.name, e.held_on
from Events e
where e.name ~* %s and e.held_on::text ~* %s
;
"""

finishers_query = """
    select p.name, (e.held_on - p.d_o_b) / 365, r.at_time
    from People p
    join Participants as pa on pa.person_id = p.id
    join Events as e on e.id = pa.event_id
    join Checkpoints as c on c.route_id = e.route_id
    join Reaches as r on r.partic_id = pa.id and r.chkpt_id = c.id
    where c.ordering = (select max(c2.ordering)
                    from Checkpoints c2
                    where c2.route_id = e.route_id)
    and e.id = %s
    order by r.at_time
    ;
"""

db = None
try:
    db = psycopg2.connect("dbname=funrun")
    cur = db.cursor()

    cur.execute(event_query, [input_event, input_year])
    res = cur.fetchall()
    if not res:
        print("No matching event")
    if len(res) > 1:
        print("Event/year is ambiguous")
    event_id = res[0][0]
    event_name = res[0][1]
    event_held_on = res[0][2]

    print(f"{event_name}, {event_held_on}")

    cur.execute(finishers_query, [event_id])
    res = cur.fetchall()
    _under20 = []
    _under24 = []
    _under29 = []
    _under34 = []
    _over35 = []

    for tup in res:
        if tup[1] < 20:
            _under20.append(tup)
        elif tup[1] >= 20 and tup[1] <= 24:
            _under24.append(tup)
        elif tup[1] >= 25 and tup[1] <= 29:
            _under29.append(tup)
        elif tup[1] >= 30 and tup[1] <= 34:
            _under34.append(tup)
        else:
            _over35.append(tup)

    print_info(_under20, "under 20")
    print_info(_under24, "20-24")
    print_info(_under29, "25-34")
    print_info(_under34, "30-34")
    print_info(_over35, "35 and over")
    
except Exception as e:
    print("Error: {e}")
except psycopg2.error as e:
    print("DB Error: {e}")
finally:
    if not db:
        db.close()