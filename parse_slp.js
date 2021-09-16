const fs = require("fs");
const sqlite3 = require("sqlite3").verbose();
const uuid = require("uuid");
const process = require("process");

const { SlippiGame } = require("@slippi/slippi-js");

const NAMESPACE = '00000000-0000-0000-0000-000000000000';



console.log("running from Local Macbook")
// get current directory
// const replays_dir = "./replays_batch_20210710/"
// const replays_dir = "/Users/eguan/Slippi/slippi_db/replays/Summit11/"
// const replays_dir = "/Users/eguan/Slippi/jwu_slp/2021-05/"

if (process.argv.length < 4) {
	console.log("ERR: Not Enough Argments")
}

// get file_start and file_end
const replays_dir = process.argv[2]
const replays_filelist_full = fs.readdirSync(replays_dir)

const file_start = Math.max(parseInt(process.argv[3]), 0)
const file_end = Math.min(parseInt(process.argv[4]), replays_filelist_full.length)


console.log(file_start)

const replays_filelist = replays_filelist_full.slice(file_start,file_end)

// const db_filepath = './raw.db'
const db_filepath = '/Volumes/T7/Slippi/slippi_db/raw.db'

// //filename for testing
// const filename_test = 'Game_20210615T212018.slp';
// const game_test = new SlippiGame(replays_dir.concat(filename_test));

// connect tp db
const db = new sqlite3.Database(db_filepath, (err) => {
  if (err) {
    console.error(err.message);
  }
  // console.log('Connected to the database.');
});


/////////////////////////////////////////////////
/////////////////// EXECUTE /////////////////////
/////////////////////////////////////////////////

db.serialize(() => {
	create_tables(db, drop=false);

  db.parallelize(() => {
		for (filename of replays_filelist) {
			ingest_slp(db, filename);
		}
  })


	// check output
	// var table_name = 'raw_games';
	// db.all(`SELECT * FROM ${table_name}`, [], (err, rows) => {
	// 	rows.forEach((row) =>{
	// 		console.log(row)
	// 	})
	// })


	db.close()
})

/////////////////////////////////////////////////

function create_tables(db, drop=false) {
	_create_table_games(db, drop);
	_create_table_player_games(db, drop);
	// _create_table_player_frames_pre(db, drop); #cut to save space
	_create_table_player_frames_post(db, drop);
	
	return db;
}

/////////////////////////////////////////////////

function ingest_slp(db, filename) {
	let game = new SlippiGame(replays_dir.concat(filename));
	let metadata = game.getMetadata();
	let settings = game.getSettings();

	// if fewer than 2 players, bail
	if (Object.keys(settings.players).length < 2) {
		console.log(filename)
		console.log("ERROR - fewer than 2 players")
		return db
	}

	else if (Object.keys(settings.players).length > 2) {
		console.log(filename)
		console.log("ERROR - more 2 players")
		return db
	}

	else {
		// create gameId uuid
		let settings_str = JSON.stringify(settings)
		let metadata_str = JSON.stringify(metadata)

		let hashstr = settings_str.concat(metadata_str)

		let gameId = uuid.v5(hashstr, NAMESPACE);

		// insert games
		_insert_table_games(db, game, gameId, filename)
		_insert_table_player_games(db, game, gameId)
		// _insert_table_player_frames_pre(db, game, gameId) #cut to save space
		_insert_table_player_frames_post(db, game, gameId)

		console.log(filename)
	}
	return db;
}

/////////////////////////////////////////////////
//////////////// CREATE TABLES //////////////////
/////////////////////////////////////////////////

function _create_table_games(db, drop=false) {
	let table_name = 'raw_games';

	let create_sql = `
		CREATE TABLE IF NOT EXISTS ${table_name} (
			gameId TEXT
		, filename TEXT
		-- getMetadata()
		, startAt TEXT
		, lastFrame INTEGER
		, playedOn TEXT
		-- getSettings()
		, slpVersion TEXT
		, isTeams INTEGER
		, isPAL 	INTEGER
		, stageId INTEGER
		, scene INTEGER
		, gameMode INTEGER
		, dirpath TEXT

		, PRIMARY KEY (
				gameId
			)
		)
	`

	db.serialize(() => {
		if (drop) {
		  // drop table
		  db.run(`DROP TABLE IF EXISTS ${table_name}`)
	  }

		db.run(create_sql)
	})
	return db
}

/////////////////////////////////////////////////////////

