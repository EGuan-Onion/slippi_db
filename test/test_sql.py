import sys
sys.path.append("/Users/eguan/slippi_db/")

import sqlite3
import pandas as pd


from paths import Paths

p = Paths(mode='test')
raw_db_path = p.RAW_DB_PATH
sql_output_dir_path = p.SQL_OUTPUT_DIR_PATH

con = sqlite3.connect(raw_db_path)
con.execute("PRAGMA cache_size=-256000")

file_stem = 'tech_directions'
sql_filepath = '../sql/' + file_stem + '.sql'
csv_out_filepath = sql_output_dir_path + file_stem + '.csv'

print(file_stem)

# con.execute("""
# 	select *
# 	from  raw_games
# 	where dir_path like '%Summit%'
# 	""")


f = open(sql_filepath, 'r')
sql_string = f.read()
f.close()


df = pd.read_sql(sql_string, con)
print(df.head())

df.to_csv(csv_out_filepath, index=False)


con.close()