#! /usr/bin/python

import sqlite3
import pandas as pd

con = sqlite3.connect('raw.db')

cur = con.cursor()

for row in cur.execute("SELECT * FROM raw_games"):
	print(row)


# for row in cur.execute("SELECT sum(1) FROM raw_player_frames_pre"):
# 	print(row)



# pandas

# print(pd.read_sql("SELECT sum(1) FROM raw_player_frames_pre", con))

sql_string = """
	SELECT
        pfp.characterId
    ,   pfp.gameId
    ,   connectCode
    ,   stageId
    ,   positionX
	,	positionY
	, 	actionStateId
    ,   actionStateCounter
    ,   CASE
            WHEN actionStateId between 347 and 352
                THEN 'Fox side-B'
            WHEN actionStateId between 353 and 359
                THEN 'Fox up-B'
        ELSE '???' END as recovery_type
	FROM  raw_player_frames_post pfp
    JOIN  raw_games g
    ON  g.gameId = pfp.gameId

    JOIN  raw_player_games pg
    ON  pg.gameId = pfp.gameId
    AND pg.playerIndex = pfp.playerIndex


	WHERE
        pfp.characterId = 2
    AND actionStateId between 347 and 359
    AND actionStateCounter = 0 
"""

print(pd.read_sql(sql_string, con))
df = pd.read_sql(sql_string, con)
df.to_clipboard()



# sql_string = """
#     SELECT
#         characterId
#     ,   actionStateId
#     ,   sum(1)
#     FROM  raw_player_frames_post
#     WHERE
#         characterId = 2
#     GROUP BY 1,2
# """

# print(pd.read_sql(sql_string, con))
# df = pd.read_sql(sql_string, con)




# Cleanup

con.close()