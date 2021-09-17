const fs = require("fs");
const sqlite3 = require("sqlite3").verbose();
const uuid = require("uuid");
const process = require("process");

const { SlippiGame } = require("@slippi/slippi-js");

const NAMESPACE = '00000000-0000-0000-0000-000000000000';



console.log(process.argv)

if (process.argv.length > 3) {
	var start = parseInt(process.argv[2])
	var end = parseInt(process.argv[3])
}


const replays_dir = "/Users/eguan/Slippi/training_data/"
const replays_filelist = fs.readdirSync(replays_dir).slice(30,50)