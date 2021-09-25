WITH agg AS (
  SELECT
  player_name
  , connect_code
  , dir_path
  , character_id
  , character_color
  , character_id_opp
  , stage_id
  , is_win
  , sum(last_frame) as frame_sum
  , sum(1) as game_count
  FROM  derived_player_game_opponent
  GROUP BY
  	1,2,3,4,5,6,7
)
  
, dim AS (
  SELECT  
  	agg.*
  , dc.character_name
  , dco.character_name as character_name_opp
  ,	stage_name
  , stage_name_short
  FROM agg
  
  JOIN dim_character dc
  ON  dc.character_id = agg.character_id
  
  JOIN dim_character dco
  ON  dco.character_id = agg.character_id_opp
  
  JOIN dim_stage ds
  ON  ds.stage_id = agg.stage_id
)

, label AS (
  SELECT
  	dim.*
  , coalesce(player_name,
      CASE
        WHEN dir_path like '%summit%' 
        	THEN CASE
        		WHEN character_name = 'Fox' THEN 'Mango/iBDW/SFAT/Aklo/moky/Plup'
        		WHEN character_name = 'Falco' THEN 'Yingling/Mango'
        		WHEN character_name = 'Marth' THEN 'Zain/Kodorin/LSD/Tai'
        		WHEN character_name = 'C. Falcon' THEN 'Wizzrobe/n0ne/Vish?'
        		WHEN character_name = 'Jiggs' THEN 'HBox/2saint'
        		WHEN character_name = 'Shiek' THEN 'Plup'
        		WHEN character_name = 'Pikachu' THEN 'Axe'
        		WHEN character_name = 'Yoshi' THEN 'aMSa'
        		WHEN character_name = 'Samus' THEN 'Plup'
        		WHEN character_name = 'Link' THEN 'Alko'
        		WHEN character_name = 'DK' THEN 'Ringler'
        		--TODO -- label 'em
        	ELSE 'Summit Rando' END
        WHEN dir_path like '%tournament%' THEN 'Tourney Rando'
        WHEN connect_code is not null THEN 'Netplay Rando'
      ELSE '???' END
    ) as player_label
  FROM  dim
)

SELECT *
FROM  label