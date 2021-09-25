import json
import pathlib
import random

# Example:
# ParseQueue(filepath=PARSE_QUEUE_PATH, replay_dir_path=REPLAY_DIR_PATH)

class ParseQueue:
	def __init__(self, filepath, replay_dir_path):
		self.filepath = filepath
		self.replay_dir_path = replay_dir_path
		# self.slp_dict
		# self.empty_slp_dict()
		try:
			self.open(filepath)
		except:
			self.empty_slp_dict()

		self.active_slp = None

		self.remove_duplicates()
		return

	## read the current log
	def open(self, filepath=None):
		if  not filepath:
			filepath = self.filepath
		f = open(filepath)
		data = json.load(f)
		f.close()
		self.slp_dict = data
		return self

	## save
	def save(self):
		self.cleanup()

		# create json object from dictionary
		slp_json = json.dumps(self.slp_dict)

		f = open(self.filepath,"w")
		f.write(slp_json)
		f.close()
		return self

	## get new .slp from a direcetory
	def queue(self, replay_dir='', recurse=True, prepend=False, force_requeue=False, shuffle=True):
		p = pathlib.Path(self.replay_dir_path+replay_dir)

		if recurse:
			path_list = p.rglob('*.slp')
		else:
			path_list = p.glob('*.slp')

		slp_list = [ str(path.relative_to(self.replay_dir_path)) for path in path_list ]

		if shuffle:
			random.seed(0)
			random.shuffle(slp_list)

		slp_list_old = [ slp for slp_list in self.slp_dict.values() for slp in slp_list ]
		slp_list_new = [ slp for slp in slp_list if slp not in slp_list_old]

		if force_requeue:
			slp_list_new = slp_list

		#since the queue pops from the end, 'prepending' really means putting at the end
		if prepend:
			self.slp_dict['queue'] = self.slp_dict['queue'] + slp_list_new
		else:
			self.slp_dict['queue'] = slp_list_new + self.slp_dict['queue']

		return self


	def parse_queue_pop(self):
		self.active_slp = self.slp_dict['queue'].pop()
		return self

	def parse_return(self, result):
		if not self.active_slp:
			print("ERROR: no active parsing slp file")
			return self

		if result not in ['success', 'failure']:
			print("ERROR: invalid result type.  Must be in ['success', 'failure']")
			return self

		self.slp_dict[result].append(self.active_slp)
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

	def remove_duplicates(self):
		#remove dupes within each list
		for key in ['queue', 'success', 'failure']:
			self.slp_dict[key] = list(set(self.slp_dict[key]))

		#remove queued values from success
		self.slp_dict['success'] = [ 
			slp for slp in self.slp_dict['success'] 
			if slp not in self.slp_dict['queue'] 
			]

		#remove successful runs or queued runs from failures
		self.slp_dict['failure'] = [ 
			slp for slp in self.slp_dict['failure'] 
			if slp not in self.slp_dict['success']  
			if slp not in self.slp_dict['queue'] 
			]
		return self

	def retry(self):
		self.slp_dict['queue'] += self.slp_dict['failure']
		self.slp_dict['failure'] = []
		return self


	def empty_slp_dict(self):
		self.slp_dict = {
			'queue': [],
			'success': [],
			'failure': [],
		}
		return self

	def empty_queue(self):
		self.slp_dict['queue'] = []
		return self