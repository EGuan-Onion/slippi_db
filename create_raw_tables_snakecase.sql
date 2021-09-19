-- CREATE Raw Tables


CREATE TABLE IF NOT EXISTS raw_games (
game_id TEXT
, file_name TEXT
-- getMetadata()
, start_at TEXT
, last_frame INTEGER
, played_on TEXT
-- getSettings()
, slp_version TEXT
, is_teams INTEGER
, is_pal 	INTEGER
, stage_id INTEGER
, scene INTEGER
, game_mode INTEGER
, dir_path TEXT

, PRIMARY KEY (
	game_id
	)
)
;

CREATE TABLE IF NOT EXISTS raw_player_games (
game_id TEXT
, player_index INTEGER
-- getSettings().players
, port INTEGER
, character_id INTEGER
, character_color INTEGER
, start_stocks INTEGER
, type INTEGER
, team_id INTEGER
, controller_fix TEXT
, nametag TEXT
, display_name TEXT
, connect_code TEXT

, PRIMARY KEY (
	game_id
	, player_index
	)
)
;



CREATE TABLE IF NOT EXISTS raw_player_frames_pre (
game_id TEXT
, player_index INTEGER
, frame INTEGER
-- player-game-level
, character_id INTEGER
-- getFrames()[i].players[j].pre
, is_follower INTEGER --may need to convert from bool
, seed INTEGER
, action_state_id INTEGER
, position_x REAL
, position_y REAL
, facing_direction INTEGER
, joystick_x REAL
, joystick_y REAL
, c_stick_x REAL
, c_stick_y REAL
, trigger REAL
, buttons INTEGER
, physical_buttons INTEGER
, physical_l_trigger REAL
, physical_r_trigger REAL
, percent REAL

, PRIMARY KEY (
	game_id
	, player_index
	, frame
	)
)
;



CREATE TABLE IF NOT EXISTS raw_player_frames_post (
game_id TEXT
, player_index INTEGER
, frame INTEGER
-- player-game-level
, character_id INTEGER
-- getFrames()[i].players[j].post
, is_follower INTEGER
, internal_character_id INTEGER
, action_state_id INTEGER
, position_x REAL
, position_y REAL
, facing_direction INTEGER
, percent REAL
, shield_size REAL
, last_attack_landed INTEGER
, current_combo_count INTEGER
, last_hit_by INTEGER
, stocks_remaining INTEGER
, action_state_counter REAL
, misc_action_state INTEGER
, is_airborne INTEGER
, last_ground_id INTEGER
, jumps_remaining INTEGER
, l_cancel_status INTEGER
, hurtbox_collision_state INTEGER
, self_induced_speeds_air_x REAL
, self_induced_speeds_y REAL
, self_induced_speeds_attack_x REAL
, self_induced_speeds_attack_y REAL
, self_induced_speeds_ground_x REAL
	
, PRIMARY KEY (
		game_id
		, player_index
		, frame
	)
)
;
