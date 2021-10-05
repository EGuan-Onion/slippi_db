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
  , dc.tier_rank
  , dco.character_name as character_name_opp
  , dco.tier_rank as tier_rank_opp
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
  , CASE
    WHEN player_name is not null THEN player_name
    WHEN dir_path like '%tournament%' THEN 'Tourney Rando'
    WHEN connect_code is not null THEN 'Netplay Rando'
    WHEN dir_path like '%home/%' and connect_code is null 
      THEN  SUBSTR(dir_path,
        INSTR(dir_path, 'home/') + length('home/'),
        INSTR(SUBSTR(dir_path,
          INSTR(dir_path, 'home/') + length('home/')
        ), '/')-1
        ) || ' local play'
      ELSE '???' 
      END as player_label
  FROM  dim
)

SELECT *
FROM  label