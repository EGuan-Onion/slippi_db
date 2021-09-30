

WITH pgo AS (
	SELECT
		game_id
	,	dir_path
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
	,	pfp.stocks_remaining as stocks
	,	pfp.action_state_id
	,	pfp.action_state_counter
	,	pfpo.percent as percent_opp
	,	pfpo.stocks_remaining as stocks_opp
	from  pgo
	
	join  pfp
	on  pgo.game_id = pfp.game_id
		AND pgo.player_index = pfp.player_index
	
	join  pfp as pfpo 
	on  pgo.game_id = pfpo.game_id
		AND pgo.player_index_opp = pfpo.player_index
		AND pfp.frame = pfpo.frame
)

, frame_throws as (
	select
		f.*
	from  frame f
	JOIN  dim_action_state_union dasu
	ON  f.character_id = dasu.character_id
	AND f.action_state_id = dasu.action_state_id

	WHERE  TRUE
		AND state_category = 'attack'
		AND attack_type = 'throw'
		AND action_state_counter < 2 -- counter has non-integer values here.  Probably due to weight-dependent throw speeds
)

, agg as (
	select
		dir_path
	,	stage_id
	,	connect_code
	,	player_name
	,	character_id
	,	character_id_opp
	,	round(X/20)*20 as X
	,	round(Y/20)*20 as Y
	,	stocks
	,	action_state_id
	,	round(percent_opp/5)*5 as percent_opp
	,	stocks_opp
	,	is_win
	,   sum(1) as rowcount
	from  frame_throws
	group by
		1,2,3,4,5,6,7,8,9,10,11
)


, dim as (
	select
		a.*
	,	ds.stage_name
	,	dc.character_name
	,	dco.character_name as character_name_opp
	,   dasu.state_name
	,	dasu.state_description 
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

	AND dc.tier_rank <= 13
	AND dco.tier_rank <= 13
)

select *
from  dim
