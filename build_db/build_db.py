#Usage:
# To build the test DB and re-populate the files
# $python build_db.py test True
import sys
sys.path.append("/Users/eguan/slippi_db/")

import pathlib
import sqlite3
import pandas as pd

from paths import (
	RAW_DB_PATH, 
	REPLAY_DIR_PATH,

	TEST_RAW_DB_PATH,
	TEST_REPLAY_DIR_PATH,
	)

#in local dir
import create_dim_tables
import parse_runner


def run_sql(sql_filepath, con):
	f = open(sql_filepath, 'r')
	sql_string = f.read()
	f.close()

	con.executescript(sql_string)
	return


def run(mode='test', populate=False):
	# connect to DB
	if mode=='test':
		db_path = TEST_RAW_DB_PATH
		replay_path = TEST_REPLAY_DIR_PATH
	elif mode=='production':
		db_path = RAW_DB_PATH
		replay_path = REPLAY_DIR_PATH
	else:
		print("unrecognized mode.  must be in ['test', 'production']")
		return

	con = sqlite3.connect(db_path)
	con.execute("PRAGMA cache_size=-256000")


	# create raw tables
	print("Creating Raw Tables")
	run_sql('create_raw_tables.sql', con)

	# # create dim tables
	print("Creating Dim Tables")
	create_dim_tables.run()

	# create indexes
	print("Creating Indexes")
	run_sql('create_index.sql', con)

	con.close()

	if populate:
		print("Populating Raw Tables")
		parse_runner.run(add_to_queue='./', mode=mode, reset_queue=True)



if __name__=='__main__':
	print(__name__)
	print(sys.argv)
	run(*sys.argv[1:3])


