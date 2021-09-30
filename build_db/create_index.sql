-- Create Indexes
-- For raw and static tables only

select *
from sqlite_master
where type != 'table'
;

-- Raw

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

-- Character

create index if not exists dim_character_id
  on  dim_character (
    character_id
  )
;

create index if not exists dim_character_cover
  on  dim_character (
    character_id
  , character_name
  , character_name_short
  , tier_rank
  )
;

-- Character Color

create index if not exists dim_character_color_id
  on  dim_character_color (
    character_id
  , character_color
  )
;


-- Stage

create index if not exists dim_stage_id
  on  dim_stage (
    stage_id
  )
;

create index if not exists dim_stage_cover
  on  dim_stage (
    stage_id
  , is_standard
  , stage_name_short
  , stage_name
  )
;

-- Action State

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

-- Action State Character

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
