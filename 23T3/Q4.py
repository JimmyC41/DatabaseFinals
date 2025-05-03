#! /usr/bin/env python3

# Write a Python/Psycopg2 script that takes a person's name and gives an
# evaluation of how their performance is trending in their chosen FunRun.

import psycopg2
import sys

if len(sys.argv) != 2:
    print("Usage!")
    exit(1)

input = sys.argv[1]
times_query = """
    select r.at_time
    from People p
    join Participants as pa on pa.person_id = p.id
    join Events as e on e.id = pa.event_id
    join Checkpoints as c on c.route_id = e.route_id
    join Reaches as r on r.partic_id = pa.id and r.chkpt_id = c.id
    where c.ordering = (select max(c2.ordering)
                    from Checkpoints c2
                    where c2.route_id = e.route_id)
    and p.name = %s
    order by e.held_on
    ;
"""

db = None
try:
    db = psycopg2.connect("dbname=funrun")
    cur = db.cursor()

    db.execute(times_query, [input])
    times = db.fetchall()
    if not times:
        print("No such person")
    elif len(times) == 1:
        print("Cannot determine a trend")
    elif len(times) == 2:
        t1 = times[0][0]
        t2 = times[1][0]
        if (t1 > t2):
            print("Improving")
        else:
            print("not improving")
    elif len(times) == 3:
        t1 = times[0][0]
        t2 = times[1][0]
        t3 = times[2][0]
        if t1 > t2 and t2 > t3:
            print("Improving")
        else:
            print("Not improving")
    else:
        print("More than 3 races... Unable to compute")
except Exception as e:
    print(f"Exception: {e}")
except psycopg2.Error as e:
    print(f"DB Error: {e}")
finally:
    if not db:
        db.close()
sys.exit(0)