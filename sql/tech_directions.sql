

WITH g AS (
	SELECT 	
		game_id
	,	last_frame
	,	stage_id
	from	raw_games rg 
	WHERE TRUE
	
)

, pg AS (
	SELECT 
		game_id 
	, 	player_index 
	,	character_id
	,	nametag
	,	display_name
	,	connect_code
	FROM  raw_player_games rpg 
	WHERE TRUE
--		AND game_id in ('00287747-7d2a-562a-86d8-3347a685b462','00481323-834e-549e-a823-3da932de49af','006c3a81-0559-5ab2-9229-54a922d71bb9','007d05bc-6553-5bcd-807b-fe0e1595d40f','00ebe897-d46c-51b9-93a0-fbfd42858e7d','00f1febf-9263-596f-a7d7-2979f7150e05','01210bb3-f502-5a78-ad8f-975eaf6b3e52','013eb14f-22ee-5913-bf3a-5cde645b6ca8','0158ef10-7df5-58ed-a889-b73d49b03cc4','0199cb8c-ff5e-55fb-994e-a15d350d33de')
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



, gpg AS (
	SELECT 
		g.game_id
	,	g.last_frame
	, 	g.stage_id
	,	pg.player_index
	,	pg.character_id
	,	pg.connect_code
	,	pgo.player_index AS player_index_opp
	,	pgo.character_id AS character_id_opp
	FROM  g
	
	JOIN  pg
	ON  g.game_id = pg.game_id

	JOIN pg  pgo
	ON  pg.game_id = pgo.game_id
	AND pg.player_index != pgo.player_index
	
	-- filter down game sample size
	WHERE TRUE
		AND stage_id in (2,3,8,28,31,32)
--		AND g.game_id in ('00ebe897-d46c-51b9-93a0-fbfd42858e7d','0199cb8c-ff5e-55fb-994e-a15d350d33de','02d48a38-512d-5daa-884e-6e2840f7e90e','02dfd8d1-3246-5426-bd06-92496df4585b','03dcc276-5ca3-57d5-9c4c-c85affed6edb','048c9ff9-c364-5e5d-b484-7c952a34be99','0525a04d-d465-5050-a65a-789703b24ab2','05a9eeb1-046e-5682-b1c5-449597e18bd7','05dbfd20-4bb2-52a9-99e8-a5d659ae4697','07d539ed-a33a-5597-a394-74db7cc4f06b','0837357c-9078-5c67-9a24-05ab4fcc7ee0','09380321-e1fd-5c6e-abc1-28894dd2b31e','0a0676c9-3797-5967-970a-1cfaa2608fa8','0bdacc5b-80c1-50ea-b501-5a738e530413','0d5f19a0-2bde-5d00-b683-5ec64ccfff32','0da4262e-7831-5192-aab2-545565851baf','0e1a72cf-8cc7-5eb3-9ef5-360296031c38','0e62d668-4260-5faa-918c-a2f63ec6de17','0e7fb41f-daae-58f6-8751-cf4e3c22dc1d','0e9f1879-2cfc-51d1-ae0e-7f641e525473','0ef5aefc-7918-509b-81e8-e7524b4b4d62','104bf2fc-4f68-5c41-8347-02d9f27f2e78','108789bc-b11d-5b8e-91c7-a1b7b8d30fe2','1111081a-ad11-5237-8922-edd62538aaed','11324f7d-291c-5edd-8137-0ef427915acd','137aed40-aff4-55e2-af11-a49784c85793','160b86f1-cd4e-5e1a-b4db-ba15cd15f87f','16f58999-bf7a-5c05-9e38-d5197abcbc87','1802b267-6cad-5b19-bf18-dcccbf746a7a','182a3467-3340-5a66-993f-e8dba062ff6d','18baaf79-4c2f-525a-9b20-9cc1a0d2ec35','18bc396e-b3d1-5064-9aaf-1ce60b509f59','1c10f074-80ea-5d81-8292-0b930ba816f8','1c928ab3-a3d5-516a-a329-16e1dd5f975e','1eb71aed-7a90-5cf9-a0c3-8d98bec0b60b','1efdba9d-4ef3-5ac2-954f-8586e72658a0','1fa2cca0-88eb-5a29-9100-08774b7ce406','2234ad1d-d25f-5b3d-8d89-5e937779e3a2','225ee4d6-f9c7-595a-ab30-aac42965d277','2374e789-a505-5abd-8b82-95487350d5e3','2422e64f-e95d-5098-8252-a0ad135109f8','255c5db0-6cee-53f5-98ba-289760720e89','26aa4849-a404-5e48-9b38-ad4827b2d70f','273e2b32-cb10-5227-ab70-2854638f48f8','278e9efc-490b-5751-bda9-5c51a0405ccb','285533ff-559f-59c4-923e-3dd87ca43e02','2a67e42f-8850-563e-94cc-bb46374ada5c','2b6af2ef-39c7-5706-b218-c9e546900b13','2f333213-040d-51ce-b01e-e6f7f3918545','2fe613db-b3a6-5103-8ba9-fe35d35458bb','307aa126-97d9-522b-9be1-afeeaa0200c3','30f1dee7-72b8-5a9d-a2c1-c35ac02cfb18','3222f748-928d-56f6-adf1-a6ad9aae4c59','33cc9324-08a0-52e6-9c64-c855c530b455','347cda83-f353-5adf-9157-a39c1184a08e','35ee9fdb-992b-5e93-a03a-f27f7beb3dc3','37069b48-b1ad-534a-8f95-b7549afeb779','37454e93-9751-5ca8-a425-81aa7e61de5d','37bbee27-df83-5d57-840a-851009d9ad71','39a05a57-695d-5674-8b12-72c0bc40716a','3a0e5982-53d3-5369-b592-52af64eb403a','3a14be0f-e48e-568d-885a-fec09619e115','3a5092ea-f114-5eca-bab6-304a24d918c4','3b6da411-255b-5497-8d9b-a58b41e48a72','3c7d0700-ec05-5f9b-a79c-a2128728c7ba','3cba888a-85b9-578e-bd6d-4a639d7aeb66','3df9cdf6-e385-5ef5-bb43-e8c090379ab1','3ed0431e-fad8-558c-928c-526133cd7416','3ee049cb-95a3-5b51-9858-4d20fc409a5a','3f0fdc01-8dbc-5fdd-9684-4d2a86626dfc','3f99b3e5-6d15-5309-97c7-f7b53758493e','3fb8836a-a5f2-5f4d-99a4-e7b3cb9f2435','4140dde2-04e5-56b8-887f-c122dded4853','41e29e3a-7b9d-55d4-ab39-bb4f8e36358f','42ba3e9d-5f82-5299-a566-9a31e55ccbe0','4528bd0e-8957-52a6-97b6-639827f7dded','45c18226-458f-5c61-be41-259c8a4e26ce','45ca66f3-3835-54f1-99df-a5e5fc83682f','461ee9fc-9d7c-5e55-a262-334bab1edb51','464b50d9-e73c-51ce-96b0-ebe2906ea56c','46fbd8e5-09e6-5579-ae84-925d592e6878','479f1abf-ade4-5674-9597-358e86245764','488ea825-f128-5586-a984-057068167f5c','49b6327e-16a2-53bb-abe3-affaae0e09a5','4ac3e427-75fa-54fb-aca4-0d6f7ad2675d','4b909a04-035c-5b30-823f-a291cf7dc3eb','4cfaed82-6531-5683-8e87-12c26b15a10b','4d8158bf-9927-55ed-9dea-1b22527c6644','4dba88ed-53f0-54bd-8d6d-b91cc545c6ad','4dbfc601-f536-52b1-900e-9278f342c99e','4f33c775-779b-55ee-ac8a-459f1c2fdc72','5191a4e5-6e66-5c82-addf-abf2a350d8bd','51b4f1e9-5396-541f-a1c6-94fde0ad0ff2','51b6b247-aa99-5c68-b648-ae1194643302','5473e331-e1d6-58c4-a6ed-3360ebd145a0','559bb7a6-e489-556c-b4cb-bf66488a909c','56262106-c99a-5157-a7cf-46d1183d4cb5','56fa4e6f-b2aa-51e3-a4ed-77daf015f69b','57d663d4-6f8c-56bd-adcf-a680e820e9e5','57eb88ff-55a2-5400-a997-3e65dc9837aa','583da042-a1de-559d-9fbd-56282d80e229','5957827e-d031-5846-a657-942a24cfa523','59aeea2b-45f3-544b-84b2-a1b3f6e2eb8c','5a66c274-413a-5cd6-b178-2b11c4693f19','5aeae0f4-94c7-542b-9413-999b4cbef26c','5c2cb900-ae32-52cc-923b-156c2b083686','5c3264eb-f81c-5736-ab3b-c28cc2d2f125','5c7ffc83-7642-5f4c-9949-6e868f7eebd6','5d3b7ef8-6192-5fcf-a8e1-23b8932bdce4','5d6077fd-87e4-57df-a56e-003a1b99873b','5e27708b-0bd1-5ab4-a73f-d234a7f0daae','5e2eea9d-fbae-5414-be12-08c8b3afaa9d','5e6f286b-67af-5573-9bb0-85546a23c73d','5e95d4fc-c518-5ff4-8851-685e96ccff2d','5ff60263-a855-5c9e-8203-ad8e001d661a','60f67cad-1cce-5c09-984e-bac34be3f894','6117cf69-e141-5ec1-8c99-8fa00b456ff7','615e0379-ebf0-5eba-acea-f8f2d68ec2b2','621de998-57bf-54c4-9901-1f2254026c97','622a4103-b7fa-5a50-90ef-aadbb690b37a','624d8485-b6c9-5962-aaf0-d8d90edd72ed','62dc5dcc-ab6f-5e36-809a-8826c4b01e94','64bc7b5f-16ac-5931-ba0e-cb97961291e7','64c5dbae-d6b9-5b41-b194-3b8e3baffa44','67610d32-fa04-5859-b081-615ce5cbc5b5','67baf9fb-45d4-5720-8e54-ae66b1aded55','6a3ec012-88f1-596e-9ab5-801cbf309bc0','6b4647dd-df69-517a-bce7-e0e1fbd4d259','6b80a36b-4f49-5434-a369-fe446e17554e','6c31f09d-d246-580a-bf2c-a73fcff78f0e','6c856b57-d753-58d9-b62f-f8ecfcb09e21','6c97c4c5-c441-5385-951e-ae3df693f579','6caa2955-0ae1-56cf-a334-0cbb8828b1cf','6d488ed0-a407-5dec-95c6-cc3df280b066','6df774cf-1064-5e5e-9f45-4754db208d8f','6ee067b2-9049-5647-a7bb-69c9e514887d','6f88bf86-bb1b-524a-9ca2-688b2164ab49','6f91a896-a848-5106-9a25-19818fc9c090','7012a571-45a8-5149-b80b-42892c47b45f','708a2fcc-92e8-53bd-8c94-58d39d71a792','70a5de49-eb20-5293-8a34-f08ae34f4486','70ef73ea-f83f-5913-81bc-8254761912d4','71744f9e-dd2b-5513-b869-029d6978fd5a','71ee0b78-dc11-5028-bf81-27865064e19b','7220f22a-9224-52a3-bf07-f7ebf67dfac3','72494da4-7258-5330-8a02-e39872648280','73a04825-3f03-530a-a1d5-448ad867e5d8','7485ba73-523c-54d9-b6dd-57a27b05973d','75b877b1-8da9-5254-923e-239faf37bc0c','765f67c6-734b-523b-8844-a6c85b5efb66','77c860d2-84fc-5885-b7a1-9628dc5b4563','7b261462-e61c-52aa-b01b-5173cec08427','7b4600d3-376a-559f-8cdd-fb0d76523af7','7b652bd8-89a8-5ea5-af1b-d20042cf868f','7bf6bdd6-5326-5dfa-a690-ebc423d90df5','7cb4337b-1c97-5daf-8cc6-e85ca3a41d10','7d20312d-f743-5a29-befe-cbd8286dc108','7f3982ac-4ad4-5464-9b4c-439414f173ea','7f8ca064-0272-5992-bf0f-ec76d2fc38d8','7fbdb7ea-bbbb-5b25-8b41-238358ccf751','810b8bd1-4548-57f7-9c3a-b591d1205a25','818f12b0-b08f-5fa5-8e29-1df8ec392c6b','81a66584-d03d-5574-9c9a-12d9c6862edb','820b9ceb-c697-51a6-99a7-bc89d89f8b95','82b0f52c-1d4a-5896-947f-253a848a5355','83ad4829-bd98-5413-ae72-6e7387eab692','84802374-e8e7-5d15-814e-b58fb04480b9','84b69021-5240-513a-9576-d7f2d6134e75','84c9608c-d673-5eba-b099-f932cf0d6f16','84fd8145-4285-58ad-96fb-1f5e8eb47966','860ec5a3-5fa9-5c23-a285-c116cc4eb8c3','87536505-0b5f-5b4c-b629-7866af2bdd6a','879eb5ae-6bcf-5b12-a298-d240dca143f1','87de289d-57bc-5640-943b-62dea91e14d5','87ebf857-4d97-579d-aa3e-b41cfbbc0d3e','8883ff65-b445-5567-a13c-e0bef22ac199','89908c59-dc8a-5013-8b58-7aaf4b3ca398','8a5eedbd-4b41-5a2c-883d-1d2a0d5d2ebe','8bd1ea42-7a7b-574e-b335-2fc472f10ea2','8dc1d206-4ce7-577d-aecf-b467aafad9dd','8decb063-d5cd-55e8-b912-a5ca80b17452','8e397ad1-c468-5a4f-aa04-ef41a5ec1dc8','9256437d-ce82-55fc-8bd0-8f9b4dbfcd92','9276def0-420f-5bd7-b848-9ca6d3888b2e','927f4e3c-c0e1-5c4a-8e03-069b653821ff','93454409-4994-5100-be58-7f6c1b7246b8','93bd2aa5-773b-55a9-a67c-c304728a0243','95996279-dcfe-533f-83c6-be27da56be08','95d953b8-4358-52dd-9be9-d0d830458b39','95ec5a1c-7f7a-5077-bb54-3be159344a59','95f028a9-e96c-5f8b-92cc-86688d76c0f2','960e9c5f-79c9-5b72-8c1b-8b730dddedc2','968d99c6-5359-5004-85b7-c67d623cde10','97f78dff-1a81-5990-be98-1f94ffcc9bd5','98a7e012-7fd2-53f5-9946-100091779e45','98bf3939-9a26-55db-9065-ebfb2366af19','9971458c-adee-5dfb-8c10-d9a5c3670c49','997a1d54-2dc1-5134-948d-dcb711dbcea6','9a31f93e-a63f-5bbe-bbf2-0d5988f76082','9b3465db-c682-523b-8f3a-d7e4f695667f')
)

, pfp AS (
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
--		AND game_id in ('00ebe897-d46c-51b9-93a0-fbfd42858e7d','0199cb8c-ff5e-55fb-994e-a15d350d33de','02d48a38-512d-5daa-884e-6e2840f7e90e','02dfd8d1-3246-5426-bd06-92496df4585b','03dcc276-5ca3-57d5-9c4c-c85affed6edb','048c9ff9-c364-5e5d-b484-7c952a34be99','0525a04d-d465-5050-a65a-789703b24ab2','05a9eeb1-046e-5682-b1c5-449597e18bd7','05dbfd20-4bb2-52a9-99e8-a5d659ae4697','07d539ed-a33a-5597-a394-74db7cc4f06b','0837357c-9078-5c67-9a24-05ab4fcc7ee0','09380321-e1fd-5c6e-abc1-28894dd2b31e','0a0676c9-3797-5967-970a-1cfaa2608fa8','0bdacc5b-80c1-50ea-b501-5a738e530413','0d5f19a0-2bde-5d00-b683-5ec64ccfff32','0da4262e-7831-5192-aab2-545565851baf','0e1a72cf-8cc7-5eb3-9ef5-360296031c38','0e62d668-4260-5faa-918c-a2f63ec6de17','0e7fb41f-daae-58f6-8751-cf4e3c22dc1d','0e9f1879-2cfc-51d1-ae0e-7f641e525473','0ef5aefc-7918-509b-81e8-e7524b4b4d62','104bf2fc-4f68-5c41-8347-02d9f27f2e78','108789bc-b11d-5b8e-91c7-a1b7b8d30fe2','1111081a-ad11-5237-8922-edd62538aaed','11324f7d-291c-5edd-8137-0ef427915acd','137aed40-aff4-55e2-af11-a49784c85793','160b86f1-cd4e-5e1a-b4db-ba15cd15f87f','16f58999-bf7a-5c05-9e38-d5197abcbc87','1802b267-6cad-5b19-bf18-dcccbf746a7a','182a3467-3340-5a66-993f-e8dba062ff6d','18baaf79-4c2f-525a-9b20-9cc1a0d2ec35','18bc396e-b3d1-5064-9aaf-1ce60b509f59','1c10f074-80ea-5d81-8292-0b930ba816f8','1c928ab3-a3d5-516a-a329-16e1dd5f975e','1eb71aed-7a90-5cf9-a0c3-8d98bec0b60b','1efdba9d-4ef3-5ac2-954f-8586e72658a0','1fa2cca0-88eb-5a29-9100-08774b7ce406','2234ad1d-d25f-5b3d-8d89-5e937779e3a2','225ee4d6-f9c7-595a-ab30-aac42965d277','2374e789-a505-5abd-8b82-95487350d5e3','2422e64f-e95d-5098-8252-a0ad135109f8','255c5db0-6cee-53f5-98ba-289760720e89','26aa4849-a404-5e48-9b38-ad4827b2d70f','273e2b32-cb10-5227-ab70-2854638f48f8','278e9efc-490b-5751-bda9-5c51a0405ccb','285533ff-559f-59c4-923e-3dd87ca43e02','2a67e42f-8850-563e-94cc-bb46374ada5c','2b6af2ef-39c7-5706-b218-c9e546900b13','2f333213-040d-51ce-b01e-e6f7f3918545','2fe613db-b3a6-5103-8ba9-fe35d35458bb','307aa126-97d9-522b-9be1-afeeaa0200c3','30f1dee7-72b8-5a9d-a2c1-c35ac02cfb18','3222f748-928d-56f6-adf1-a6ad9aae4c59','33cc9324-08a0-52e6-9c64-c855c530b455','347cda83-f353-5adf-9157-a39c1184a08e','35ee9fdb-992b-5e93-a03a-f27f7beb3dc3','37069b48-b1ad-534a-8f95-b7549afeb779','37454e93-9751-5ca8-a425-81aa7e61de5d','37bbee27-df83-5d57-840a-851009d9ad71','39a05a57-695d-5674-8b12-72c0bc40716a','3a0e5982-53d3-5369-b592-52af64eb403a','3a14be0f-e48e-568d-885a-fec09619e115','3a5092ea-f114-5eca-bab6-304a24d918c4','3b6da411-255b-5497-8d9b-a58b41e48a72','3c7d0700-ec05-5f9b-a79c-a2128728c7ba','3cba888a-85b9-578e-bd6d-4a639d7aeb66','3df9cdf6-e385-5ef5-bb43-e8c090379ab1','3ed0431e-fad8-558c-928c-526133cd7416','3ee049cb-95a3-5b51-9858-4d20fc409a5a','3f0fdc01-8dbc-5fdd-9684-4d2a86626dfc','3f99b3e5-6d15-5309-97c7-f7b53758493e','3fb8836a-a5f2-5f4d-99a4-e7b3cb9f2435','4140dde2-04e5-56b8-887f-c122dded4853','41e29e3a-7b9d-55d4-ab39-bb4f8e36358f','42ba3e9d-5f82-5299-a566-9a31e55ccbe0','4528bd0e-8957-52a6-97b6-639827f7dded','45c18226-458f-5c61-be41-259c8a4e26ce','45ca66f3-3835-54f1-99df-a5e5fc83682f','461ee9fc-9d7c-5e55-a262-334bab1edb51','464b50d9-e73c-51ce-96b0-ebe2906ea56c','46fbd8e5-09e6-5579-ae84-925d592e6878','479f1abf-ade4-5674-9597-358e86245764','488ea825-f128-5586-a984-057068167f5c','49b6327e-16a2-53bb-abe3-affaae0e09a5','4ac3e427-75fa-54fb-aca4-0d6f7ad2675d','4b909a04-035c-5b30-823f-a291cf7dc3eb','4cfaed82-6531-5683-8e87-12c26b15a10b','4d8158bf-9927-55ed-9dea-1b22527c6644','4dba88ed-53f0-54bd-8d6d-b91cc545c6ad','4dbfc601-f536-52b1-900e-9278f342c99e','4f33c775-779b-55ee-ac8a-459f1c2fdc72','5191a4e5-6e66-5c82-addf-abf2a350d8bd','51b4f1e9-5396-541f-a1c6-94fde0ad0ff2','51b6b247-aa99-5c68-b648-ae1194643302','5473e331-e1d6-58c4-a6ed-3360ebd145a0','559bb7a6-e489-556c-b4cb-bf66488a909c','56262106-c99a-5157-a7cf-46d1183d4cb5','56fa4e6f-b2aa-51e3-a4ed-77daf015f69b','57d663d4-6f8c-56bd-adcf-a680e820e9e5','57eb88ff-55a2-5400-a997-3e65dc9837aa','583da042-a1de-559d-9fbd-56282d80e229','5957827e-d031-5846-a657-942a24cfa523','59aeea2b-45f3-544b-84b2-a1b3f6e2eb8c','5a66c274-413a-5cd6-b178-2b11c4693f19','5aeae0f4-94c7-542b-9413-999b4cbef26c','5c2cb900-ae32-52cc-923b-156c2b083686','5c3264eb-f81c-5736-ab3b-c28cc2d2f125','5c7ffc83-7642-5f4c-9949-6e868f7eebd6','5d3b7ef8-6192-5fcf-a8e1-23b8932bdce4','5d6077fd-87e4-57df-a56e-003a1b99873b','5e27708b-0bd1-5ab4-a73f-d234a7f0daae','5e2eea9d-fbae-5414-be12-08c8b3afaa9d','5e6f286b-67af-5573-9bb0-85546a23c73d','5e95d4fc-c518-5ff4-8851-685e96ccff2d','5ff60263-a855-5c9e-8203-ad8e001d661a','60f67cad-1cce-5c09-984e-bac34be3f894','6117cf69-e141-5ec1-8c99-8fa00b456ff7','615e0379-ebf0-5eba-acea-f8f2d68ec2b2','621de998-57bf-54c4-9901-1f2254026c97','622a4103-b7fa-5a50-90ef-aadbb690b37a','624d8485-b6c9-5962-aaf0-d8d90edd72ed','62dc5dcc-ab6f-5e36-809a-8826c4b01e94','64bc7b5f-16ac-5931-ba0e-cb97961291e7','64c5dbae-d6b9-5b41-b194-3b8e3baffa44','67610d32-fa04-5859-b081-615ce5cbc5b5','67baf9fb-45d4-5720-8e54-ae66b1aded55','6a3ec012-88f1-596e-9ab5-801cbf309bc0','6b4647dd-df69-517a-bce7-e0e1fbd4d259','6b80a36b-4f49-5434-a369-fe446e17554e','6c31f09d-d246-580a-bf2c-a73fcff78f0e','6c856b57-d753-58d9-b62f-f8ecfcb09e21','6c97c4c5-c441-5385-951e-ae3df693f579','6caa2955-0ae1-56cf-a334-0cbb8828b1cf','6d488ed0-a407-5dec-95c6-cc3df280b066','6df774cf-1064-5e5e-9f45-4754db208d8f','6ee067b2-9049-5647-a7bb-69c9e514887d','6f88bf86-bb1b-524a-9ca2-688b2164ab49','6f91a896-a848-5106-9a25-19818fc9c090','7012a571-45a8-5149-b80b-42892c47b45f','708a2fcc-92e8-53bd-8c94-58d39d71a792','70a5de49-eb20-5293-8a34-f08ae34f4486','70ef73ea-f83f-5913-81bc-8254761912d4','71744f9e-dd2b-5513-b869-029d6978fd5a','71ee0b78-dc11-5028-bf81-27865064e19b','7220f22a-9224-52a3-bf07-f7ebf67dfac3','72494da4-7258-5330-8a02-e39872648280','73a04825-3f03-530a-a1d5-448ad867e5d8','7485ba73-523c-54d9-b6dd-57a27b05973d','75b877b1-8da9-5254-923e-239faf37bc0c','765f67c6-734b-523b-8844-a6c85b5efb66','77c860d2-84fc-5885-b7a1-9628dc5b4563','7b261462-e61c-52aa-b01b-5173cec08427','7b4600d3-376a-559f-8cdd-fb0d76523af7','7b652bd8-89a8-5ea5-af1b-d20042cf868f','7bf6bdd6-5326-5dfa-a690-ebc423d90df5','7cb4337b-1c97-5daf-8cc6-e85ca3a41d10','7d20312d-f743-5a29-befe-cbd8286dc108','7f3982ac-4ad4-5464-9b4c-439414f173ea','7f8ca064-0272-5992-bf0f-ec76d2fc38d8','7fbdb7ea-bbbb-5b25-8b41-238358ccf751','810b8bd1-4548-57f7-9c3a-b591d1205a25','818f12b0-b08f-5fa5-8e29-1df8ec392c6b','81a66584-d03d-5574-9c9a-12d9c6862edb','820b9ceb-c697-51a6-99a7-bc89d89f8b95','82b0f52c-1d4a-5896-947f-253a848a5355','83ad4829-bd98-5413-ae72-6e7387eab692','84802374-e8e7-5d15-814e-b58fb04480b9','84b69021-5240-513a-9576-d7f2d6134e75','84c9608c-d673-5eba-b099-f932cf0d6f16','84fd8145-4285-58ad-96fb-1f5e8eb47966','860ec5a3-5fa9-5c23-a285-c116cc4eb8c3','87536505-0b5f-5b4c-b629-7866af2bdd6a','879eb5ae-6bcf-5b12-a298-d240dca143f1','87de289d-57bc-5640-943b-62dea91e14d5','87ebf857-4d97-579d-aa3e-b41cfbbc0d3e','8883ff65-b445-5567-a13c-e0bef22ac199','89908c59-dc8a-5013-8b58-7aaf4b3ca398','8a5eedbd-4b41-5a2c-883d-1d2a0d5d2ebe','8bd1ea42-7a7b-574e-b335-2fc472f10ea2','8dc1d206-4ce7-577d-aecf-b467aafad9dd','8decb063-d5cd-55e8-b912-a5ca80b17452','8e397ad1-c468-5a4f-aa04-ef41a5ec1dc8','9256437d-ce82-55fc-8bd0-8f9b4dbfcd92','9276def0-420f-5bd7-b848-9ca6d3888b2e','927f4e3c-c0e1-5c4a-8e03-069b653821ff','93454409-4994-5100-be58-7f6c1b7246b8','93bd2aa5-773b-55a9-a67c-c304728a0243','95996279-dcfe-533f-83c6-be27da56be08','95d953b8-4358-52dd-9be9-d0d830458b39','95ec5a1c-7f7a-5077-bb54-3be159344a59','95f028a9-e96c-5f8b-92cc-86688d76c0f2','960e9c5f-79c9-5b72-8c1b-8b730dddedc2','968d99c6-5359-5004-85b7-c67d623cde10','97f78dff-1a81-5990-be98-1f94ffcc9bd5','98a7e012-7fd2-53f5-9946-100091779e45','98bf3939-9a26-55db-9065-ebfb2366af19','9971458c-adee-5dfb-8c10-d9a5c3670c49','997a1d54-2dc1-5134-948d-dcb711dbcea6','9a31f93e-a63f-5bbe-bbf2-0d5988f76082','9b3465db-c682-523b-8f3a-d7e4f695667f')
)


, frame AS (
	select
		gpg.*
	,   pfp.frame
	, 	pfp.position_x AS X
	,	pfp.position_y AS Y
	,	pfp.facing_direction
	,	pfp.stocks_remaining AS stocks
	,	pfp.action_state_id
	,	pfp.action_state_counter
	,	pfp.percent
	,	pfpo.stocks_remaining AS stocks_opp
	from  gpg
	
	join  pfp
	on  gpg.game_id = pfp.game_id
		AND gpg.player_index = pfp.player_index
	
	join  pfp AS pfpo 
	on  gpg.game_id = pfpo.game_id
		AND gpg.player_index_opp = pfpo.player_index
		AND pfp.frame = pfpo.frame
)

, frame_tech AS (
	select
		*
	from  frame
	where  TRUE
		AND action_state_id in (
				0183 --miss tech down
			,	0191 --miss tech up
			,	0199 --tech in place
			,	0200 --tech forward
			,	0201 --tech backward
			)

		AND action_state_counter = 0
)

, agg AS (
	select
		stage_id
	,	CASE 
			WHEN connect_code in ('RELU#824', 'EG#164', 'EG#0', 'DAKO#725', 'DAK#0') THEN connect_code
		ELSE 'Netplay Rando' END AS connect_code
	,	character_id
	,	character_id_opp
	,	facing_direction
	,	round(X/10)*10 AS X
	,	round(Y/10)*10 AS Y
--	,	stocks
	,	action_state_id
	,	round(percent/10)*10 AS percent
--	,	stocks_opp
	,   sum(1) AS rowcount
	from  frame_tech
	group by
		1,2,3,4,5,6,7,8,9
)


, dim AS (
	select
		a.*
	,	ds.stage_name
	,	dc.character_name
	,	dco.character_name AS character_name_opp
	,   dasu.state_name
	,	dasu.state_description 
	
	from agg a
	
	join dim_stage ds 
	on	ds.stage_id = a.stage_id
	
	join dim_character dc 
	on  dc.character_id = a.character_id
	
	join dim_character dco
	on  dco.character_id = a.character_id_opp
	
	left join dim_action_state_union dasu
	on  dasu.action_state_id = a.action_state_id
		and dasu.character_id = a.character_id
	
	where TRUE 
		AND dc.tier_rank <= 6
		AND dco.tier_rank <= 6
)

, dim_relabel AS (
	SELECT 
		dim.*
	,	CASE facing_direction
			WHEN 1 THEN	
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Right' -- facing-dependent
					WHEN 201 THEN 'Tech Left' -- facing-dependent
				ELSE '???' END
			WHEN -1 THEN
				CASE action_state_id
					WHEN 183 THEN 'Miss Tech'
					WHEN 191 THEN 'Miss Tech'
					WHEN 199 THEN 'Tech In Place'
					WHEN 200 THEN 'Tech Left' -- facing-dependent
					WHEN 201 THEN 'Tech Right' -- facing-dependent
				ELSE '???' END
		ELSE '???' END AS tech_description
	FROM  dim
)

select *
from  dim_relabel
