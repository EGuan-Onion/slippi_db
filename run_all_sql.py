#Usage:
# $python run_all_sql.py production
import sys
import sqlite3
import pandas as pd
import pathlib

from paths import (
	RAW_DB_PATH, 
	SQL_DIR_PATH, 
	SQL_OUTPUT_DIR_PATH,

	TEST_RAW_DB_PATH, 
	# TEST_SQL_DIR_PATH, 
	TEST_SQL_OUTPUT_DIR_PATH,
	)


def run(mode='test'):
	if mode=='test':
		db_path = TEST_RAW_DB_PATH
		sql_dir_path = pathlib.Path(SQL_DIR_PATH)
		out_dir_path = pathlib.Path(TEST_SQL_OUTPUT_DIR_PATH)
	elif mode=='production':
		db_path = RAW_DB_PATH
		sql_dir_path = pathlib.Path(SQL_DIR_PATH)
		out_dir_path = pathlib.Path(SQL_OUTPUT_DIR_PATH)
	else:
		print("unrecognized mode.  must be in ['test', 'production']")
		return

	con = sqlite3.connect(db_path)
	con.execute("PRAGMA cache_size=-256000")



	for p in sql_dir_path.glob('*.sql'):
		# print(p)
		# print(p.relative_to(sql_dir_path))
		file_stem = p.stem #marth_attacks

		sql_file_path = sql_dir_path.joinpath(file_stem + ".sql")
		out_file_path = out_dir_path.joinpath(file_stem + ".csv")

		print(sql_file_path)
		print(out_file_path)

		# Run SQL
		#read SQL
		print("Read .sql file")
		f = open(sql_file_path, 'r')
		sql_string = f.read()
		f.close()

		#run SQL
		print("Run .sql with pandas")
		df = pd.read_sql(sql_string, con)

		#write CSV
		print("csv head")
		print(df.head())
		print("Write")
		df.to_csv(out_file_path, index=False)


	con.close()

if __name__ == '__main__':
	print(__name__)
	print(sys.argv)
	run(*sys.argv[1:2])