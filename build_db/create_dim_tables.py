#!/usr/bin/python

# create dim tables
# dim_character
# dim_action_state (global action states only)
# dim_stage

import os
import sqlite3
import pandas as pd

dim_table_filepath = '/Users/eguan/Slippi/slippi_db/dim_tables/'

filelist = os.listdir('/Users/eguan/Slippi/slippi_db/dim_tables')


con = sqlite3.connect('raw.db')

cur = con.cursor()


for file in filelist:
	filepath = dim_table_filepath+file
	table_name = file.strip('.csv')
	df = pd.read_csv(filepath)
	cur.execute("DROP TABLE {}".format(table_name))
	df.to_sql(table_name, con, if_exists='replace', index=False)

	for row in cur.execute("SELECT * FROM {}".format(table_name)):
		print(row)

con.close()