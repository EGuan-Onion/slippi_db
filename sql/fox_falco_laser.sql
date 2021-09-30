
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
	WHERE	TRUE
		AND character_id in (2,20) --Fox, Falco
)


, lasers AS (
	SELECT 
		game_id
	,	player_index
	-- ,	rpfp.action_state_id
	,	sum(1) as laser_count
	FROM	raw_player_frames_post  rpfp

	JOIN  dim_action_state_union dasu
	ON  dasu.character_id = rpfp.character_id
	AND dasu.action_state_id = rpfp.action_state_id
	
	WHERE TRUE 
		AND state_name like 'Blaster%Loop'
		-- AND rpfp.character_id in (2,20) --Fox, Falco
		-- AND rpfp.action_state_id in (342, 345) --Ground laser, air laser
		AND (	(rpfp.character_id = 2  AND  action_state_counter = 5) --fox laser comes out on frame 5
			OR  (rpfp.character_id = 20  AND  action_state_counter = 8) --falco falco laser comes out on frame 8
		)

	GROUP BY
		1,2
)


, pgo_lasers AS (
	SELECT 
		pgo.*
	,	laser_count
	FROM pgo

	JOIN  lasers
	ON  pgo.game_id = lasers.game_id
	  AND pgo.player_index = lasers.player_index
)

, agg AS (
	SELECT
		dir_path
	, connect_code
	,	player_name
	,	character_id
	,	character_id_opp
	,	stage_id
	,	sum(1) as game_count
	,	sum(last_frame) as frame_count
	,	sum(laser_count) as laser_count
	FROM pgo_lasers
	GROUP BY
		1,2,3,4,5,6
)

, dim AS (

	SELECT
		agg.*
	,	dc.character_name
	,	dco.character_name as character_name_opp
	,	ds.stage_name
	,	ds.stage_name_short
	-- ,	dasu.state_name
	-- ,	dasu.state_description
	-- ,	dasu.state_category
	-- ,	dasu.attack_type
	-- ,	dasu.direction
  , coalesce(player_name,
      CASE
        WHEN dir_path like '%tournament%' THEN 'Tourney Rando'
        WHEN connect_code is not null THEN 'Netplay Rando'
      ELSE '???' END
    ) as player_label
	FROM agg

	JOIN dim_stage ds 
	ON  ds.stage_id = agg.stage_id

	JOIN dim_character dc
	ON  dc.character_id = agg.character_id

	JOIN dim_character dco
	ON  dco.character_id = agg.character_id_opp

	-- JOIN dim_action_state_union dasu
	-- ON 	dasu.character_id = agg.character_id
	-- 	AND dasu.action_state_id = agg.action_state_id

	WHERE 	TRUE 
)

SELECT *
FROM dim

