-- Create Indexes

select *
from sqlite_master
where type != 'table'
;

create index if not exists raw_games_cover
  on raw_games (
  	game_id
  ,	last_frame
  ,	stage_id
  , dir_path
  )
;


create index if not exists raw_player_games_cover
  on raw_player_games (
  	game_id 
  , player_index 
  ,	character_id
  ,	character_color
  ,	nametag
  ,	display_name
  ,	connect_code
  )
;



create index if not exists raw_player_frames_post_cover
  on raw_player_frames_post (
  	game_id
  ,	player_index
  ,	frame
  ,	action_state_id 
  ,	action_state_counter 
  ,	facing_direction -- 1 = right, -1 = left
  , is_airborne
  , position_x 
  ,	position_y 
  ,	percent 
  ,	stocks_remaining
  )
;


create index if not exists dim_action_state_id
  on  dim_action_state (
    action_state_id
  )
;



create index if not exists dim_action_state_cover
  on  dim_action_state (
    action_state_id
  , state_name
  , state_description
  , state_category
  , attack_type
  , direction
  )
;


create index if not exists dim_action_state_character_id
  on  dim_action_state_character (
    character_id
  , action_state_id
  )
;



create index if not exists dim_action_state_character_cover
  on  dim_action_state_character (
    character_id
  , action_state_id
  , state_name
  , state_description
  , state_category
  , attack_type
  , direction
  )
;
