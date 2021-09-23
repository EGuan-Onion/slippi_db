--create_player_game_opponent.sql

CREATE TABLE IF NOT EXISTS derived_player_game_opponent (
		game_id
	,	last_frame
	, stage_id
	,	dir_path --more?
	,	player_index
	,	character_id
	, character_color
	,	connect_code
	,	player_index_opp
	,	character_id_opp
	,	character_color_opp
	, connect_code_opp
	-- winner
	-- player_id

, PRIMARY KEY (
		game_id
	,	player_index
	)
)
;

--two-player-only
