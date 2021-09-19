import sqlite3
import pandas as pd

sys.path.insert(1, '../')

from paths import RAW_DB_PATH, SQL_OUTPUT_DIR_PATH

con = sqlite3.connect(RAW_DB_PATH)
con.execute("PRAGMA cache_size=-64000")


sql_filepath = './sql/tech_directions.sql'
csv_out_filepath = SQL_OUTPUT_DIR_PATH + 'tech_directions.csv'

# con.execute("""
# 	select *
# 	from  raw_games
# 	where dir_path like '%Summit%'
# 	""")


f = open(sql_filepath, 'r')
sql_string = f.read()
f.close()


#print 4 rows)
for row in con.execute(sql_string).fetchmany(4):
	print(row)

df = pd.read_sql(sql_string, con)
df.to_csv(csv_out_filepath, index=False)


con.close()