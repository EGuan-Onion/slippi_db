

WITH pgo AS (
	SELECT
		game_id
	,	dir_path
	,	dir_path like '%Summit%' as is_summit
	,	last_frame
	,	stage_id
	,	player_index
	,	character_id
	,	character_color
	,	connect_code
	,	player_name
	,	player_index_opp
	,	character_id_opp
	,	is_win
	FROM 	derived_player_game_opponent
)

, pfp as (
	SELECT 
		game_id
	,	player_index
	,	frame
	,	action_state_id 
	,	action_state_counter 
	,	facing_direction -- 1 = right, -1 = left
	, 	position_x 
	,	position_y 
	,	percent 
	,	stocks_remaining 
	FROM  raw_player_frames_post rpfp 
	WHERE TRUE 
		AND frame >= 0
)


, frame as (
	select
		pgo.*
	,   pfp.frame
	, 	pfp.position_x as X
	,	pfp.position_y as Y
	,	pfp.facing_direction
	,	pfp.action_state_id
	,	pfp.action_state_counter
	,	pfp.stocks_remaining as stocks
	,	pfp.percent
	,	pfpo.stocks_remaining as stocks_opp
	,	pfpo.percent as percent_opp
	from  pgo
	
	join  pfp
	on  pgo.game_id = pfp.game_id
		AND pgo.player_index = pfp.player_index
	
	join  pfp as pfpo 
	on  pgo.game_id = pfpo.game_id
		AND pgo.player_index_opp = pfpo.player_index
		AND pfp.frame = pfpo.frame
)

, frame_attack as (
	select
		*
	from  frame
	join  dim_action_state_union dasu
	on  frame.action_state_id = dasu.action_state_id
	and frame.character_id = dasu.character_id 
	where  TRUE
		AND state_category = 'attack'
		AND attack_type != 'throw'  --TODO split throws, grabescape, and grabwhiff
		AND action_state_counter = 1
)

, agg as (
	select
		dir_path
	,	stage_id
	,	connect_code
	,	player_name
	,	is_summit
	,	character_id
	,   character_color
	,	character_id_opp
	,	facing_direction
	-- ,	round(X/20)*20 as X
	-- ,	round(Y/20)*20 as Y
	,	action_state_id
	,	stocks_opp
	,	round(percent/10)*10 as percent_opp
	, 	is_win
	,   sum(1) as rowcount
	from  frame_attack
	group by
		1,2,3,4,5,6,7,8,9,10,11,12,13
)


, dim as (
	select
		a.*
	,	ds.stage_name
	,	dc.character_name
	,	dco.character_name as character_name_opp
	,   dasu.state_name
	,	dasu.state_description 
	,	dasu.attack_type
	,	dasu.direction
	,	coalesce(player_name,
		CASE
		WHEN dir_path like '%tournament%' THEN 'Tourney Rando'
		WHEN connect_code is not null THEN 'Netplay Rando'
		WHEN dir_path like '%home/%' and connect_code is null 
			THEN  SUBSTR(dir_path,
				INSTR(dir_path, 'home/') + length('home/'),
				INSTR(SUBSTR(dir_path,
					INSTR(dir_path, 'home/') + length('home/')
				), '/')-1
			  ) || ' local play'
	    ELSE '???' END
	    ) as player_label
	
	from agg a
	
	join dim_stage ds 
	on	ds.stage_id = a.stage_id
	
	join dim_character dc 
	on  dc.character_id = a.character_id
	
	join dim_character dco
	on  dco.character_id = a.character_id_opp
	
	join dim_action_state_union dasu
	on  dasu.action_state_id = a.action_state_id
		and dasu.character_id = a.character_id
	
	where TRUE 
		AND dc.tier_rank <= 16 --Y.Link+
		AND dco.tier_grade <= 16
)

select * 
from dim