function _create_table_player_games(db, drop=false) {
	let table_name = 'raw_player_games';

	let create_sql = `
		CREATE TABLE IF NOT EXISTS ${table_name} (
			gameId TEXT
		, playerIndex INTEGER
		-- getSettings().players
		, port INTEGER
		, characterId INTEGER
		, characterColor INTEGER
		, startStocks INTEGER
		, type INTEGER
		, teamId INTEGER
		, controllerFix TEXT
		, nametag TEXT
		, displayName TEXT
		, connectCode TEXT

		, PRIMARY KEY (
				gameId
			, playerIndex
			)
		)
	`;

	db.serialize(() => {
		if (drop) {
		  // drop table
		  db.run(`DROP TABLE IF EXISTS ${table_name}`)
	  }

		db.run(create_sql)
	})

	return db;
}

/////////////////////////////////////////////////////////

function _create_table_player_frames_pre(db, drop=false) {
	let table_name = 'raw_player_frames_pre';

	let create_sql = `
		CREATE TABLE IF NOT EXISTS  ${table_name} (
			gameId TEXT
		, playerIndex INTEGER
		, frame INTEGER
		-- player-game-level
		, characterId INTEGER
		-- getFrames()[i].players[j].pre
	  , isFollower INTEGER --may need to convert from bool
	  , seed INTEGER
	  , actionStateId INTEGER
	  , positionX REAL
	  , positionY REAL
	  , facingDirection INTEGER
	  , joystickX REAL
	  , joystickY REAL
	  , cStickX REAL
	  , cStickY REAL
	  , trigger REAL
	  , buttons INTEGER
	  , physicalButtons INTEGER
	  , physicalLTrigger REAL
	  , physicalRTrigger REAL
	  , percent REAL
		
		, PRIMARY KEY (
				gameId
			, playerIndex
			, frame
			)
		)
	`

	db.serialize(() => {
		if (drop) {
		  // drop table
		  db.run(`DROP TABLE IF EXISTS ${table_name}`)
	  }

		db.run(create_sql)
	})

	return db;
}

/////////////////////////////////////////////////////////

function _create_table_player_frames_post(db, drop=false) {
	let table_name = 'raw_player_frames_post';

	let create_sql = `
		CREATE TABLE IF NOT EXISTS raw_player_frames_post (
			gameId TEXT
		, playerIndex INTEGER
		, frame INTEGER
		-- player-game-level
		, characterId INTEGER
		-- getFrames()[i].players[j].post
	  , isFollower INTEGER
	  , internalCharacterId INTEGER
	  , actionStateId INTEGER
	  , positionX REAL
	  , positionY REAL
	  , facingDirection INTEGER
	  , percent REAL
	  , shieldSize REAL
	  , lastAttackLanded INTEGER
	  , currentComboCount INTEGER
	  , lastHitBy INTEGER
	  , stocksRemaining INTEGER
	  , actionStateCounter REAL
	  , miscActionState INTEGER
	  , isAirborne INTEGER
	  , lastGroundId INTEGER
	  , jumpsRemaining INTEGER
	  , lCancelStatus INTEGER
	  , hurtboxCollisionState INTEGER
	  , selfInducedSpeedsAirX REAL
	  , selfInducedSpeedsY REAL
	  , selfInducedSpeedsAttackX REAL
	  , selfInducedSpeedsAttackY REAL
	  , selfInducedSpeedsGroundX REAL
			
			, PRIMARY KEY (
					gameId
				, playerIndex
				, frame
			)
		)
	`

	db.serialize(() => {
		if (drop) {
		  // drop table
		  db.run(`DROP TABLE IF EXISTS ${table_name}`)
	  }

		db.run(create_sql)
	})

	return db;
}


/////////////////////////////////////////////////////////
/////////////////////  INSERT  //////////////////////////
/////////////////////////////////////////////////////////

