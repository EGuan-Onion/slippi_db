#Usage:
#To run all scripts in production, refreshing the output
# $python run_sql.py production 
#To run tech_directions.sql specifically, on a test environment
# $python run_sql.py test tech_directions
import sys
import sqlite3
import pandas as pd
import pathlib

from paths import Paths

#name clashes with build_db.run_sql()

def run_one(sql_file_path, sql_dir_path, out_dir_path, con):
	file_stem = sql_file_path.stem #marth_attacks

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


def run(mode='test', sql_file=None):
	p = Paths(mode=mode)
	db_path = p.RAW_DB_PATH
	sql_dir_path = pathlib.Path(p.SQL_DIR_PATH)
	out_dir_path = pathlib.Path(p.SQL_OUTPUT_DIR_PATH)

	con = sqlite3.connect(db_path)
	con.execute("PRAGMA cache_size=-256000")


	if sql_file:
		sql_file_path = sql_dir_path.joinpath(sql_file)
		path_list = [sql_file_path]
	else:
		path_list = sql_dir_path.glob('*.sql')


	for path in path_list:
		run_one(path, sql_dir_path, out_dir_path, con)

	con.close()


if __name__ == '__main__':
	print(__name__)
	print(sys.argv)
	run(*sys.argv[1:3])