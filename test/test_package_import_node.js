const fs = require("fs");
const sqlite3 = require("sqlite3").verbose();
const uuid = require("uuid");
const process = require("process");

const { SlippiGame } = require("@slippi/slippi-js");