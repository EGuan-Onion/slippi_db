INSERT OR REPLACE INTO derived_player_game_opponent

WITH g AS (
	SELECT 	
		game_id
	,	last_frame
	,	stage_id
	, 	dir_path
	FROM	raw_games rg 
	WHERE last_frame > 30*60 --at least 30s long
		AND stage_id in (2,3,8,28,31,32) --neutrals only
		AND (NOT is_teams) --not teams
		AND dir_path like '%:dir_path%'
		AND file_name = ':file_name'
)

, pga AS (
	SELECT
		game_id
	,	sum(1) as player_count
	,	sum(case type when 0 then 1 else 0 end) as human_count
	,	sum(start_stocks) as start_stocks_sum
	FROM	raw_player_games rpg
	GROUP BY
		game_id
	HAVING
		player_count = 2
	AND human_count = 2
	AND start_stocks_sum = 8
)

, g_2players AS (
	SELECT
		g.*
	FROM g
	JOIN pga
	ON 	g.game_id = pga.game_id
)

, pg AS (
	SELECT 
		game_id 
	, 	player_index 
	,	character_id
	,	character_color
	,	nametag
	,	display_name
	,	connect_code
	FROM  raw_player_games rpg 
)

, pg_join AS (
	SELECT
		g.game_id
	,	g.last_frame
	,	g.stage_id
	,	g.dir_path
	, 	pg.player_index 
	,	pg.character_id
	,   pg.character_color
	,	pg.nametag
	,	pg.display_name
	,	pg.connect_code
	,	rpfp.stocks_remaining
	,	rpfp.percent
	,	mccp.player_name
	FROM	g_2players g
	JOIN	pg
	ON  pg.game_id = g.game_id

	JOIN raw_player_frames_post rpfp
	ON  rpfp.game_id = g.game_id
	AND rpfp.frame = g.last_frame
	AND rpfp.player_index = pg.player_index

	LEFT JOIN map_connect_code_player mccp
	ON  mccp.connect_code = pg.connect_code
)


, pgo AS (
	SELECT
		pg.*
	,	pg_opp.player_index AS player_index_opp
	,	pg_opp.character_id AS character_id_opp
	,	pg_opp.character_color AS character_color_opp
	,	pg_opp.connect_code AS connect_code_opp
	,	pg_opp.player_name AS player_name_opp
	,	pg_opp.stocks_remaining AS stocks_remaining_opp
	,	pg_opp.percent AS percent_opp
	FROM pg_join pg
	JOIN pg_join pg_opp
	ON  pg_opp.game_id = pg.game_id
	AND pg_opp.player_index != pg.player_index
)

, pgo_label AS (
	SELECT
		*
	,	case 
			when stocks_remaining>0 and stocks_remaining_opp=0 then 1
			else 0 
		end	as is_win_end
	,	case 
			when stocks_remaining>0 and stocks_remaining_opp>0 then 1
			else 0 
		end	as is_no_contest
	,	case 
			when stocks_remaining>stocks_remaining_opp then 1
			when stocks_remaining=stocks_remaining_opp and percent<percent_opp then 1
			else 0 
		end	as is_stock_percent_lead
	,	case
			when stocks_remaining>0 and stocks_remaining_opp=0 then 1
			when stocks_remaining=0 and stocks_remaining_opp>0 then 0
			when stocks_remaining>stocks_remaining_opp then 1
			when stocks_remaining=stocks_remaining_opp and percent<percent_opp then 1
			when stocks_remaining<stocks_remaining_opp then 0
			when stocks_remaining=stocks_remaining_opp and percent>percent_opp then 0
			else null 
		end as is_win
	,	max(stocks_remaining, stocks_remaining_opp) as stocks_remaining_winner
	FROM pgo
)


SELECT
	game_id
,	last_frame
,	stage_id
,	dir_path
,	player_index
,	character_id
,	character_color
,	connect_code
,	player_name
-- ,	stocks_remaining
-- ,	percent
,	player_index_opp
,	character_id_opp
-- ,	character_color_opp
-- ,	connect_code_opp
-- ,	player_name_opp
-- ,	stocks_remaining_opp
-- ,	percent_opp
-- ,	is_win_end
-- ,	is_no_contest
-- ,	is_stock_percent_lead
,	is_win
,	stocks_remaining_winner
FROM pgo_label
WHERE is_win IS NOT null