#Arguments: <mode> [if_exists='replace']
import sys
sys.path.append("/Users/eguan/slippi_db/")

import pathlib
import sqlite3
import pandas as pd


from paths import Paths


def run(
		mode,
		if_exists='replace',
	):
	p = Paths(mode=mode)

	db_path = p.RAW_DB_PATH
	static_table_dir_path = p.STATIC_TABLE_DIR_PATH


	file_list = pathlib.Path(static_table_dir_path).glob('*.csv')

	con = sqlite3.connect(db_path)
	print(db_path)
	print(static_table_dir_path)

	for file_path in file_list:
		table_name = file_path.stem
		print(table_name)

		df = pd.read_csv(file_path)


		# con.execute("DROP TABLE {}".format(table_name))
		df.to_sql(name=table_name, con=con, if_exists=if_exists, index=False)

		# # Check Result
		# for row in con.execute("SELECT * FROM {}".format(table_name)):
		# 	print(row)

	con.close()



if __name__=='__main__':
	print(__name__)
	print(sys.argv)
	
	if sys.argv[1] == '-help':
		print("Arguments: <mode> [if_exists='replace']")
		print("  if_exists in ('fail', 'replace', 'append')")
		print("Example: create static tables in test environment")
		print("$python create_static_tables.py test")

	else:
		run(*sys.argv[1:3])