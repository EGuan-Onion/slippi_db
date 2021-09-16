-- Positional data
-- X,Y of P1, X,Y of P2
-- Outcome data
-- net changes in % within the next... 2,5,10 seconds?
with g as (
	SELECT 	
		gameId
	,	lastFrame
	,	stageId
	from	raw_games rg 
	WHERE TRUE
	
)

, pg0 as (
	SELECT 
		gameId 
	, 	playerIndex 
	,	characterId
	, row_number() over (partition by gameId  order by characterId asc, playerIndex asc) as player 
	FROM  raw_player_games rpg 
	WHERE TRUE
--		AND gameId in ('00287747-7d2a-562a-86d8-3347a685b462','00481323-834e-549e-a823-3da932de49af','006c3a81-0559-5ab2-9229-54a922d71bb9','007d05bc-6553-5bcd-807b-fe0e1595d40f','00ebe897-d46c-51b9-93a0-fbfd42858e7d','00f1febf-9263-596f-a7d7-2979f7150e05','01210bb3-f502-5a78-ad8f-975eaf6b3e52','013eb14f-22ee-5913-bf3a-5cde645b6ca8','0158ef10-7df5-58ed-a889-b73d49b03cc4','0199cb8c-ff5e-55fb-994e-a15d350d33de')
)

, pg as (
	SELECT
		gameId
	,   max(CASE player WHEN 1 THEN playerIndex ELSE null END) as playerIndex1
	,   max(CASE player WHEN 1 THEN characterId ELSE null END) as characterId1
	,   max(CASE player WHEN 2 THEN playerIndex ELSE null END) as playerIndex2
	,   max(CASE player WHEN 2 THEN characterId ELSE null END) as characterId2
	FROM pg0
	GROUP BY
		gameId
		
)

, gpg as (
	SELECT 
		g.gameId
	,	g.lastFrame
	, 	g.stageId
	,	pg.playerIndex1
	,	pg.characterId1
	,	pg.playerIndex2
	,	pg.characterId2
	FROM  g
	JOIN  pg
	ON  g.gameId = pg.gameId
	
	-- filter down game sample size
	WHERE TRUE
		AND characterId1 = 2 -- Fox
		AND characterId2 = 9 -- Marth
		AND stageId = 31 --Battlefield
	LIMIT 1
)

, pfp as (
	SELECT 
		gameId
	,	playerIndex
	,	frame
	,	actionStateId 
	,	actionStateCounter 
	, 	positionX 
	,	positionY 
	,	percent 
	,	stocksRemaining 
	FROM  raw_player_frames_post rpfp 
	WHERE TRUE 
		AND frame >= 0
--		AND gameId in ('00287747-7d2a-562a-86d8-3347a685b462','00481323-834e-549e-a823-3da932de49af','006c3a81-0559-5ab2-9229-54a922d71bb9','007d05bc-6553-5bcd-807b-fe0e1595d40f','00ebe897-d46c-51b9-93a0-fbfd42858e7d','00f1febf-9263-596f-a7d7-2979f7150e05','01210bb3-f502-5a78-ad8f-975eaf6b3e52','013eb14f-22ee-5913-bf3a-5cde645b6ca8','0158ef10-7df5-58ed-a889-b73d49b03cc4','0199cb8c-ff5e-55fb-994e-a15d350d33de')
)


, frame as (
	select
		gpg.*
	,   pfp1.frame
	, 	pfp1.positionX as X1
	,	pfp1.positionY as Y1
	,	pfp1.percent as percent1
	,	pfp1.stocksRemaining as stocks1
	, 	pfp2.positionX as X2
	,	pfp2.positionY as Y2
	,	pfp2.percent as percent2
	,	pfp2.stocksRemaining as stocks2
	from  gpg
	
	join  pfp as pfp1
	on  gpg.gameId = pfp1.gameId
		AND gpg.playerIndex1 = pfp1.playerIndex
	
	join  pfp as pfp2
	on  gpg.gameId = pfp2.gameId
		AND gpg.playerIndex2 = pfp2.playerIndex
		AND pfp1.frame = pfp2.frame
)

, delta_5s as (
	select
		f0.*
	,	f5.percent1 - f0.percent1 as percent1_d5
	,	f5.stocks1 - f0.stocks1 as stocks1_d5
	,	f5.percent2 - f0.percent2 as percent2_d5
	,	f5.stocks2 - f0.stocks2 as stocks2_d5
	FROM frame f0
	join frame f5
	on  f0.gameId = f5.gameId
	AND (f0.frame + 5*60) = f5.frame
)

, agg as (
	SELECT 
		gameId
	,	characterId1
	, 	characterId2
	, 	stageId
	,	round(X1/5)*5 as X1
	,	round(Y1/5)*5 as Y1
	,	round(percent1/10)*10 as percent1
	,	round(X2/5)*5 as X2
	,	round(Y2/5)*5 as Y2
	,	round(percent2/10)*10 as percent1
	,	sum(percent1_d5)/sum(1) as percent1_d5
	,	sum(stocks1_d5)/sum(1) as stocks1_d5
	,	sum(percent2_d5)/sum(1) as percent2_d5
	,	sum(stocks2_d5)/sum(1) as stocks2_d5
	,	sum(1) as rowcount
	from  delta_5s
	group by
		1,2,3,4,5,6,7,8,9,10
)



, dim as (
	SELECT
		a.*
		, dc1.character_name as character_name1
		, dc2.character_name as character_name2
		, ds.stage_name
	FROM agg a
	
	LEFT JOIN  dim_character dc1 
	on  dc1.character_id  = a.characterId1
	
	LEFT JOIN  dim_character dc2
	on  dc2.character_id  = a.characterId2
	
	LEFT JOIN  dim_stage ds
	on  ds.stage_id  = a.stageId
)

SELECT 
	*
FROM dim
;
