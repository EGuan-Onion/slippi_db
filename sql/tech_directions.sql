--TODO tech towards / away opp
-- X-coarseness

WITH pgo AS (
	SELECT
		game_id
	,	last_frame
	,	stage_id
	,	player_index
	,	character_id
	,	connect_code
	,	player_name
	,	player_index_opp
	,	character_id_opp
	,	is_win
	FROM 	derived_player_game_opponent
)

, pfp AS (
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


, frame AS (
	select
		pgo.*
	,   pfp.frame
	, 	pfp.position_x AS X
	,	pfp.position_y AS Y
	,	pfp.facing_direction
	,	pfp.stocks_remaining AS stocks
	,	pfp.action_state_id
	,	pfp.action_state_counter
	, 	pfpo.position_x AS X_opp
	,	pfpo.position_y AS Y_opp
	,	pfpo.percent AS percent_opp
	,	pfpo.stocks_remaining AS stocks_opp
	from  pgo
	
	join  pfp
	on  pgo.game_id = pfp.game_id
		AND pgo.player_index = pfp.player_index
	
	join  pfp AS pfpo 
	on  pgo.game_id = pfpo.game_id
		AND pgo.player_index_opp = pfpo.player_index
		AND pfp.frame = pfpo.frame
)

, frame_tech AS (
	select
		*
	from  frame
	where  TRUE
		AND action_state_id in (
				0183 --miss tech down
			,	0191 --miss tech up
			,	0199 --tech in place
			,	0200 --tech forward
			,	0201 --tech backward
			)

		AND action_state_counter = 0
)

, agg AS (
	select
		stage_id
	,	connect_code
	,	player_name
	,	character_id
	,	character_id_opp
	,	facing_direction
	,	X > X_opp as is_right_of_opp
	,	X > 0 as is_right_of_center
	,	round(X/20)*20 AS X
	,	round(Y/10)*10 AS Y
--	,	stocks
	,	action_state_id
	,	round(percent_opp/10)*10 AS percent_opp
--	,	stocks_opp
	,	is_win
	,   sum(1) AS rowcount
	from  frame_tech
	group by
		1,2,3,4,5,6,7,8,9,10,11,12
)


, dim AS (
	select
		a.*
	,	ds.stage_name
	,	dc.character_name
	,	dco.character_name AS character_name_opp
	,   dasu.state_name
	,	dasu.state_description 
	
	from agg a
	
	join dim_stage ds 
	on	ds.stage_id = a.stage_id
	
	join dim_character dc 
	on  dc.character_id = a.character_id
	
	join dim_character dco
	on  dco.character_id = a.character_id_opp
	
	left join dim_action_state_union dasu
	on  dasu.action_state_id = a.action_state_id
		and dasu.character_id = a.character_id
	
	where TRUE 
		AND dc.tier_rank <= 13
		AND dco.tier_rank <= 13
)

, dim_relabel AS (
	SELECT 
		dim.*
	,	CASE facing_direction
			WHEN 1 THEN	
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Right' -- facing-dependent
					WHEN 201 THEN 'Tech Left' -- facing-dependent
				ELSE '???' END
			WHEN -1 THEN
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Left' -- facing-dependent
					WHEN 201 THEN 'Tech Right' -- facing-dependent
				ELSE '???' END
		ELSE '???' END AS tech_left_right
	,	CASE (facing_direction * iif(is_right_of_opp, 1, -1))
			WHEN 1 THEN	
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Away' -- facing-dependent
					WHEN 201 THEN 'Tech Towards' -- facing-dependent
				ELSE '???' END
			WHEN -1 THEN
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Towards' -- facing-dependent
					WHEN 201 THEN 'Tech Away' -- facing-dependent
				ELSE '???' END
		ELSE '???' END AS tech_towards_away
	,	CASE (facing_direction * iif(is_right_of_center, 1, -1))
			WHEN 1 THEN	
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech to Edge' -- facing-dependent
					WHEN 201 THEN 'Tech to Center' -- facing-dependent
				ELSE '???' END
			WHEN -1 THEN
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech to Center' -- facing-dependent
					WHEN 201 THEN 'Tech to Edge' -- facing-dependent
				ELSE '???' END
		ELSE '???' END AS tech_center_edge
	FROM  dim
)

select *
from  dim_relabel
