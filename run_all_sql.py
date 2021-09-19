#run_all_sql.py
import sqlite3
import pandas as pd
import pathlib

from paths import RAW_DB_PATH, SQL_DIR_PATH, SQL_OUTPUT_DIR_PATH


def run():
	con = sqlite3.connect(RAW_DB_PATH)
	con.execute("PRAGMA cache_size=-64000")


	sql_dir_path = pathlib.Path(SQL_DIR_PATH)
	out_dir_path = pathlib.Path(SQL_OUTPUT_DIR_PATH)

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
		f = open(sql_file_path, 'r')
		sql_string = f.read()
		f.close()

		#run SQL
		df = pd.read_sql(sql_string, con)

		#write CSV
		print(df.head())
		# df.to_csv(out_file_path, index=False)


	con.close()

if __name__ == '__main__':
	print(__name__)
	run()