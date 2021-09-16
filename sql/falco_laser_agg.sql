SELECT 
	rpfp.characterId
,   rpfp.actionStateId
, 	rpg.characterId as characterIdOpp
, 	dc.character_name
,	dco.character_name as character_name_opp
,	rg.stageId
,	ds.stage_name
,	ds.stage_name_short
,   count(distinct rg.gameId) as game_count_distinct
,   count(rg.gameId) as game_count
, 	sum(rg.lastFrame) as frame_count
,   sum(frame_count) as laser_frame_count
FROM  (
	SELECT 
		gameId
	,   playerIndex
	,	characterId 
	,	actionStateId
	,	actionStateCounter
	, 	sum(1) as frame_count
	FROM	raw_player_frames_post  
	
	WHERE 	TRUE 
	    AND actionStateId = 345
	    AND (
	    		(characterId = 2  AND  actionStateCounter = 5)
    		OR  (characterId = 20  AND  actionStateCounter = 8)
		)
    GROUP BY
		gameId
	,   playerIndex
	,	characterId 
	,	actionStateId
	, 	actionStateCounter
) rpfp

JOIN 	raw_player_games rpg
ON  rpg.gameId = rpfp.gameId
  AND rpg.playerIndex != rpfp.playerIndex

JOIN	raw_games rg
ON  rg.gameId = rpfp.gameId

JOIN   dim_stage ds 
ON  ds.stage_id = rg.stageId

JOIN   dim_character dc
ON  dc.character_id = rpfp.characterId

JOIN   dim_character dco
ON  dco.character_id = rpg.characterId

WHERE 	TRUE 
    
GROUP BY
	rpfp.characterId
,   rpfp.actionStateId
, 	rpg.characterId
, 	dc.character_name
,	dco.character_name
,	rg.stageId
,	ds.stage_name
,	ds.stage_name_short
