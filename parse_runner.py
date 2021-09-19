#first argument, relative dir path.  If empty, uses existing queue.
# To add all files from 'jwu_slp/2021-06/' to the queue and begin running
# $python parse_runner.py 'jwu_slp/2021-06/'
# To add all files from the test replay directory
# $python parse_runner.py './' test
# To resume processing the current queue (either works)
# $python parse_runner.py
# $python parse_runner.py None production

import sys

from Naked.toolshed.shell import execute_js

from paths import (
	REPLAY_DIR_PATH, 
	RAW_DB_PATH, 
	PARSE_QUEUE_PATH, 
	PARSE_SLP_JS_PATH,

	TEST_REPLAY_DIR_PATH, 
	TEST_RAW_DB_PATH, 
	TEST_PARSE_QUEUE_PATH, 
	TEST_PARSE_SLP_JS_PATH,
	)
from parse_queue import ParseQueue

# Read the queue
# run parse_slp.js to process the .slp file and write to the database
# return status, update queue

def run(
		add_to_queue=None, 
		mode='production',
		reset_queue=False,
		):

	if mode=='test':
		print("TEST MODE")
		parse_queue_path=TEST_PARSE_QUEUE_PATH
		replay_dir_path=TEST_REPLAY_DIR_PATH
		db_path=TEST_RAW_DB_PATH
		js_path=TEST_PARSE_SLP_JS_PATH

	elif mode=='production':
		parse_queue_path=PARSE_QUEUE_PATH
		replay_dir_path=REPLAY_DIR_PATH
		db_path=RAW_DB_PATH
		js_path=PARSE_SLP_JS_PATH

	else:
		print("unrecognized mode.  must be in ['test', 'production']")
		return

	pq = ParseQueue(filepath=parse_queue_path, replay_dir_path=replay_dir_path)

	if reset_queue:
		pq.init_empty_slp_dict()

	if add_to_queue:
		print("queue: {}".format(add_to_queue))
		pq.queue(add_to_queue, prepend=True)

	while len(pq.slp_dict['queue']) > 0:
		pq.parse_queue_pop()
		replay_file_path = pq.active_slp
		print(replay_file_path)

		arg_list = [db_path, replay_dir_path, replay_file_path]
		arg_list_wrapped = [ "'" + arg + "'" for arg in arg_list ]
		arg_str = " ".join(arg_list_wrapped)

		result = execute_js(file_path=js_path, arguments=arg_str)
		result_str = 'success' if result else 'failure'

		pq.parse_return(result_str)
		pq.save()


	print("Queue is empty")


if __name__ == '__main__':
	print(__name__)
	
	# add_to_queue = sys.argv[1] if len(sys.argv)>1 else None
	# mode = sys.argv[2] if len(sys.argv)>2 else None

	print(sys.argv)
	run(*sys.argv[1:4])
	# run(add_to_queue=add_to_queue, mode=mode)