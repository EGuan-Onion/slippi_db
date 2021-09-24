import sys
sys.path.append("/Users/eguan/slippi_db/")

import sqlite3
import pandas as pd
import run_sql


from paths import Paths

#Run All
run_sql.run(mode='test')


#Run One
p = Paths(mode='test')
sql_dir_path = p.SQL_DIR_PATH

path_list = pathlib.Path(sql_dir_path).glob('*.sql')
path = next(path_list)

run_sql.run(mode='test', sql_file=path)