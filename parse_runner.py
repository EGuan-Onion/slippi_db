
from Naked.toolshed.shell import execute_js

from paths import REPLAY_DIR_PATH, RAW_DB_PATH
from parse_queue import ParseQueue

# Read the queue
# run parse_slp_single.js
# return values to the queue

pq = ParseQueue()

while len(pq.slp_dict['queue']) > 0:
	pq.parse_queue_pop()
	replay_file_path = pq.active_slp

	## Execeute Javascript
	js_file_path = "parse_slp.js"
	arg_list = [RAW_DB_PATH, REPLAY_DIR_PATH, replay_file_path]
	arg_list_wrapped = [ "'" + arg + "'" for arg in arg_list ]
	arg_str = " ".join(arg_list_wrapped)
	print(arg_str)

	result = execute_js(file_path=js_file_path, arguments=arg_str)
	result_str = 'success' if result else 'failure'
	print(result_str)

	pq.parse_return(result_str)
	pq.write_slp_log()