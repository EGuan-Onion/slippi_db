# test_parse_queue.py
import sys
sys.path.append("/Users/eguan/slippi_db/")

from parse_queue import ParseQueue
from paths import *

pq = ParseQueue(TEST_PARSE_QUEUE_PATH, TEST_REPLAY_DIR_PATH)

pq.init_empty_slp_dict()
# pq.queue()
pq.queue('')

print(pq.slp_dict)


pq.init_empty_slp_dict()
pq.save()