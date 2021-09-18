const fs = require("fs");
const sqlite3 = require("sqlite3").verbose();
const uuid = require("uuid");
const process = require("process");

const { SlippiGame } = require("@slippi/slippi-js");

const NAMESPACE = '00000000-0000-0000-0000-000000000000';


if (process.argv.length < 4) {
	console.log("ERR: Not Enough Argments")
}

const db_file_path = process.argv[2] 		// '/Volumes/T7/slippi_db/db/raw.db'
const replay_dir_path = process.argv[3] 	// '/Volumes/T7/slippi_db/replays/'
const replay_file_path = process.argv[4]	// 'Summit-11/Day 3/Game_20210718T000019.slp'


// connect to db
const db = new sqlite3.Database(db_file_path, (err) => {
  if (err) {
    console.error(err.message);
  }
  // console.log('Connected to the database.');
});


/////////////////////////////////////////////////
/////////////////// EXECUTE /////////////////////
/////////////////////////////////////////////////

db.serialize(() => {
	db.run("BEGIN TRANSACTION")
	ingest_slp(db, replay_dir_path, replay_file_path);
	db.run("COMMIT")
})


/////////////////////////////////////////////////

function ingest_slp(db, dir_path, file_path) {
	let file_path_full = dir_path.concat(file_path); // fix dir names missing '/'

	let game = new SlippiGame(file_path_full);
	let metadata = game.getMetadata();
	let settings = game.getSettings();

	// if fewer than 2 players, bail
	if (Object.keys(settings.players).length < 2) {
		console.log(file_path)
		console.log("ERROR - fewer than 2 players")
		return db
	}

	else if (Object.keys(settings.players).length > 2) {
		console.log(file_path)
		console.log("ERROR - more 2 players")
		return db
	}

	else {
		// create gameId uuid
		let settings_str = JSON.stringify(settings)
		let metadata_str = JSON.stringify(metadata)

		let hashstr = settings_str.concat(metadata_str)

		let gameId = uuid.v5(hashstr, NAMESPACE);

		//insert
		_insert_table_games(db, game, gameId, file_path_full)
		_insert_table_player_games(db, game, gameId)
		// _insert_table_player_frames_pre(db, game, gameId) #cut to save space
		_insert_table_player_frames_post(db, game, gameId)
	}
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
		replay_file_path,
		metadata.startAt,
		metadata.lastFrame,
		metadata.playedOn,
		settings.slpVersion,
		settings.isTeams,
		settings.isPAL,
		settings.stageId,
		settings.scene,
		settings.gameMode,
		replay_dir_path,
	];

	db.run(insert_sql, data_obj);

	data_obj = null;

	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_games(db, game, gameId) {
	// db.run("BEGIN TRANSACTION")

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

	// db.run("COMMIT")
	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_frames_pre(db, game, gameId) {
	// db.run("BEGIN TRANSACTION") //transaction

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

			data_obj = null //Trying to save memory. not sure if this works.
		}
	}

	// db.run("COMMIT")
	return db;
}

/////////////////////////////////////////////////////////

function _insert_table_player_frames_post(db, game, gameId) {
	// db.run("BEGIN TRANSACTION") //not running in sequence

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

			data_obj = null //Trying to save memory.  not sure if this helps.
		}
	}

	// db.run("COMMIT")
	return db;
}

