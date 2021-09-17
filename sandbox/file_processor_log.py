import json
import pathlib

#TODO - paths.py
DIR_PATH = "/Volumes/T7/slippi_db/"
REPLAY_DIR_PATH = DIR_PATH + "replays/"



replay_dir = 'Summit-11/'



## Generate
# all dirs, recursive

def init_slp_dict():
	slp_dict = {
		'queue': [],
		'done': [],
		'failed': [],
		'excluded': [],
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





def _get_new_slp(slp_dict, replay_dir='', replay_dir_path=REPLAY_DIR_PATH, recurse=True):
	p = pathlib.Path(replay_dir_path+replay_dir)

	if recurse:
		slp_list = p.rglob('*.slp')
	else:
		slp_list = p.glob('*.slp')

	slp_list_old = [ slp for slp_list in slp_dict.values() for slp in slp_list ]
	slp_list_new = [ slp for slp in slp_list if slp not in slp_list_old]

	return slp_list_new

def queue_new_slp(slp_dict, replay_dir='', replay_dir_path=REPLAY_DIR_PATH, recurse=True, prepend=False):
	slp_list_new = _get_new_slp(slp_dict, replay_dir='', replay_dir_path=REPLAY_DIR_PATH, recurse=True)
	
	if prepend:
		slp_dict['queue'].reverse()
		slp_dict['queue'].append(slp_list_new)
		slp_dict['queue'].reverse()
	else:
		slp_dict['queue'].append(slp_list_new)

	return slp_dict


## update new files
def update_new_files(replay_dir, filepath="slp_log.json"):
	old_log = read_slp_log(filepath)
	new_log = get_slp_dir(replay_dir)

	for slp_file in new_log.keys():
		if not slp_file in old_log.keys():
			old_log[slp_file] = new_log[slp_file]

	write_log(old_log, filepath)
	return


## update processed

## run -- go thru queue, mark as processed when completed