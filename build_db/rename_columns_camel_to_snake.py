import sys
import sqlite3
import pandas as pd
import re
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../')

from paths import Paths


def camel_to_snake(string):
	#manual case for PAL
	out_str = str(string)
	out_str = out_str.replace('PAL','_pal')

	re_cap = re.compile('[A-Z]')
	cap_list = re_cap.findall(out_str)
	for char in cap_list:
		out_str = out_str.replace(char, '_'+char.lower())
	return out_str

def get_column_names(table_name, con):
	df_cols = pd.read_sql("PRAGMA table_info({})".format(table_name), con)
	col_list = list(df_cols['name'])
	return col_list


#which DB?
p = Paths(mode='test')

raw_db_path = p.RAW_DB_PATH
con = sqlite3.connect(raw_db_path)
cur = con.cursor()

table_list = ['raw_games', 'raw_player_games', 'raw_player_frames_post']

manual_rename_list = [
	('raw_games', 'filename', 'file_name'),
	('raw_games', 'dirpath', 'dir_path'),
]

rename_col_sql = "ALTER TABLE {table} RENAME COLUMN {old_col} TO {new_col}"
#ALTER TABLE (tablename) RENAME COLUMN (old_name) TO (new_name)


for table_name in table_list:
	col_list = get_column_names(table_name, con)
	for col in col_list:
		new_col = camel_to_snake(col)
		if new_col != col:
			sql_string = rename_col_sql.format(table=table_name, old_col=col, new_col=new_col)
			print(sql_string)
			cur.execute(sql_string)

for (table, old_col, new_col) in manual_rename_list:
	sql_string = rename_col_sql.format(table=table, old_col=old_col, new_col=new_col)
	print(sql_string)
	cur.execute(sql_string)


# print(camel_to_snake('gameId'))
# print(camel_to_snake('isPAL'))
# print(camel_to_snake('physicalLTrigger'))


con.close()
