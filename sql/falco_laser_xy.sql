SELECT 
	rpfp.characterId
,   rpfp.actionStateId
,   rpfp.x
,   rpfp.y
, 	rpg.characterId as characterIdOpp
, 	dc.character_name
,	dco.character_name as character_name_opp
,	rg.stageId
,	ds.stage_name
,	ds.stage_name_short
,   count(distinct rg.gameId) as game_count
,   sum(frame_count) as frame_count
FROM  (
	SELECT 
		gameId
	,   playerIndex
	,	characterId 
	,	actionStateId
	,	actionStateCounter
	,	round(positionX/5)*5 as x
	,	round(positionY/0.5)*0.5 as y
	, 	sum(1) as frame_count
	FROM	raw_player_frames_post  
	
	WHERE 	TRUE 
	    AND characterId = 20
	    AND actionStateId = 345
	    AND actionStateCounter = 8
	    and positionY between -20 and 50
	    AND positionX between -60 and 60
    GROUP BY
		gameId
	,   playerIndex
	,	characterId 
	,	actionStateId
	, 	actionStateCounter
	,	round(positionY/0.5)*0.5
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
,   rpfp.x
,   rpfp.y
, 	rpg.characterId
, 	dc.character_name
,	dco.character_name
,	rg.stageId
,	ds.stage_name
,	ds.stage_name_short
