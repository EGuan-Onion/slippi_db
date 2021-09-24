#first argument, relative dir path.  If empty, uses existing queue.
# To add all files from 'jwu_slp/2021-06/' to the queue and begin running
# $python parse_runner.py 'jwu_slp/2021-06/' production True

import sys

from Naked.toolshed.shell import execute_js

from paths import Paths
from parse_queue import ParseQueue

# Read the queue
# run parse_slp.js to process the .slp file and write to the database
# return status, update queue

def run(
		add_to_queue=None, 
		mode='test',
		force_requeue=False,
		reset_queue=False,
		):

	p = Paths(mode=mode)

	if mode=='test':
		print("TEST MODE")

	parse_queue_path=p.PARSE_QUEUE_PATH 
	replay_dir_path=p.REPLAY_DIR_PATH
	db_path=p.RAW_DB_PATH
	parse_slp_js_path=p.PARSE_SLP_JS_PATH


	pq = ParseQueue(filepath=parse_queue_path, replay_dir_path=replay_dir_path)

	if reset_queue:
		pq.slp_dict['queue'] = []
		# pq.init_empty_slp_dict()

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

		result = execute_js(file_path=parse_slp_js_path, arguments=arg_str)
		result_str = 'success' if result else 'failure'

		pq.parse_return(result_str)
		pq.save()


	print("Queue is empty")


if __name__ == '__main__':
	print(__name__)
	

	print(sys.argv)
	run(*sys.argv[1:5])