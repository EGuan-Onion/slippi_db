# test_parse_runner.py
import sys
sys.path.append("/Users/eguan/slippi_db/")

from parse_queue import ParseQueue
from paths import Paths
import parse_runner


p = Paths(mode='test')
parse_queue_path = p.PARSE_QUEUE_PATH
replay_dir_path = p.REPLAY_DIR_PATH

#Clear queue
pq = ParseQueue(parse_queue_path, replay_dir_path)
pq.empty_slp_dict()
pq.save()

#Parse Runner
parse_runner.run(add_to_queue='./', mode='test')
