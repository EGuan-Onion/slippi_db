# test_parse_queue.py

from parse_queue import ParseQueue

replay_dir = 'Summit-11/Day 3'

pq = ParseQueue()
pq.init_empty_slp_dict()
print(pq.slp_dict)

pq.get_new_slp('Summit-11/Day 3')


pq.queue_new_slp()


pq.get_new_slp('Summit-11/Day 2')


print(pq.slp_dict)

pq.write_slp_log()
