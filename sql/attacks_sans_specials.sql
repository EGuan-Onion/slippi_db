-- NOT YET DONE
with dim_action_state_union as (
	SELECT 
		character_id
	  , *
	from  dim_action_state das 
	
	CROSS JOIN  dim_character dc
	
	where action_state_id < 341
	  and tier_rank <= 6
)


, g as (
	SELECT 	
		game_id
	,	last_frame
	,	stage_id
	, 	dir_path like '%Summit%' as is_summit
	from	raw_games rg 
	WHERE TRUE
	
)

, pg as (
	SELECT 
		game_id 
	, 	player_index 
	,	character_id
	,   character_color
	,	nametag
	,	display_name
	,	connect_code
	FROM  raw_player_games rpg 
	WHERE TRUE
--		AND game_id in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
)

, pgo AS (
	SELECT 
		pg.*
	,	pgo.player_index
	,	pgo.character_index
	from  pg
	join pg  pgo
	on  pg.game_id = pgo.game_id
	AND pg.player_index != pgo.player_index
)



, gpg as (
	SELECT 
		g.game_id
	,	g.last_frame
	, 	g.stage_id
	,	g.is_summit
	,	pg.player_index
	,	pg.character_id
	,   pg.character_color
	,	pg.connect_code
	,	pgo.player_index as player_index_opp
	,	pgo.character_id as character_id_opp
	FROM  g
	
	JOIN  pg
	ON  g.game_id = pg.game_id
	JOIN pg  pgo
	
	on  pg.game_id = pgo.game_id
	AND pg.player_index != pgo.player_index
	
	-- filter down game sample size
	WHERE TRUE
		AND stage_id in (2,3,8,28,31,32)
		-- AND pg.character_id = 9 --Marth
--		AND pg.game_id in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
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
--		AND game_id in ('6c298400-4c88-5c07-8ca7-1902bbc0cb20', '99f7aa0e-2691-5ad2-8c26-090185cdcf06')
)


, frame as (
	select
		gpg.*
	,   pfp.frame
	, 	pfp.position_x as X
	,	pfp.position_y as Y
	,	pfp.facing_direction
	,	pfp.stocks_remaining as stocks
	,	pfp.action_state_id
	,	pfp.action_state_counter
	,	pfp.percent
	,	pfpo.stocks_remaining as stocks_opp
--	,   min(pfp.stocks_remaining)=0 over (partition by gpg.game_id, gpg.player_index) as is_win
	from  gpg
	
	join  pfp
	on  gpg.game_id = pfp.game_id
		AND gpg.player_index = pfp.player_index
	
	join  pfp as pfpo 
	on  gpg.game_id = pfpo.game_id
		AND gpg.player_index_opp = pfpo.player_index
		AND pfp.frame = pfpo.frame
)

, frame_attack as (
	select
		*
	from  frame
	join  dim_action_state_union das
	on  frame.action_state_id = das.action_state_id
	and frame.character_id = das.character_id 
	where  TRUE
		AND state_category = 'attack'
		AND action_state_counter = 1
)

, agg as (
	select
		stage_id
	,	CASE 
			WHEN connect_code in ('RELU#824', 'EG#164', 'EG#0', 'DAKO#725', 'DAK#0') THEN connect_code
		ELSE 'Netplay Rando' END AS connect_code
	,	is_summit
	,	character_id
	,   character_color
	,	character_id_opp
	,	facing_direction
	,	round(X/20)*20 as X
	,	round(Y/20)*20 as Y
--	,	stocks
	,	action_state_id
--	,	round(percent/10)*10 as percent
--	,	stocks_opp
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
	on	ds.stage_id = a.stage_id
	
	join dim_character dc 
	on  dc.character_id = a.character_id
	
	join dim_character dco
	on  dco.character_id = a.character_id_opp
	
	join dim_action_state_union das 
	on  das.action_state_id = a.action_state_id
		and das.character_id = a.character_id
	
	where TRUE 
		AND dc.tier_rank <= 6
		AND dco.tier_rank <= 6
)

select * from dim