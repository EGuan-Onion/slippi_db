with dim_action_state_marth_union as (
	SELECT 
		9 as character_id
	  , *
	from  dim_action_state das 
	where action_state_id < 341
	
	UNION ALL
	
	SELECT
		*
	from  dim_action_state_marth dasm 
)


, g as (
	SELECT 	
		gameId
	,	lastFrame
	,	stageId
	, 	dirpath like '%Summit%' as is_summit
	from	raw_games rg 
	WHERE TRUE
	
)

, pg as (
	SELECT 
		gameId 
	, 	playerIndex 
	,	characterId
	,   characterColor
	,	nametag
	,	displayName
	,	connectCode
	FROM  raw_player_games rpg 
	WHERE TRUE
--		AND gameId in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
)

, pgo AS (
	SELECT 
		pg.*
	,	pgo.playerIndex
	,	pgo.characterIndex
	from  pg
	join pg  pgo
	on  pg.gameId = pgo.gameId
	AND pg.playerIndex != pgo.playerIndex
)



, gpg as (
	SELECT 
		g.gameId
	,	g.lastFrame
	, 	g.stageId
	,	g.is_summit
	,	pg.playerIndex
	,	pg.characterId
	,   pg.characterColor
	,	pg.connectCode
	,	pgo.playerIndex as playerIndexOpp
	,	pgo.characterId as characterIdOpp
	FROM  g
	
	JOIN  pg
	ON  g.gameId = pg.gameId
	JOIN pg  pgo
	
	on  pg.gameId = pgo.gameId
	AND pg.playerIndex != pgo.playerIndex
	
	-- filter down game sample size
	WHERE TRUE
		AND stageId in (2,3,8,28,31,32)
		AND pg.characterId = 9 --Marth
--		AND pg.gameId in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
)

, pfp as (
	SELECT 
		gameId
	,	playerIndex
	,	frame
	,	actionStateId 
	,	actionStateCounter 
	,	facingDirection -- 1 = right, -1 = left
	, 	positionX 
	,	positionY 
	,	percent 
	,	stocksRemaining 
	FROM  raw_player_frames_post rpfp 
	WHERE TRUE 
		AND frame >= 0
--		AND gameId in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
)


, frame as (
	select
		gpg.*
	,   pfp.frame
	, 	pfp.positionX as X
	,	pfp.positionY as Y
	,	pfp.facingDirection
	,	pfp.stocksRemaining as stocks
	,	pfp.actionStateId
	,	pfp.actionStateCounter
	,	pfp.percent
	,	pfpo.stocksRemaining as stocksOpp
--	,   min(pfp.stocksRemaining)=0 over (partition by gpg.gameId, gpg.playerIndex) as is_win
	from  gpg
	
	join  pfp
	on  gpg.gameId = pfp.gameId
		AND gpg.playerIndex = pfp.playerIndex
	
	join  pfp as pfpo 
	on  gpg.gameId = pfpo.gameId
		AND gpg.playerIndexOpp = pfpo.playerIndex
		AND pfp.frame = pfpo.frame
)

, frame_attack as (
	select
		*
	from  frame
	join  dim_action_state_marth_union das
	on  frame.actionStateId = das.action_state_id
	where  TRUE
		AND state_category = 'attack'
		AND actionStateCounter = 1
)

, agg as (
	select
		stageId
	,	CASE 
			WHEN connectCode != 'RELU#824' THEN 'Not Justin'
		ELSE connectCode END as connectCode
	,	is_summit
	,	characterId
	,   characterColor
	,	characterIdOpp
	,	facingDirection
	,	round(X/10)*10 as X
	,	round(Y/10)*10 as Y
--	,	stocks
	,	actionStateId
--	,	round(percent/10)*10 as percent
--	,	stocksOpp
	,   sum(1) as rowcount
	from  frame_attack
	group by
		1,2,3,4,5,6,7,8,9,10
)


, dim as (
	select
		a.*
	,	ds.stage_name
	,	dc.character_name
	,	dco.character_name as character_name_opp
	,   das.state_name
	,	das.state_description 
	,	das.attack_type
	,	das.direction
	
	from agg a
	
	join dim_stage ds 
	on	ds.stage_id = a.stageId
	
	join dim_character dc 
	on  dc.character_id = a.characterId
	
	join dim_character dco
	on  dco.character_id = a.characterIdOpp
	
	join dim_action_state_marth_union das 
	on  das.action_state_id = a.actionStateId
	
	where TRUE 
		AND dc.tier_rank <= 6
		AND dco.tier_rank <= 6
)

select * from dim