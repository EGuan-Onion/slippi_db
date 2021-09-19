import sys
sys.path.append("/Users/eguan/slippi_db/")

import pathlib
import sqlite3
import pandas as pd


from paths import RAW_DB_PATH, TEST_RAW_DB_PATH, DIM_TABLE_DIR_PATH


def run(mode='test'):
	if mode=='test':
		db_path = TEST_RAW_DB_PATH
	elif mode=='production':
		db_path = RAW_DB_PATH
	else:
		print("unrecognized mode.  must be in ['test', 'production']")
		return


	file_list = pathlib.Path(DIM_TABLE_DIR_PATH).glob('*.csv')

	con = sqlite3.connect(db_path)


	for file_path in file_list:
		table_name = file_path.stem
		print(table_name)

		df = pd.read_csv(file_path)


		# con.execute("DROP TABLE {}".format(table_name))
		df.to_sql(name=table_name, con=con, if_exists='replace', index=False)

		# # Check Result
		# for row in con.execute("SELECT * FROM {}".format(table_name)):
		# 	print(row)

	con.close()



if __name__=='__main__':
	print(__name__)
	run(mode='test')