import sys

from Naked.toolshed.shell import execute_js

from paths import REPLAY_DIR_PATH, RAW_DB_PATH, PARSE_QUEUE_PATH, PARSE_SLP_JS_PATH
from parse_queue import ParseQueue

# Read the queue
# run parse_slp_single.js
# return values to the queue

pq = ParseQueue(filepath=PARSE_QUEUE_PATH, replay_dir_path=REPLAY_DIR_PATH)

#first argument, relative dir path.  If empty, uses existing queue.
# EX: 'jwu_slp/2021-06/'
if len(sys.argv)>1:
	pq.queue(sys.argv[1], prepend=True)

while len(pq.slp_dict['queue']) > 0:
	pq.parse_queue_pop()
	replay_file_path = pq.active_slp
	print(replay_file_path)

	## Execeute Javascript
	js_file_path = PARSE_SLP_JS_PATH

	arg_list = [RAW_DB_PATH, REPLAY_DIR_PATH, replay_file_path]
	arg_list_wrapped = [ "'" + arg + "'" for arg in arg_list ]
	arg_str = " ".join(arg_list_wrapped)

	result = execute_js(file_path=js_file_path, arguments=arg_str)
	result_str = 'success' if result else 'failure'

	pq.parse_return(result_str)
	pq.save()

print("Queue is empty")
