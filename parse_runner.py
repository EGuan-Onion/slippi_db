#Arguments: <mode> [add_to_queue=None] [force_requeue=False] [empty_queue=False]
#$python parse_runner.py test './onion_slp/' True

import sys

import pathlib
import sqlite3

from Naked.toolshed.shell import execute_js

from paths import Paths
from parse_queue import ParseQueue

# Read the queue
# run parse_slp.js to process the .slp file and write to the database
# return status, update queue

def insert_derived(mode, replay_file_path):
	p = Paths(mode=mode)
	db_path = p.RAW_DB_PATH


	con = sqlite3.connect(db_path)

	#TODO standardize this
	sql_filepath = p.REPO_DIR_PATH + 'build_db/insert_player_game_opponent_args.sql'
	f = open(sql_filepath, 'r')
	sql_string = f.read()
	f.close()

	#SQL args?
	replay_p = pathlib.Path(replay_file_path)
	sql_args = {
		'dir_path' : replay_p.parent,
		'file_name' : replay_p.name,
	}
	
	# print(dir_path, file_name)
	con.execute(sql_string, sql_args)
	return


def run(
		mode,
		add_to_queue=None, 
		force_requeue=False,
		empty_queue=False,
		):

	p = Paths(mode=mode)

	if mode=='test':
		print("TEST MODE")

	parse_queue_path=p.PARSE_QUEUE_PATH 
	replay_dir_path=p.REPLAY_DIR_PATH
	db_path=p.RAW_DB_PATH
	parse_slp_js_path=p.PARSE_SLP_JS_PATH


	pq = ParseQueue(filepath=parse_queue_path, replay_dir_path=replay_dir_path)

	if empty_queue:
		pq.empty_queue()

	if add_to_queue:
		print("queue: {}".format(add_to_queue))
		pq.queue(add_to_queue, prepend=True, force_requeue=force_requeue)

	while len(pq.slp_dict['queue']) > 0:
		pq.parse_queue_pop()
		replay_file_path = pq.active_slp
		print(replay_file_path)

		arg_list = [db_path, replay_dir_path, replay_file_path]
		arg_list_wrapped = [ "'" + arg + "'" for arg in arg_list ]
		arg_str = " ".join(arg_list_wrapped)

		#insert raw data from parse_slp.js
		result = execute_js(file_path=parse_slp_js_path, arguments=arg_str)
		result_str = 'success' if result else 'failure'

		#update derived tables with another insert operation, using replay_file_path
		insert_derived(mode, replay_file_path)

		pq.parse_return(result_str)
		pq.save()


	print("Queue is empty")


if __name__ == '__main__':
	print(__name__)
	print(sys.argv)
	
	if sys.argv[1] == '-help':
		print("Arguments: <mode> [add_to_queue=None] [force_requeue=False] [empty_queue=False]")
		print("Example: parse .slp files in './onion_slp/', forcing re-runs")
		print("$python parse_runner.py test './onion_slp/' True")

	else:
		run(*sys.argv[1:5])