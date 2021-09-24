--create_player_game_opponent.sql

--filter on:
-- 2 human players
-- game length at least 30s
-- neutral stage

CREATE TABLE IF NOT EXISTS derived_player_game_opponent (
	game_id 	TEXT
,	last_frame 	INTEGER
,	stage_id 	INTEGER
,	dir_path 	TEXT
,	player_index 	INTEGER
,	character_id 	INTEGER
,	character_color 	INTEGER
,	connect_code 	TEXT
,	player_name 	TEXT
,	player_index_opp 	INTEGER
,	character_id_opp 	INTEGER
,	is_win 	INTEGER
,	stocks_remaining_winner 	INTEGER

, PRIMARY KEY (
		game_id
	,	player_index
	)
)
;

CREATE INDEX IF NOT EXISTS derived_player_game_opponent_cover1 
	ON derived_player_game_opponent (
		game_id
	,	stage_id
	,	player_index
	,	character_id
	,	player_name
	,	player_index_opp
	,	character_id_opp
	,	is_win
	)
;

CREATE INDEX IF NOT EXISTS derived_player_game_opponent_cover0 
	ON derived_player_game_opponent (
		game_id
	,	last_frame
	,	stage_id
	,	dir_path
	,	player_index
	,	character_id
	,	character_color
	,	connect_code
	,	player_name
	,	player_index_opp
	,	character_id_opp
	,	is_win
	,	stocks_remaining_winner
	)
;