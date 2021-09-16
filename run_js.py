#! /usr/bin/python

from Naked.toolshed.shell import execute_js
import pathlib





# training_data
# # For `./replays/training_data`
# start_index = 19600
# stop_index = 95102



for dirpath in [
	# '"./replays/Summit-11/Day 1/"', 
	# '"./replays/Summit-11/Day 2/"', 
	# '"/Volumes/T7/Slippi/slippi_db/replays/original/"',
	# '"/Volumes/T7/Slippi/slippi_db/replays/training_data/"',
	'"/Volumes/T7/Slippi/slippi_db/replays/onion_slp/202006_to_202109/"',
	]:

	start_index = 0
	stop_index = 3870

	step_size = 1


	print(dirpath, start_index, stop_index)

	for x in range(start_index, stop_index, step_size):
		#arguments
		# dirpath = '"./replays/Summit-11/Day 2/"'
		step_start = str(x)
		step_end = str(min(x+step_size, stop_index))

		arg_list = [dirpath, step_start, step_end]
		arg_str = " ".join(arg_list)
		print(arg_str)

		success = execute_js(file_path="parse_slp.js", arguments=arg_str)
		if not success:
			print("Failure args: {}".format(arg_str))

	print("end")
