#!/usr/bin/env python3

# Write Python/Psycopg2 script that, given a group ID,
# produces a discography for that group. 

import sys
import psycopg2

if len(sys.argv != 2):
    print("Usage!")
    sys.exit(1)
input_group_id = sys.argv[1]

group_query = """
    select name
    from Groups
    where id = %s
    ;
"""

album_query = """
    select a.id, a.title, a.year, a.genre
    from Groups g
    join Albums as a on a.made_by = g.id
    where g.id = %s
    order by a.year, a.title
    ;
"""

songs_query = """
    select s.trackNo, s.title, s.length
    from Songs s
    join Albums as a on a.id = s.on_album
    where a.id = %s
    order by s.trackNo
    ;
"""

db = None

def convertToMinSec(seconds):
    mins = int(seconds/60)
    secs = seconds - mins*60
    return [min, secs]

try:
    db = psycopg2.connect("dbname=music")
    cur = db.cursor()

    cur.execute(group_query, [input_group_id])
    res = cur.fetchone()
    group_name = res[0]

    if not res:
        print("Invalid group ID")
        sys.exit(1)
    
    print(f"Discography for {group_name}")

    cur.execute(album_query, [input_group_id])
    res = cur.fetchall()

    for album in res:
        album_id = album[0]
        album_title = album[1]
        album_year = int(album[2])
        album_genre = album[3]

        print(f"--------------------\n{album_title} ({album_year}) ({album_genre})\n--------------------")

        cur.execute(songs_query, [album_id])
        res = cur.fetchall()

        if not res:
            print("No songs in this album!")
            continue

        for song in res:
            song_no = song[0]
            song_title = song[1]
            song_length = int(song[2])
            song_mins, song_secs = convertToMinSec(song_length)
            print(f"{song_no:2d}. {song_title} ({song_mins:d}:{song_secs:02d})")
except Exception as e:
    print(f"Error: {e}")
except psycopg2.error as e:
    print(f"DB Error: {e}")
finally:
    if db:
        db.close()
sys.exit(0)