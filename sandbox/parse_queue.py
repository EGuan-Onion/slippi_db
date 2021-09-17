import json
import pathlib

#TODO - paths.py
DIR_PATH = "/Volumes/T7/slippi_db/"
REPLAY_DIR_PATH = DIR_PATH + "replays/"

# "/Volumes/T7/slippi_db/replays/Summit-11/"
# "/Volumes/T7/slippi_db/replays/Summit-11/Day 1"


# replay_dir = 'Summit-11/'


class ParseQueue:
	def __init__(self, filepath="slp_log.json", replay_dir_path=REPLAY_DIR_PATH):
		self.filepath = filepath
		self.replay_dir_path = replay_dir_path
		# self.slp_dict
		# self.init_empty_slp_dict()
		self.read_slp_log(filepath)
		self.active_slp = None
		return


	def init_empty_slp_dict(self):
		self.slp_dict = {
			'queue': [],
			'success': [],
			'failure': [],
			'excluded': [],
		}
		return self

	## read the current log
	def read_slp_log(self, filepath=None):
		if  not filepath:
			filepath = self.filepath
		f = open(filepath)
		data = json.load(f)
		f.close()
		self.slp_dict = data
		return self

	## save
	def write_slp_log(self):
		self.cleanup()

		# create json object from dictionary
		slp_json = json.dumps(self.slp_dict)

		f = open(self.filepath,"w")
		f.write(slp_json)
		f.close()
		return self

	## get new .slp from a direcetory
	def get_new_slp(self, replay_dir='', recurse=True):
		p = pathlib.Path(self.replay_dir_path+replay_dir)

		if recurse:
			path_list = p.rglob('*.slp')
		else:
			path_list = p.glob('*.slp')

		slp_list = [ str(path.relative_to(self.replay_dir_path)) for path in path_list ]

		slp_list_old = [ slp for slp_list in self.slp_dict.values() for slp in slp_list ]
		slp_list_new = [ slp for slp in slp_list if slp not in slp_list_old]

		self.slp_dict['new'] = slp_list_new

		return self

	def queue_new_slp(self, prepend=False):
		slp_list_new = self.slp_dict.pop('new', None)
		
		if prepend:
			self.slp_dict['queue'] = slp_list_new + self.slp_dict['queue']
		else:
			self.slp_dict['queue'] = self.slp_dict['queue'] + slp_list_new

		return self


	def parse_queue_pop(self):
		self.active_slp = self.slp_dict['queue'].pop()
		return

	def parse_return(self, status):
		if not self.active_slp:
			print("ERROR: no active parsing slp file")
			return self

		if status not in ['success', 'failure', 'excluded']:
			print("ERROR: invalid status type.  Must be in ['success', 'failure', 'excluded']")
			return self

		self.slp_dict[status].append(self.active_slp)
		self.active_slp = None

		return self

	def cleanup(self):
		# Clean up any active .slp parsing
		if self.active_slp:
			print("WARNING: active parsing file returned to queue. {}".format(self.active_slp))
			self.slp_dict['queue'].append(str(self.active_slp))
			self.active_slp = None

		# Clean up any new files not queued
		new_pop = self.slp_dict.pop('new', None)
		if new_pop:
			print("WARNING: {} files in 'new' removed".format(len(new_pop)))

		return self



# ## update new files
# def update_new_files(replay_dir, filepath="slp_log.json"):
# 	old_log = read_slp_log(filepath)
# 	new_log = get_slp_dir(replay_dir)

# 	for slp_file in new_log.keys():
# 		if not slp_file in old_log.keys():
# 			old_log[slp_file] = new_log[slp_file]

# 	write_log(old_log, filepath)
# 	return


## update processed

## run -- go thru queue, mark as processed when completed