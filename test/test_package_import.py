#test package import

import sys
sys.path.append("/Users/eguan/slippi_db/")

import os
import pandas
import pathlib
import sqlite3
import random
from Naked.toolshed.shell import execute_js

import paths
import parse_queue
import parse_runner
import run_sql
import build_db.build_db

# node.js packages
execute_js('test/test_package_import_node.js')
execute_js('test/test_slippi.js')
