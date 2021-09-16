import json
import pathlib

## Handle Files


# maintain a log of all .slp files in './replays'
# All are marked as "TODO" or "Done"

## get all replay directories


# replay_dir = './replays/'
replay_dir = './replays/Summit-11/'



## Generate
# all dirs, recursive

def get_slp_dir(replay_dir):
	p = pathlib.Path(replay_dir)

	slp_dict = {
		str(x): {
			'status': 'unprocessed'
		}
		for x in p.glob('**/*.slp')
	}

	return slp_dict

## read the current log
def read_slp_log(filepath="slp_log.json"):
	f = open(filepath)
	data = json.load(f)
	f.close()
	return data

## save
def write_log(slp_dict, filepath="slp_log.json"):
	# create json object from dictionary
	json = json.dumps(slp_dict)

	f = open(filepath,"w")
	f.write(json)
	f.close()
	return


## update new files
def update_new_files(replay_dir, filepath="slp_log.json"):
	old_log = read_slp_log(filepath)
	new_log = get_slp_dir(replay_dir)

	for slp_file in new_log.keys():
		if not slp_file in old_log.keys():
			old_log[slp_file] = new_log[slp_file]

	write_log(old_log, filepath)
	return

## update queue
def queue_all_unprocessed(slp_dict):
	out = slp_dict
	for key in out.keys():
		if out[key]['status'] == 'unprocessed'
			out[key]['status'] = 'queued'
	return out

## queue everything in a directory
def queue_dir(slp_dict, replay_dir, force_rerun=False, recurse=False):
	out = slp_dict
	for key in out.keys():
		if pathlib.Path(key).parent == replay_dir:
			if  force_rerun || out[key]['status'] == 'unprocessed':
				out[key]['status'] = 'queued'
	return out


## update processed

## run -- go thru queue, mark as processed when completed