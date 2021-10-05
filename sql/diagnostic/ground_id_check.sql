WITH pgo AS (
  select
  game_id
    , stage_id
    , player_index
  from  derived_player_game_opponent
)

, rpfp AS (
  select
    game_id
  , player_index
  , position_x
  , position_y
  , is_airborne
  , last_ground_id
  from  raw_player_frames_post
  where not is_airborne
)

SELECT
  pgo.stage_id
    , stage_name
    , round(position_x/5)*5 as X
    , round(position_y/5)*5 as Y
    , last_ground_id
    , sum(1) as frame_count
FROM  pgo
JOIN rpfp
on rpfp.game_id = pgo.game_id
  and rpfp.player_index = pgo.player_index

JOIN dim_stage ds
on ds.stage_id = pgo.stage_id

GROUP BY
  1,2,3,4,5



