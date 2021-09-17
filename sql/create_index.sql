-- Create Indexes

select *
from sqlite_master
where type != 'table'
;

create index if not exists raw_games_cover
on raw_games (
  	gameId
  ,	lastFrame
  ,	stageId
  , dirpath
)
;


create index if not exists raw_player_games_cover
on raw_player_games (
  	gameId 
  , playerIndex 
  ,	characterId
  ,	characterColor
  ,	nametag
  ,	displayName
  ,	connectCode
)
;



create index if not exists raw_player_frames_post_cover
on raw_player_frames_post (
  	gameId
  ,	playerIndex
  ,	frame
  ,	actionStateId 
  ,	actionStateCounter 
  ,	facingDirection -- 1 = right, -1 = left
  , isAirborne
  , positionX 
  ,	positionY 
  ,	percent 
  ,	stocksRemaining
)

