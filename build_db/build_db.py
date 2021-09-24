#Arguments: <mode> [populate=False]
import sys
sys.path.append("/Users/eguan/slippi_db/")

import os
import pathlib
import sqlite3
import pandas as pd

from paths import Paths

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


def run(
		mode, 
		populate=False,
		wipe=False,
	):

	p = Paths(mode=mode)
	db_path = p.RAW_DB_PATH
	replay_path = p.REPLAY_DIR_PATH

	if wipe:
		print("Deleting old .db file")
		os.remove(db_path)

	# connect to DB
	print(db_path)
	con = sqlite3.connect(db_path)
	con.execute("PRAGMA cache_size=-256000")

	# create raw tables
	print("Creating Raw Tables")
	run_sql('create_raw_tables.sql', con)

	# create static tables
	print("Creating Static Tables")
	create_static_tables.run(mode=mode)

	print("Creating dim_action_state_union")
	run_sql('create_dim_action_state_union.sql', con)

	# create indexes
	print("Creating Indexes")
	run_sql('create_index.sql', con)

	# create derived table
	print("Creating derived_player_game_opponent")
	run_sql('create_player_game_opponent.sql', con)



	if populate:
		print("Populating Raw Tables")
		parse_runner.run(add_to_queue='./', mode=mode, force_requeue=True, reset_queue=True)

		print("Populating Derived Tables")
		run_sql('insert_player_game_opponent.sql', con)

	con.close()


if __name__=='__main__':
	print(__name__)
	print(sys.argv)
	
	if sys.argv[1] == '-help':
		print("Arguments: <mode> [populate=False] [wipe=False]")
		print("  populate will add files to tables.  Usually used for test env)")
		print("Example: rebuild the db in test environment, and re-parsing .slp files")
		print("$python build_db.py test True True")

	else:
		run(*sys.argv[1:4])