function _insert_table_games(db, game, gameId, filename) {
	let table_name = 'raw_games';

	let insert_sql = `
		REPLACE INTO ${table_name} (
			gameId
		, filename
		-- getMetadata()
		, startAt
		, lastFrame
		, playedOn
		-- getSettings()
		, slpVersion
		, isTeams
		, isPAL 
		, stageId
		, scene
		, gameMode
		, dirpath
		)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
	`;

	let metadata = game.getMetadata();
	let settings = game.getSettings();

	let data_obj = [
		gameId,
		filename,
		metadata.startAt,
		metadata.lastFrame,
		metadata.playedOn,
		settings.slpVersion,
		settings.isTeams,
		settings.isPAL,
		settings.stageId,
		settings.scene,
		settings.gameMode,
		replays_dir,
	];

	db.run(insert_sql, data_obj);

	data_obj = null;

	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_games(db, game, gameId) {

	let table_name = 'raw_player_games';

	let insert_sql = `
		REPLACE INTO ${table_name} (
			gameId
		, playerIndex
		-- getSettings().players
		, port
		, characterId
		, characterColor
		, startStocks
		, type
		, teamId
		, controllerFix
		, nametag
		, displayName
		, connectCode
		)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
	`;

	let metadata = game.getMetadata();
	let settings = game.getSettings();

	for (key of Object.keys(settings.players)) {
		let data_obj = [
			gameId,
			settings.players[key].playerIndex, 
			settings.players[key].port, 
			settings.players[key].characterId,
			settings.players[key].characterColor,
			settings.players[key].startStocks,
			settings.players[key].type,
			settings.players[key].teamId,
			settings.players[key].controllerFix,
			settings.players[key].nametag,
			settings.players[key].displayName,
			settings.players[key].connectCode,
		];

		db.run(insert_sql, data_obj);
		
		data_obj = null
	}


	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_frames_pre(db, game, gameId) {

	let table_name = 'raw_player_frames_pre';

	let insert_sql = `
		REPLACE INTO ${table_name} (
			gameId
		, playerIndex
		, frame
		-- player-game-level
		, characterId
		-- getFrames()[i].players[j].pre
	  , isFollower
	  , seed
	  , actionStateId
	  , positionX
	  , positionY
	  , facingDirection
	  , joystickX
	  , joystickY
	  , cStickX
	  , cStickY
	  , trigger
	  , buttons
	  , physicalButtons
	  , physicalLTrigger
	  , physicalRTrigger
	  , percent
		)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
	`;

	// let metadata = game.getMetadata();
	let settings = game.getSettings();
	let frames = game.getFrames();

	db.run("BEGIN TRANSACTION") //transaction

	for (frames_key of Object.keys(frames)) {

		for (player of settings.players) {
			let playerIndex = player.playerIndex
			let pre = frames[frames_key].players[playerIndex].pre

			let data_obj = [
				gameId,
		    pre.playerIndex,
		    pre.frame,
				player.characterId,
		    pre.isFollower,
		    pre.seed,
		    pre.actionStateId,
		    pre.positionX,
		    pre.positionY,
		    pre.facingDirection,
		    pre.joystickX,
		    pre.joystickY,
		    pre.cStickX,
		    pre.cStickY,
		    pre.trigger,
		    pre.buttons,
		    pre.physicalButtons,
		    pre.physicalLTrigger,
		    pre.physicalRTrigger,
		    pre.percent,
			];

			db.run(insert_sql, data_obj)

			data_obj = null
		}
	}

	db.run("COMMIT") //transaction

	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_frames_post(db, game, gameId) {

	let table_name = 'raw_player_frames_post';

	let insert_sql = `
		REPLACE INTO ${table_name} (
			gameId
		, playerIndex
		, frame
		-- player-game-level
		, characterId
		-- getFrames()[i].players[j].post
	  , isFollower
	  , internalCharacterId
	  , actionStateId
	  , positionX
	  , positionY
	  , facingDirection
	  , percent
	  , shieldSize
	  , lastAttackLanded
	  , currentComboCount
	  , lastHitBy
	  , stocksRemaining
	  , actionStateCounter
	  , miscActionState
	  , isAirborne
	  , lastGroundId
	  , jumpsRemaining
	  , lCancelStatus
	  , hurtboxCollisionState
	  , selfInducedSpeedsAirX
	  , selfInducedSpeedsY
	  , selfInducedSpeedsAttackX
	  , selfInducedSpeedsAttackY
	  , selfInducedSpeedsGroundX
		)
		VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
	`;

	// let metadata = game.getMetadata();
	let settings = game.getSettings();
	let frames = game.getFrames();


	db.run("BEGIN TRANSACTION")

	for (frames_key of Object.keys(frames)) {

		for (player of settings.players) {
			let playerIndex = player.playerIndex
			if (frames[frames_key].players[playerIndex] === null) {
				console.log("ERR: playerIndex is null")
				return db;
			}

			let post = frames[frames_key].players[playerIndex].post

			let data_obj = [
				gameId,
				post.playerIndex,
		    post.frame,
				player.characterId,
				post.isFollower,
				post.internalCharacterId,
				post.actionStateId,
				post.positionX,
				post.positionY,
				post.facingDirection,
				post.percent,
				post.shieldSize,
				post.lastAttackLanded,
				post.currentComboCount,
				post.lastHitBy,
				post.stocksRemaining,
				post.actionStateCounter,
				post.miscActionState,
				post.isAirborne,
				post.lastGroundId,
				post.jumpsRemaining,
				post.lCancelStatus,
				post.hurtboxCollisionState,
				post.selfInducedSpeeds.airX,
				post.selfInducedSpeeds.y,
				post.selfInducedSpeeds.attackX,
				post.selfInducedSpeeds.attackY,
				post.selfInducedSpeeds.groundX,
			];

			db.run(insert_sql, data_obj)

			data_obj = null
		}
	}
	db.run("COMMIT")

	return db;
}

