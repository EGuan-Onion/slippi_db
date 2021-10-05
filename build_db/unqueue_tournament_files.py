import sys
sys.path.append("/Users/eguan/slippi_db/")

from pathlib import Path

from parse_queue import ParseQueue
from paths import Paths

for mode in ('test', 'local', 'production'):
	print(mode)
	p = Paths(mode=mode)
	parse_queue_path = p.PARSE_QUEUE_PATH
	replay_dir_path = p.REPLAY_DIR_PATH

	pq = ParseQueue(parse_queue_path, replay_dir_path)

	for key in ['queue']:
		list_temp = pq.slp_dict[key]
		list_clean = [ s for s in list_temp if not Path(s).parts[0] == 'tournament' ]
		pq.slp_dict[key] = list_clean
	pq.save()