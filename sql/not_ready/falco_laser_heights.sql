SELECT 
	characterId
,	actionStateId
,	round(positionY/0.01)*0.01 as y
, 	sum(1) as frame_count
FROM	raw_player_frames_post rpfp 

LEFT JOIN	raw_games rg
ON  rg.gameId = rpfp.gameId

WHERE 	TRUE 
    AND characterId = 20
    AND actionStateId = 345
    AND actionStateCounter = 8
    AND stageId = 32
    and positionY between -4 and 14
    AND positionX between -20 and 20
    
GROUP BY
	characterId
,	actionStateId
,	round(positionY/0.01)*0.01