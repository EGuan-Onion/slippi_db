-- CREATE Raw Tables


CREATE TABLE IF NOT EXISTS raw_games (
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
;

CREATE TABLE IF NOT EXISTS raw_player_games (
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
;



CREATE TABLE IF NOT EXISTS raw_player_frames_pre (
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
;



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
;
