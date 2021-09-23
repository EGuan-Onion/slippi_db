
CREATE TABLE IF NOT EXISTS dim_action_state_union AS 

	SELECT 
		character_id
	  , das.*
	from  dim_action_state das 
	
	CROSS JOIN  dim_character dc
	WHERE action_state_id < 341


	UNION ALL


	SELECT
		*
	from  dim_action_state_character

;


create index if not exists dim_action_state_union_id
  on  dim_action_state_union (
    character_id
  , action_state_id
  )
;



create index if not exists dim_action_state_union_cover
  on  dim_action_state_union (
    character_id
  , action_state_id
  , state_name
  , state_description
  , state_category
  , attack_type
  , direction
  )
;
