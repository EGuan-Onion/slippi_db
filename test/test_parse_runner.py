# test_parse_runner.py
import sys
sys.path.append("/Users/eguan/slippi_db/")

from parse_queue import ParseQueue
from paths import *
import parse_runner


#Clear queue
pq = ParseQueue(TEST_PARSE_QUEUE_PATH, TEST_REPLAY_DIR_PATH)
pq.init_empty_slp_dict()
pq.save()

#Parse Runner
parse_runner.run(add_to_queue='./', mode='test')
