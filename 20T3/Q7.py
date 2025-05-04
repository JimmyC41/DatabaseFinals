#!/usr/bin/env python3

# Write a Python/Psycopg2 script that, given an album ID, produces a list of 
# ongs giving the song title, the people who performed on that song, and the
# instrument(s) they played on that song.

import sys
import psycopg2

if len(sys.argv) != 2:
    print("Usage!")
    sys.exit(1)
input_album_id = sys.argv[1]

album_query = """
    select id, title, year, genre
    from Albums
    where id = %s
    ;
"""

songs_query = """
    select s.id, s.title, s.trackNo
    from Albums a
    join Songs s on s.on_album = a.id
    where a.id = %s
    ;
"""

performer_query = """
    select pe.name, string_agg(po.instrument,',' order by po.instrument)
    from Songs s
    join PlaysOn as po on po.song = s.id
    join Performers as pe on pe.id = po.performer
    where s.id = %s
    group by pe.name
    order by pe.name
    ;
"""

db = None

try:
    db = psycopg2.connect("dbname=music")
    cur = db.cursor()

    cur.execute(album_query, [input_album_id])
    res = cur.fetchone()
    if not res:
        print("Invalid album ID")
        sys.exit(1)
    
    album_id = res[0]
    album_title = res[1]
    album_year = int(res[2])
    album_genre = res[3]

    print(f"{album_title} ({album_year}) ({album_genre})")
    print("========================================")

    cur.execute(songs_query, [album_id])
    res = cur.fetchall()

    for song in res:
        song_id = song[0]
        song_title = song[1]
        song_no = song[2]

        print(f"{song_no}. {song_title}")
        cur.execute(performer_query, [song_id])
        res = cur.fetchall()
        
        for performer in res:
            print(f"    {performer[0]}: {performer[1]}")
except Exception as e:
    print(f"Error: {e}")
except psycopg2.Error as e:
    print(f"DB Error: {e}")
finally:
    if db:
        db.close()
sys.exit(0)
