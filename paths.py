#filepaths
#mode in (test, local, production)

class Paths():
	def __init__(self, mode):
		self.REPO_DIR_PATH = "/Users/eguan/slippi_db/"
		self.STATIC_TABLE_DIR_PATH = self.REPO_DIR_PATH + "static_tables/"
		self.SQL_DIR_PATH = self.REPO_DIR_PATH + "sql/"
		self.TEST_DIR_PATH = self.REPO_DIR_PATH + "test/"
		self.PARSE_SLP_JS_PATH = self.REPO_DIR_PATH + "parse_slp.js"

		if  mode=="test":
			self.DIR_PATH = "/Users/eguan/slippi_db/test/"
			self.REPLAY_DIR_PATH = self.DIR_PATH + "replays/"
			self.RAW_DB_PATH = self.DIR_PATH + "db/raw_test.db"
			self.PARSE_QUEUE_PATH = self.DIR_PATH + "parse_queue_test.json"
			self.SQL_OUTPUT_DIR_PATH = self.DIR_PATH + "sql_output/"

		elif mode=="local":
			self.DIR_PATH = "/Users/eguan/Documents/slippi_db_local/"
			self.REPLAY_DIR_PATH = self.DIR_PATH + "replays/"
			self.RAW_DB_PATH = self.DIR_PATH + "db/raw_local.db"
			self.PARSE_QUEUE_PATH = self.DIR_PATH + "parse_queue.json"
			self.SQL_OUTPUT_DIR_PATH = self.DIR_PATH + "sql_output/"

		elif mode=="production":
			self.DIR_PATH = "/Volumes/T7/slippi_db/"
			self.REPLAY_DIR_PATH = self.DIR_PATH + "replays/"
			self.RAW_DB_PATH = self.DIR_PATH + "db/raw_prod.db"
			self.PARSE_QUEUE_PATH = self.DIR_PATH + "parse_queue.json"
			self.SQL_OUTPUT_DIR_PATH = self.DIR_PATH + "sql_output/"

		else:
			print("ERROR: Unrecognized mode.  Must be 'test' or 'local' or 'production'")

		return
