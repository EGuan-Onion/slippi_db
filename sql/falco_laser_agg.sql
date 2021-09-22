WITH rpfp AS (
	SELECT 
		game_id
	,	player_index
	,	character_id 
	,	action_state_id
	,	action_state_counter
	,	sum(1) as frame_count
	FROM	raw_player_frames_post  
	
	WHERE 	TRUE 
	    AND action_state_id = 345 --laser
	    AND (
	    		(character_id = 2  AND  action_state_counter = 5) --fox
    		OR  (character_id = 20  AND  action_state_counter = 8) --falco
		)
    GROUP BY
		game_id
	,	player_index
	,	character_id 
	,	action_state_id
	,	action_state_counter
)

SELECT 
	rpfp.character_id
,	rpfp.action_state_id
,	rpg.character_id as character_id_opp
,	dc.character_name
,	dco.character_name as character_name_opp
,	rg.stage_id
,	ds.stage_name
,	ds.stage_name_short
,	count(distinct rg.game_id) as game_count_distinct
,	count(rg.game_id) as game_count
,	sum(rg.last_frame) as frame_count
,	sum(frame_count) as laser_frame_count
FROM  rpfp

JOIN raw_player_games rpg
ON  rpg.game_id = rpfp.game_id
  AND rpg.player_index != rpfp.player_index

JOIN raw_games rg
ON  rg.game_id = rpfp.game_id

JOIN dim_stage ds 
ON  ds.stage_id = rg.stage_id

JOIN dim_character dc
ON  dc.character_id = rpfp.character_id

JOIN dim_character dco
ON  dco.character_id = rpg.character_id

WHERE 	TRUE 
    
GROUP BY
	rpfp.character_id
,	rpfp.action_state_id
,	rpg.character_id
,	dc.character_name
,	dco.character_name
,	rg.stage_id
,	ds.stage_name
,	ds.stage_name_short
