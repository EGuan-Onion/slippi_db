#run_tests.py
import sys
import pathlib
from paths import Paths

def run():
	p = Paths(mode='test')
	test_path = p.TEST_DIR_PATH
	path_list = pathlib.Path(test_path).glob('*.py')

	for path in path_list:
		print(path.stem)
		exec(open(path).read())

if __name__ == '__main__':
	print(__name__)
	print(sys.argv)
	
	run()
	# if sys.argv[1] == '-help':
	# 	print("Arguments: (None)")
	# 	print("Example: run all tests in the test dir")
	# 	print("$python run_tests.py")

	# else:
	# 	run()