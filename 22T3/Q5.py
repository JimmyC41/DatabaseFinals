#!/usr/bin/env python3

# Write a Python/Psycopg2 script that prints details of a race meeting.

import sys
import psycopg2

if len(sys.argv) != 3:
    print("Usage!")
    sys.exit(1)
input_racecourse = sys.argv[1]
input_date = sys.argv[2]

racecourse_query = """
    select id
    from Racecourses
    where name = %s
"""

meeting_query = """
    select m.id
    from Racecourses rc
    join Meetings as m on m.run_at = rc.id
    where rc.name = %s and m.run_on = %s
"""

races_query = """
    select r.id, r.name, r.prize, r.length
    from Races r
    join Meetings as m on m.id = r.part_of
    where m.id = %s
"""

race_info_query = """
    select h.name, j.name, ru.finished
    from Races r
    join Runners as ru on ru.race = r.id
    join Horses as h on h.id = ru.horse
    join Jockeys as j on j.id = ru.jockey
    where r.id = %s
    and ru.finished <= 3
"""

db = None

try:
    db = psycopg2.connect("dbname=races")
    cur = db.cursor()

    cur.execute(racecourse_query, [input_racecourse])
    res = cur.fetchone()
    if not res:
        print("No such racecourse")
        sys.exit(1)

    cur.execute(meeting_query, [input_racecourse, input_date])
    res = cur.fetchone()
    if not res:
        print("No such meeting")
        sys.exit(0)
    meeting_id = res[0]

    print(f"Race meeting at {input_racecourse} on {input_date}")

    cur.execute(races_query, [meeting_id])
    races = cur.fetchall()
    prize_multiple = [0.7, 0.2, 0.1]

    for race in races:
        race_id = race[0]
        race_name = race[1]
        race_prize = race[2]
        race_length = race[3]

        print(f"{race_name}, prize pool ${race_prize}, run over {race_length}m")

        cur.execute(race_info_query, [race_id])
        runners = cur.fetchall()
        for runner in runners:
            horse_name = runner[0]
            jockey_name = runner[1]
            position = runner[2] - 1
            winnings = race_prize * prize_multiple[position]

            print(f"{horse_name} ridden by {jockey_name} wins ${winnings}")
except Exception as e:
    print("Error: {e}")
except psycopg2.error as e:
    print("DB Error: {e}")
finally:
    if db:
        db.close()
sys.exit(0)