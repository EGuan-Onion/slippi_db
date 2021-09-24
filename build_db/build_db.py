#Usage:
# To build the test DB and re-populate the files
# $python build_db.py test True
# $python build_db.py production
import sys
sys.path.append("/Users/eguan/slippi_db/")

import pathlib
import sqlite3
import pandas as pd

from paths import Paths
# (
# 	RAW_DB_PATH, 
# 	REPLAY_DIR_PATH,

# 	TEST_RAW_DB_PATH,
# 	TEST_REPLAY_DIR_PATH,
# 	)

#in local dir
import create_static_tables
import parse_runner


#name clashes with run_sql.py
def run_sql(sql_filepath, con):
	f = open(sql_filepath, 'r')
	sql_string = f.read()
	f.close()

	con.executescript(sql_string)
	return


def run(mode='test', populate=False):
	# which DB?  test, local, production
	p = Paths(mode=mode)
	db_path = p.RAW_DB_PATH
	replay_path = p.REPLAY_DIR_PATH

	# connect to DB
	print(db_path)
	con = sqlite3.connect(db_path)
	con.execute("PRAGMA cache_size=-256000")

	# create raw tables
	print("Creating Raw Tables")
	run_sql('create_raw_tables.sql', con)

	# # create dim tables
	print("Creating Static Tables")
	create_static_tables.run(mode=mode)

	print("Creating Action State Union")
	run_sql('create_dim_action_state_union.sql', con)

	# create indexes
	print("Creating Indexes")
	run_sql('create_index.sql', con)

	con.close()

	if populate:
		print("Populating Raw Tables")
		parse_runner.run(add_to_queue='./', mode=mode, force_requeue=True, reset_queue=True)



if __name__=='__main__':
	print(__name__)
	print(sys.argv)
	run(*sys.argv[1:3])


