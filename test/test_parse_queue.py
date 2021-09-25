# test_parse_queue.py
import sys
sys.path.append("/Users/eguan/slippi_db/")

from parse_queue import ParseQueue
from paths import Paths

p = Paths(mode='test')
parse_queue_path = p.PARSE_QUEUE_PATH
replay_dir_path = p.REPLAY_DIR_PATH

pq = ParseQueue(parse_queue_path, replay_dir_path)

pq.empty_slp_dict()
pq.queue(replay_dir='foo', recurse=False)
print(pq.slp_dict)
pq.queue(force_requeue=True, shuffle=False)
print(pq.slp_dict)


pq.empty_slp_dict()
pq.save()