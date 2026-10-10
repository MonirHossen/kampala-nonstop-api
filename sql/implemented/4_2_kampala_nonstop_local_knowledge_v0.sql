-- Kampala Nonstop / Africa Nonstop — Local Knowledge V0
-- PostgreSQL. Generated from the live spreadsheet on 2026-09-09.
-- Source: https://docs.google.com/spreadsheets/d/1CsxSfz_Gqbdb6SMqa1t8C6wbtwhMIa4a27HxsoVQ-FM/edit
-- 87 Local Knowledge entries; all spreadsheet tags retained as supplied.
-- Run AFTER the geographic tables/data, 4_kampala_nonstop_local_knowledge_schema.sql
-- and 4_1_kampala_nonstop_local_knowledge_seed_data.sql.
-- Fixed UUIDs make this script safe to rerun. A targeted language correction is included.
-- Existing rows created by another import with different UUIDs are not deduplicated.
-- Blank geography means country-wide; named areas resolve by country + area code.
-- Blank explanations become NULL. No image or source URLs were supplied.
-- Audit columns use the schema's TIMESTAMPTZ defaults; is_live defaults to TRUE.
-- Page Contexts are empty in the spreadsheet, so no page-context links are inserted.
-- Language compatibility: spreadsheet lug maps to the existing seed code lg.
-- Runyankole–Rukiga lists nyn,cgg: the schema has only one language FK.
-- That entry uses nyn (Runyankole), as instructed; both language tags are retained.
-- Language descriptions have no destination column; they are retained as comments.

BEGIN;
SET LOCAL search_path = public, pg_temp;
SET LOCAL standard_conforming_strings = on;

-- Add missing spreadsheet reference data; preserve existing reference records.
INSERT INTO local_knowledge_tags (code, name, description)
VALUES
    ('ACADEMY_AWARDS', 'Academy Awards', 'Local Knowledge about academy awards.'),
    ('ACHOLI', 'Acholi', 'Local Knowledge about acholi.'),
    ('ACHOLILAND', 'Acholiland', 'Local Knowledge about acholiland.'),
    ('ANKOLE', 'Ankole', 'Local Knowledge about ankole.'),
    ('ATESO', 'Ateso', 'Local Knowledge about ateso.'),
    ('AWARDS', 'Awards', 'Recognition received through formal awards and honours.'),
    ('BARKCLOTH', 'Barkcloth', 'Local Knowledge about barkcloth.'),
    ('BET_AWARDS', 'Bet Awards', 'Local Knowledge about bet awards.'),
    ('BIRDS', 'Birds', 'Local Knowledge about birds.'),
    ('BLACK_PANTHER', 'Black Panther', 'Local Knowledge about black panther.'),
    ('BODA_BODA', 'Boda Boda', 'Local Knowledge about boda boda.'),
    ('BORDERS', 'Borders', 'Local Knowledge about borders.'),
    ('BUGANDA', 'Buganda', 'Local Knowledge about buganda.'),
    ('BUSOGA', 'Busoga', 'Local Knowledge about busoga.'),
    ('BWINDI', 'Bwindi', 'Local Knowledge about bwindi.'),
    ('CASH', 'Cash', 'Local Knowledge about cash.'),
    ('CEREMONIES', 'Ceremonies', 'Local Knowledge about ceremonies.'),
    ('CHESS', 'Chess', 'Local Knowledge about chess.'),
    ('CHIMPANZEES', 'Chimpanzees', 'Local Knowledge about chimpanzees.'),
    ('CLANS', 'Clans', 'Local Knowledge about clans.'),
    ('CLOTHING', 'Clothing', 'Local Knowledge about clothing.'),
    ('COMMUNITY', 'Community', 'Local Knowledge about community.'),
    ('CRAFTS', 'Crafts', 'Local Knowledge about crafts.'),
    ('CRATER_LAKES', 'Crater Lakes', 'Local Knowledge about crater lakes.'),
    ('CULTURE', 'Culture', 'Local Knowledge about culture.'),
    ('DINING', 'Dining', 'Local Knowledge about dining.'),
    ('DIRECTIONS', 'Directions', 'Local Knowledge about directions.'),
    ('DRINKS', 'Drinks', 'Local Knowledge about drinks.'),
    ('DRIVING', 'Driving', 'Local Knowledge about driving.'),
    ('EAST_AFRICA', 'East Africa', 'Local Knowledge about east africa.'),
    ('EASTERN_UGANDA', 'Eastern Uganda', 'Local Knowledge about eastern uganda.'),
    ('EDDY_KENZO', 'Eddy Kenzo', 'Local Knowledge about eddy kenzo.'),
    ('ELDERS', 'Elders', 'Local Knowledge about elders.'),
    ('ELECTRICITY', 'Electricity', 'Local Knowledge about electricity.'),
    ('EQUATOR', 'Equator', 'Local Knowledge about equator.'),
    ('ETIQUETTE', 'Etiquette', 'Local Knowledge about etiquette.'),
    ('FILM', 'Film', 'Local Knowledge about film.'),
    ('FLORENCE_KASUMBA', 'Florence Kasumba', 'Local Knowledge about florence kasumba.'),
    ('FOOD', 'Food', 'Local Knowledge about food.'),
    ('FOREST_WHITAKER', 'Forest Whitaker', 'Local Knowledge about forest whitaker.'),
    ('FRIED_TOMATOES', 'Fried Tomatoes', 'Local Knowledge about fried tomatoes.'),
    ('GEOGRAPHY', 'Geography', 'Local Knowledge about geography.'),
    ('GEOLOGY', 'Geology', 'Local Knowledge about geology.'),
    ('GHETTO_KIDS', 'Ghetto Kids', 'Local Knowledge about ghetto kids.'),
    ('GOMESI', 'Gomesi', 'Local Knowledge about gomesi.'),
    ('GOSSIP_GIRL', 'Gossip Girl', 'Local Knowledge about gossip girl.'),
    ('GREETINGS', 'Greetings', 'Local Knowledge about greetings.'),
    ('GREY_CROWNED_CRANE', 'Grey Crowned Crane', 'Local Knowledge about grey crowned crane.'),
    ('HEALTH', 'Health', 'Local Knowledge about health.'),
    ('HERITAGE', 'Heritage', 'Local Knowledge about heritage.'),
    ('HISTORY', 'History', 'Local Knowledge about history.'),
    ('HUMOUR', 'Humour', 'Local Knowledge about humour.'),
    ('ISLANDS', 'Islands', 'Local Knowledge about islands.'),
    ('JUICE', 'Juice', 'Local Knowledge about juice.'),
    ('KAMPALA', 'Kampala', 'Local Knowledge about kampala.'),
    ('KAMPALA_NONSTOP', 'Kampala Nonstop', 'Local Knowledge about kampala nonstop.'),
    ('KANZU', 'Kanzu', 'Local Knowledge about kanzu.'),
    ('KATWE', 'Katwe', 'Local Knowledge about katwe.'),
    ('KAZINGA_CHANNEL', 'Kazinga Channel', 'Local Knowledge about kazinga channel.'),
    ('KIGEZI', 'Kigezi', 'Local Knowledge about kigezi.'),
    ('KWANJULA', 'Kwanjula', 'Local Knowledge about kwanjula.'),
    ('LAKE_ALBERT', 'Lake Albert', 'Local Knowledge about lake albert.'),
    ('LAKE_BUNYONYI', 'Lake Bunyonyi', 'Local Knowledge about lake bunyonyi.'),
    ('LAKE_MUTANDA', 'Lake Mutanda', 'Local Knowledge about lake mutanda.'),
    ('LAKE_VICTORIA', 'Lake Victoria', 'Local Knowledge about lake victoria.'),
    ('LAKES', 'Lakes', 'Local Knowledge about lakes.'),
    ('LANDMARKS', 'Landmarks', 'Local Knowledge about landmarks.'),
    ('LANGUAGE', 'Language', 'Local Knowledge about language.'),
    ('LIONS', 'Lions', 'Local Knowledge about lions.'),
    ('LOCAL_LIFE', 'Local Life', 'Local Knowledge about local life.'),
    ('LUGANDA', 'Luganda', 'Local Knowledge about luganda.'),
    ('LUSOGA', 'Lusoga', 'Local Knowledge about lusoga.'),
    ('MADINA_NALWANGA', 'Madina Nalwanga', 'Local Knowledge about madina nalwanga.'),
    ('MARVEL', 'Marvel', 'Local Knowledge about marvel.'),
    ('MATOOKE', 'Matooke', 'Local Knowledge about matooke.'),
    ('MGAHINGA', 'Mgahinga', 'Local Knowledge about mgahinga.'),
    ('MOBILE_MONEY', 'Mobile Money', 'Local Knowledge about mobile money.'),
    ('MONEY', 'Money', 'Local Knowledge about money.'),
    ('MOUNTAIN_GORILLAS', 'Mountain Gorillas', 'Local Knowledge about mountain gorillas.'),
    ('MOUNTAINS', 'Mountains', 'Local Knowledge about mountains.'),
    ('MURCHISON_FALLS', 'Murchison Falls', 'Local Knowledge about murchison falls.'),
    ('MUSIC', 'Music', 'Local Knowledge about music.'),
    ('NATIONAL_IDENTITY', 'National Identity', 'Local Knowledge about national identity.'),
    ('NATIONAL_PARKS', 'National Parks', 'Protected national parks, their landscapes, wildlife and visitor experiences.'),
    ('NATIONAL_SYMBOLS', 'National Symbols', 'Local Knowledge about national symbols.'),
    ('NATURE', 'Nature', 'Local Knowledge about nature.'),
    ('NIGHTLIFE', 'Nightlife', 'Local Knowledge about nightlife.'),
    ('NORTHERN_UGANDA', 'Northern Uganda', 'Local Knowledge about northern uganda.'),
    ('NOTABLE_PEOPLE', 'Notable People', 'People recognised for significant public, cultural, professional or historical achievements.'),
    ('NYANYA_MBISI', 'Nyanya Mbisi', 'Local Knowledge about nyanya mbisi.'),
    ('OLIVIER_AWARDS', 'Olivier Awards', 'Local Knowledge about olivier awards.'),
    ('PACKING', 'Packing', 'Local Knowledge about packing.'),
    ('PEOPLE', 'People', 'Local Knowledge concerning named individuals or groups of people.'),
    ('PERMITS', 'Permits', 'Local Knowledge about permits.'),
    ('PHIONA_MUTESI', 'Phiona Mutesi', 'Local Knowledge about phiona mutesi.'),
    ('PHOTOGRAPHY', 'Photography', 'Local Knowledge about photography.'),
    ('PLACE_NAMES', 'Place Names', 'Local Knowledge about place names.'),
    ('PLACES_OF_WORSHIP', 'Places Of Worship', 'Local Knowledge about places of worship.'),
    ('PLUGS', 'Plugs', 'Local Knowledge about plugs.'),
    ('PRACTICAL_INFORMATION', 'Practical Information', 'Local Knowledge about practical information.'),
    ('QUEEN_ELIZABETH_NATIONAL_PARK', 'Queen Elizabeth National Park', 'Local Knowledge about queen elizabeth national park.'),
    ('QUEEN_OF_KATWE', 'Queen Of Katwe', 'Local Knowledge about queen of katwe.'),
    ('RAIN', 'Rain', 'Local Knowledge about rain.'),
    ('ROAD_SAFETY', 'Road Safety', 'Local Knowledge about road safety.'),
    ('ROLEX', 'Rolex', 'Local Knowledge about rolex.'),
    ('RUKIGA', 'Rukiga', 'Local Knowledge about rukiga.'),
    ('RUNYANKOLE', 'Runyankole', 'Local Knowledge about runyankole.'),
    ('RWENZORI_MOUNTAINS', 'Rwenzori Mountains', 'Local Knowledge about rwenzori mountains.'),
    ('SAFARI', 'Safari', 'Wildlife-viewing and nature experiences associated with safari travel.'),
    ('SAFETY', 'Safety', 'Local Knowledge about safety.'),
    ('SHEILA_ATIM', 'Sheila Atim', 'Local Knowledge about sheila atim.'),
    ('SHOEBILL', 'Shoebill', 'Local Knowledge about shoebill.'),
    ('SITYA_LOSS', 'Sitya Loss', 'Local Knowledge about sitya loss.'),
    ('SOCIAL_CUSTOMS', 'Social Customs', 'Local Knowledge about social customs.'),
    ('SPORT', 'Sport', 'Local Knowledge concerning sport, athletes and sporting achievement.'),
    ('SSESE_ISLANDS', 'Ssese Islands', 'Local Knowledge about ssese islands.'),
    ('STREET_FOOD', 'Street Food', 'Local Knowledge about street food.'),
    ('TELEVISION', 'Television', 'Local Knowledge about television.'),
    ('TESO', 'Teso', 'Local Knowledge about teso.'),
    ('THE_AFRICAN_QUEEN', 'The African Queen', 'Local Knowledge about the african queen.'),
    ('THE_LAST_KING_OF_SCOTLAND', 'The Last King Of Scotland', 'Local Knowledge about the last king of scotland.'),
    ('THEATRE', 'Theatre', 'Local Knowledge about theatre.'),
    ('TRAFFIC', 'Traffic', 'Local Knowledge about traffic.'),
    ('TRANSPORT', 'Transport', 'Local Knowledge about transport.'),
    ('UGANDA_KOB', 'Uganda Kob', 'Local Knowledge about uganda kob.'),
    ('UGANDAN_CUISINE', 'Ugandan Cuisine', 'Local Knowledge about ugandan cuisine.'),
    ('VIRUNGA_MOUNTAINS', 'Virunga Mountains', 'Local Knowledge about virunga mountains.'),
    ('VISITORS', 'Visitors', 'Local Knowledge about visitors.'),
    ('VOLCANOES', 'Volcanoes', 'Local Knowledge about volcanoes.'),
    ('WAKALIWOOD', 'Wakaliwood', 'Local Knowledge about wakaliwood.'),
    ('WATER', 'Water', 'Local Knowledge about water.'),
    ('WEATHER', 'Weather', 'Local Knowledge about weather.'),
    ('WETLANDS', 'Wetlands', 'Local Knowledge about wetlands.'),
    ('WHITNEY_PEAK', 'Whitney Peak', 'Local Knowledge about whitney peak.'),
    ('WHO_KILLED_CAPTAIN_ALEX', 'Who Killed Captain Alex', 'Local Knowledge about who killed captain alex.'),
    ('WILDLIFE', 'Wildlife', 'Local Knowledge about wildlife.'),
    ('YOUNG_CARDAMOM_AND_HAB', 'Young Cardamom And Hab', 'Local Knowledge about young cardamom and hab.')
ON CONFLICT (code) DO NOTHING;
-- ach: A Southern Luo language spoken mainly across Acholiland in northern Uganda.
-- cgg: A Bantu language spoken mainly in the Kigezi area of south-western Uganda.
-- lug: A major Ugandan language rooted in Buganda and widely spoken in Kampala and central Uganda.
-- nyn: A Bantu language spoken mainly across Ankole in south-western Uganda.
-- teo: An Eastern Nilotic language spoken mainly in the Teso sub-region of eastern Uganda.
-- xog: A Bantu language spoken mainly in Busoga in eastern Uganda.
INSERT INTO local_languages (code, name)
VALUES
    ('ach', 'Acholi'),
    ('cgg', 'Rukiga'),
    ('lg', 'Luganda'),
    ('nyn', 'Runyankole'),
    ('teo', 'Ateso'),
    ('xog', 'Lusoga')
ON CONFLICT (code) DO NOTHING;
INSERT INTO local_language_countries (language_code, country_code)
VALUES
    ('ach', 'UG'),
    ('cgg', 'UG'),
    ('lg', 'UG'),
    ('nyn', 'UG'),
    ('teo', 'UG'),
    ('xog', 'UG')
ON CONFLICT (language_code, country_code) DO NOTHING;

-- Temporary import data records the exact sheet row and resolved geographic code.
CREATE TEMP TABLE _kn_lk_v0_import (
    sheet_row integer PRIMARY KEY,
    id uuid NOT NULL UNIQUE,
    type_code varchar(50) NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    explanation text,
    country_code char(2) NOT NULL,
    area_code varchar(50),
    language_code varchar(10),
    tag_codes text NOT NULL
) ON COMMIT DROP;

INSERT INTO _kn_lk_v0_import
    (sheet_row, id, type_code, title, content, explanation,
     country_code, area_code, language_code, tag_codes)
VALUES
    ('2', '3a484521-f810-5400-9a83-484442d958d7', 'INSIDER_TIP', 'Nonstop tip', 'A superior rolex comes with fresh nyanya mbisi. We don’t make the rules, we just respect them.', NULL, 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX, NYANYA_MBISI'),
    ('3', 'adc5218e-66e3-5fec-a17e-0396b71814e7', 'INSIDER_TIP', 'Nonstop tip', 'A rolex should be made to order.', 'If it has been waiting for you longer than you have been waiting for it, my friend, reconsider.', 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX'),
    ('4', '5b20c15f-885e-54ee-b6ed-6253af0d77f7', 'INSIDER_TIP', 'Nonstop tip', 'A superior rolex is balanced: hot chapati, generous egg, fresh vegetables and just enough nyanya mbisi to make everything else behave.', NULL, 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX, NYANYA_MBISI'),
    ('5', 'e5f0d3da-22dc-55de-a691-2f095c5d6044', 'INSIDER_TIP', 'Nonstop tip', 'You can ask for your rolex without nyanya mbisi. No one will judge you.', NULL, 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX, NYANYA_MBISI'),
    ('6', '6c6d8030-8d98-50a7-8d08-79a1d2d4ea26', 'INSIDER_TIP', 'Nonstop tip', 'The best rolex is usually eaten immediately, standing somewhere you hadn’t planned to stop.', NULL, 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX'),
    ('7', 'cee1da43-7d8c-5e28-a773-8041598c8f20', 'PHRASE', 'Nyanya mbisi', 'Raw tomatoes in Luganda', 'A common rolex request—slices of fresh, uncooked tomato rather than tomato fried with the egg.', 'UG', 'BUGANDA', 'lg', 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX, NYANYA_MBISI, LANGUAGE'),
    ('8', '8036ebc7-d0d8-5277-9974-8ee39c12cec9', 'INSIDER_TIP', 'Fried tomatoes in rolex', 'Ask for fried tomatoes if you prefer them cooked', 'The tomato is cooked with the egg rather than added fresh.', 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX, FRIED_TOMATOES'),
    ('9', '6c52a434-62fd-5e3c-8f1e-bc606978a49c', 'FUN_FACT', 'A foot in both hemispheres', 'Uganda lies across the equator with tourist attractions around the line between the northern and southern hemispheres', NULL, 'UG', 'EQUATOR', NULL, 'EQUATOR, GEOGRAPHY'),
    ('10', 'd12e1868-3695-5e98-ab1f-7d5a976403b9', 'FUN_FACT', 'Pearl of Africa', 'Winston Churchill popularised the nickname while describing Uganda’s scenery and natural richness', NULL, 'UG', NULL, NULL, 'HISTORY, NATIONAL_IDENTITY, PEOPLE, NOTABLE_PEOPLE'),
    ('11', 'd9f96cb9-5495-533c-b510-08187706895e', 'FUN_FACT', 'Snow in Uganda', 'The Rwenzori Mountains have equatorial glaciers', 'Their highest peaks rise above 5,000 metres despite lying close to the equator.', 'UG', 'RWENZORI_MOUNTAINS', NULL, 'RWENZORI_MOUNTAINS, MOUNTAINS, NATURE'),
    ('12', '1971e86b-97a3-5331-a7bf-6c976bcf4b1d', 'FUN_FACT', 'Uganda Kob and Crowned Crane', 'are national symbols appearing together on Uganda’s coat of arms', 'The grey crowned crane also appears on the national flag.', 'UG', NULL, NULL, 'WILDLIFE, NATIONAL_SYMBOLS, UGANDA_KOB, GREY_CROWNED_CRANE'),
    ('13', 'bf7a2142-8ce9-5003-8c3f-0255b6d0310a', 'FUN_FACT', 'Tree-climbing lions', 'Lions climb trees in Queen Elizabeth National Park', 'The Ishasha sector is particularly associated with this unusual behaviour.', 'UG', 'ISHASHA', NULL, 'WILDLIFE, SAFARI, NATIONAL_PARKS, LIONS, QUEEN_ELIZABETH_NATIONAL_PARK'),
    ('14', '8789f807-592a-5037-8126-44a3c58e75a3', 'FUN_FACT', 'Three countries, one lake', 'Lake Victoria is shared by Uganda, Kenya and Tanzania', 'It is Africa’s largest lake by surface area.', 'UG', 'LAKE_VICTORIA', NULL, 'LAKES, LAKE_VICTORIA, GEOGRAPHY'),
    ('15', '766e534f-1f05-59ed-b1b0-250ada2cd7cd', 'FUN_FACT', 'Gorilla country', 'Uganda is one of three countries where mountain gorillas live wild', 'Gorilla tracking takes place in Bwindi and Mgahinga national parks.', 'UG', 'SOUTH_WEST', NULL, 'WILDLIFE, SAFARI, NATIONAL_PARKS, MOUNTAIN_GORILLAS, BWINDI, MGAHINGA'),
    ('16', '1bf92317-fe54-5777-b6db-8724654c1300', 'FUN_FACT', 'The Kazinga Channel', 'joins Lakes George and Edward', 'Its shores attract hippos, buffaloes, elephants and large numbers of waterbirds.', 'UG', 'KAZINGA_CHANNEL', NULL, 'LAKES, WILDLIFE, SAFARI, NATIONAL_PARKS, KAZINGA_CHANNEL, QUEEN_ELIZABETH_NATIONAL_PARK'),
    ('17', '3cfbc325-0d11-510e-93d5-7c97d03380f0', 'FUN_FACT', 'The name Kampala', 'comes from a reference to impala. The area was once described as the “hill of the impala”', NULL, 'UG', 'KAMPALA', NULL, 'KAMPALA, PLACE_NAMES, HISTORY'),
    ('18', '25eec367-4b98-5616-a989-6af7e996f034', 'FUN_FACT', 'Shoebill', 'Uganda is one of the best places to see the shoebill', 'This enormous wetland bird takes its name from its shoe-shaped bill.', 'UG', NULL, NULL, 'WILDLIFE, SAFARI, BIRDS, SHOEBILL, WETLANDS'),
    ('19', 'c38b480b-6feb-5a87-ba4f-97d382c91e91', 'FUN_FACT', 'Place of many little birds', 'Lake Bunyonyi’s name refers to the birdlife found around it', 'The lake sits among terraced hills in south-western Uganda.', 'UG', 'LAKE_BUNYONYI', NULL, 'LAKES, LAKE_BUNYONYI, BIRDS, PLACE_NAMES'),
    ('20', 'dd68adc9-2113-53cb-9f13-887dd75ddb7b', 'FUN_FACT', 'A lake of islands', 'Lake Bunyonyi contains 29 islands', 'Some of the islands carry significant local histories and legends.', 'UG', 'LAKE_BUNYONYI', NULL, 'LAKES, LAKE_BUNYONYI, ISLANDS'),
    ('21', '1e209399-3eca-5838-a900-37f1414bf792', 'FUN_FACT', 'Uganda’s island archipelago', 'The Ssese archipelago contains 84 islands in Lake Victoria', 'Bugala is the largest of the group.', 'UG', 'SSESE_ISLANDS', NULL, 'LAKES, LAKE_VICTORIA, SSESE_ISLANDS, ISLANDS'),
    ('22', 'c00cebc8-46a6-517e-bb22-abcaeb930410', 'FUN_FACT', 'A lake shared with Congo', 'Lake Albert forms part of Uganda’s border with the Democratic Republic of the Congo', 'It belongs to the African Great Lakes system.', 'UG', 'LAKE_ALBERT', NULL, 'LAKES, LAKE_ALBERT, BORDERS, GEOGRAPHY'),
    ('23', '600f1325-88fb-5d53-9a5e-e0be3f6689fc', 'FUN_FACT', 'Lakes born from volcanoes', 'Western Uganda contains numerous crater lakes formed through volcanic activity', 'Many are concentrated around Fort Portal and the Queen Elizabeth National Park region.', 'UG', 'CRATER_LAKES', NULL, 'LAKES, CRATER_LAKES, VOLCANOES, GEOLOGY'),
    ('24', 'c27f4972-60a1-5506-8786-47b8ce359994', 'FUN_FACT', 'Lake among the volcanoes', 'Lake Mutanda lies beneath the Virunga Mountains', 'Its waters offer views towards the volcanic peaks near Uganda’s south-western border.', 'UG', 'LAKE_MUTANDA', NULL, 'LAKES, LAKE_MUTANDA, VIRUNGA_MOUNTAINS, VOLCANOES'),
    ('25', '2f6df454-e93d-56e4-9ca6-d1862d8a2aaf', 'FUN_FACT', 'Luganda', 'is rooted in Buganda and widely spoken across central Uganda, including Kampala', 'It is also commonly used between speakers of different languages in Kampala and other urban areas.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, BUGANDA, KAMPALA'),
    ('26', 'a78123a0-cb82-5c35-b726-0d28672b3e8b', 'FUN_FACT', 'Runyankole–Rukiga', 'is spoken across south-western Uganda, particularly around Ankole and Kigezi', 'Runyankole and Rukiga are closely related, although speakers retain distinct identities.', 'UG', 'SOUTH_WEST', 'nyn', 'LANGUAGE, RUNYANKOLE, RUKIGA, ANKOLE, KIGEZI'),
    ('27', '1c18a4e9-7ab5-5cf9-9208-c5e2b4e76f30', 'FUN_FACT', 'Ateso', 'is spoken mainly in the Teso sub-region of eastern Uganda', 'The language crosses the national border and is also spoken by Iteso communities in western Kenya.', 'UG', 'TESO', 'teo', 'LANGUAGE, ATESO, TESO, EASTERN_UGANDA'),
    ('28', 'e8bed714-04a1-5668-b1c0-9cbb2583a5bc', 'FUN_FACT', 'Lusoga', 'is spoken mainly in Busoga in eastern Uganda', 'Busoga lies broadly between Lake Victoria, Lake Kyoga, the Nile and the Mpologoma River.', 'UG', 'BUSOGA', 'xog', 'LANGUAGE, LUSOGA, BUSOGA, EASTERN_UGANDA'),
    ('29', '275103aa-4291-55e7-b3c6-97623493c325', 'FUN_FACT', 'Acholi', 'is spoken across Acholiland in northern Uganda', 'It is also spoken by Acholi communities across the border in South Sudan.', 'UG', 'ACHOLILAND', 'ach', 'LANGUAGE, ACHOLI, ACHOLILAND, NORTHERN_UGANDA'),
    ('30', '0080dd14-f832-5ccd-bcf8-d93849881171', 'FUN_FACT', 'Queen of Katwe', 'tells the true story of Ugandan chess player Phiona Mutesi', 'Parts of the Disney film were shot in Katwe, where its story is set.', 'UG', 'KATWE', NULL, 'FILM, PEOPLE, NOTABLE_PEOPLE, QUEEN_OF_KATWE, PHIONA_MUTESI, CHESS, SPORT, KATWE'),
    ('31', '4532c87b-c4f2-5b3d-b907-057a4aa70796', 'FUN_FACT', 'From Katwe to Disney', 'Ugandan dancer Madina Nalwanga made her film debut playing Phiona Mutesi', 'She was discovered during a casting search involving nearly 700 girls.', 'UG', 'KATWE', NULL, 'FILM, PEOPLE, NOTABLE_PEOPLE, QUEEN_OF_KATWE, MADINA_NALWANGA, KATWE'),
    ('32', '854084c5-8d47-56bc-bde5-0153de34485a', 'FUN_FACT', 'An Oscar-winning Amin', 'Forest Whitaker won the Academy Award for portraying Idi Amin in The Last King of Scotland', 'Much of the film was shot on location in Uganda.', 'UG', NULL, NULL, 'FILM, PEOPLE, NOTABLE_PEOPLE, AWARDS, THE_LAST_KING_OF_SCOTLAND, FOREST_WHITAKER, ACADEMY_AWARDS'),
    ('33', 'd90696e4-c6dc-53fb-9d86-378f7d74aa9d', 'FUN_FACT', 'The African Queen', 'filmed scenes around Lake Albert and Murchison Falls in 1951', 'The production starred Humphrey Bogart and Katharine Hepburn.', 'UG', 'MURCHISON_FALLS', NULL, 'FILM, PEOPLE, NOTABLE_PEOPLE, THE_AFRICAN_QUEEN, LAKE_ALBERT, MURCHISON_FALLS'),
    ('34', '7a2a7e9b-eb15-598a-99a6-90206a391de9', 'FUN_FACT', 'Welcome to Wakaliwood', 'Wakaliga in Kampala is home to Uganda’s celebrated low-budget action-film movement', 'Its best-known production is Who Killed Captain Alex?', 'UG', 'WAKALIGA', NULL, 'FILM, WAKALIWOOD, WHO_KILLED_CAPTAIN_ALEX, KAMPALA'),
    ('35', 'ab8893ba-f18f-505c-8017-a87504c1dce7', 'FUN_FACT', 'Uganda in Wakanda', 'Kampala-born Florence Kasumba plays Dora Milaje warrior Ayo in the Marvel Cinematic Universe', 'She appears in Black Panther, Avengers: Infinity War and other Marvel productions.', 'UG', 'KAMPALA', NULL, 'FILM, TELEVISION, PEOPLE, NOTABLE_PEOPLE, FLORENCE_KASUMBA, BLACK_PANTHER, MARVEL, KAMPALA'),
    ('36', '039ab072-e834-5848-b38c-3279dcc6cbe4', 'FUN_FACT', 'XOXO, Kampala', 'Gossip Girl star Whitney Peak was born in Kampala', 'The Ugandan-Canadian actor also appeared in Hocus Pocus 2 and Chilling Adventures of Sabrina.', 'UG', 'KAMPALA', NULL, 'FILM, TELEVISION, PEOPLE, NOTABLE_PEOPLE, WHITNEY_PEAK, GOSSIP_GIRL, KAMPALA'),
    ('37', '58e53123-36d8-5874-9542-0b69f06134b7', 'FUN_FACT', 'Two Olivier Awards', 'Uganda-born Sheila Atim has won Olivier Awards for both supporting and leading performances', 'She is also a singer, composer and playwright.', 'UG', NULL, NULL, 'THEATRE, FILM, TELEVISION, MUSIC, PEOPLE, NOTABLE_PEOPLE, AWARDS, SHEILA_ATIM, OLIVIER_AWARDS'),
    ('38', '895cbe5c-fd70-5507-b98c-eb36fbf1b119', 'FUN_FACT', 'Sitya Loss goes global', 'Eddy Kenzo’s Sitya Loss gained international attention through a viral video featuring the Ghetto Kids', 'The song helped introduce the Ugandan performers to audiences worldwide.', 'UG', NULL, NULL, 'MUSIC, PEOPLE, NOTABLE_PEOPLE, EDDY_KENZO, SITYA_LOSS, GHETTO_KIDS'),
    ('39', '66b33145-99da-5ed7-83d7-50dd0628238f', 'FUN_FACT', 'A Ugandan BET first', 'Eddy Kenzo became the first Ugandan artist to win a BET Award in 2015', 'He won the Viewer’s Choice award for Best New International Artist.', 'UG', NULL, NULL, 'MUSIC, PEOPLE, NOTABLE_PEOPLE, AWARDS, EDDY_KENZO, BET_AWARDS'),
    ('40', '38e4a6fe-cf35-58b8-ab45-0230f63ec2d7', 'FUN_FACT', 'Kampala on the soundtrack', 'Queen of Katwe featured music by Kampala duo Young Cardamom and HAB', 'Their song #1 Spice was created specifically for the film.', 'UG', 'KAMPALA', NULL, 'FILM, MUSIC, PEOPLE, NOTABLE_PEOPLE, QUEEN_OF_KATWE, YOUNG_CARDAMOM_AND_HAB, KAMPALA'),
    ('41', '111b3142-b03e-5650-a4ce-82d8b4c5fd28', 'FUN_FACT', 'Four cinematic universes', 'Kampala-born Florence Kasumba has appeared in Marvel, DC, The Lion King and Emerald City', 'Her roles include Ayo, Senator Acantha, Shenzi and the Wicked Witch of the East.', 'UG', 'KAMPALA', NULL, 'FILM, TELEVISION, PEOPLE, NOTABLE_PEOPLE, FLORENCE_KASUMBA, KAMPALA'),
    ('42', 'f1ab9bb6-b493-5213-b6a4-0463d3b33251', 'PHRASE', 'Webale', 'Thank you in Luganda', 'Use webale nnyo to say “thank you very much”.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, GREETINGS'),
    ('43', 'fbca9ce8-aa7d-5200-9d51-3e91752fa344', 'PHRASE', 'Oli otya?', 'How are you? in Luganda', 'An everyday greeting addressed to one person.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, GREETINGS'),
    ('44', '73afd797-764d-51e4-b145-790f839850a0', 'PHRASE', 'Gyebale ko', 'A Luganda greeting acknowledging someone’s work', 'Often translated as “well done”, it is also used as a general greeting.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, GREETINGS'),
    ('45', '97fa19f6-eae1-500a-8fb4-cc4470361a2e', 'PHRASE', 'Kale', 'Okay, then or alright in Luganda', 'The precise meaning depends on tone and context.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA'),
    ('46', '0edc3f79-f17b-5585-b10c-f635132b3f01', 'PHRASE', 'Mpola mpola', 'Slowly, slowly in Luganda', 'Useful when asking someone to reduce their speed or take things gently.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA'),
    ('47', 'fb5a54bc-0075-528d-b0e2-a3fb3a31ca7f', 'PHRASE', 'Ssebo', 'A respectful Luganda term for a man', 'Similar to “sir” in everyday conversation.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, ETIQUETTE'),
    ('48', '56ebb521-1912-51e6-93f4-f868d30a6732', 'PHRASE', 'Nnyabo', 'A respectful Luganda term for a woman', 'Similar to “madam” in everyday conversation.', 'UG', 'BUGANDA', 'lg', 'LANGUAGE, LUGANDA, ETIQUETTE'),
    ('49', '15cc8a83-9711-5898-a439-97901156ef92', 'PHRASE', 'Boda boda', 'A term used across Uganda for a motorcycle taxi', 'It is usually shortened to “boda”; the name developed from “border-to-border”.', 'UG', NULL, NULL, 'LANGUAGE, TRANSPORT, BODA_BODA'),
    ('50', '04c0b370-ea9b-55d2-abb5-7eb0a49d0f92', 'PHRASE', 'Muzungu', 'A term widely used across Uganda and East Africa for a white person or foreign visitor', 'It may be descriptive, playful or attention-seeking depending on context.', 'UG', NULL, NULL, 'LANGUAGE, EAST_AFRICA, VISITORS'),
    ('51', 'cab5ea20-0062-5ec1-9896-2c1bf0805faf', 'ETIQUETTE', 'Greetings first', 'Greet people before getting down to business', 'Beginning immediately with a request can feel abrupt or overly transactional.', 'UG', NULL, NULL, 'ETIQUETTE, GREETINGS'),
    ('52', 'eeb414bd-ca2c-59d7-9b8f-e3cf46d37b26', 'ETIQUETTE', 'Taking photographs', 'Ask before photographing someone', 'Be particularly considerate around children, homes and ceremonies.', 'UG', NULL, NULL, 'ETIQUETTE, PHOTOGRAPHY'),
    ('53', '04fef5d3-2c8b-50f5-b827-13f52c3f380c', 'ETIQUETTE', 'How are you?', 'Give a genuine answer before returning the question', 'It is often a real social exchange rather than a passing formality.', 'UG', NULL, NULL, 'ETIQUETTE, GREETINGS'),
    ('54', '08f3e3ec-93d8-54bf-a55f-876d4a32673d', 'ETIQUETTE', 'Ssebo and nnyabo', 'Use these respectful Luganda terms when addressing someone politely', 'Ssebo addresses a man; nnyabo addresses a woman.', 'UG', 'BUGANDA', 'lg', 'ETIQUETTE, LANGUAGE, LUGANDA'),
    ('55', 'afb79598-896a-5aa5-b4c6-fe1eba720b5f', 'ETIQUETTE', 'Dress respectfully', 'Cover your shoulders and knees in conservative settings', 'This is especially appropriate in places of worship and at formal community occasions.', 'UG', NULL, NULL, 'ETIQUETTE, CLOTHING, PLACES_OF_WORSHIP'),
    ('56', 'ee6196ad-a128-5ed4-a910-4c30b3b6d68a', 'ETIQUETTE', 'Follow your host', 'Let your host guide introductions, greetings and seating', 'Social order may reflect age, status or family relationships that are not immediately obvious.', 'UG', NULL, NULL, 'ETIQUETTE, CEREMONIES, GREETINGS'),
    ('57', 'cd444374-4d8b-5673-829b-4b3893894449', 'ETIQUETTE', 'Use your right hand', 'Give, receive and eat with your right hand where practical', 'The left hand is traditionally associated with personal hygiene and may be considered unsuitable for handling food or passing items.', 'UG', NULL, NULL, 'ETIQUETTE, DINING'),
    ('58', 'd829575e-3a16-55fa-9fba-9c6959f50b7f', 'ETIQUETTE', 'Greet the room', 'Acknowledge the wider group when you arrive', 'Greeting only the person you came to see can appear dismissive.', 'UG', NULL, NULL, 'ETIQUETTE, GREETINGS'),
    ('59', '9f610a53-6461-50fd-a99b-fa89bcd7edf1', 'ETIQUETTE', 'Public affection', 'Keep public displays of affection discreet', 'Attitudes vary, but many public and community settings remain socially conservative.', 'UG', NULL, NULL, 'ETIQUETTE, SOCIAL_CUSTOMS'),
    ('60', 'd811529a-08a6-5a87-9403-895fd6bc463e', 'ETIQUETTE', 'Cultural ceremonies', 'Ask your host about expectations beforehand', 'Appropriate clothing, gifts, photography and arrival times can vary by ceremony and community.', 'UG', NULL, NULL, 'ETIQUETTE, CEREMONIES'),
    ('61', '6793f2d5-a554-5e62-9e79-b3898f5ff5a1', 'PRACTICAL_TIP', 'What is a rolex?', 'A popular Ugandan street food made with an omelette wrapped in chapati', 'The name is generally understood as a play on “rolled eggs”.', 'UG', NULL, NULL, 'FOOD, STREET_FOOD, UGANDAN_CUISINE, ROLEX'),
    ('62', 'ebc67df2-b3be-5878-8f4c-71de6b1779ad', 'PRACTICAL_TIP', 'Carry small banknotes', 'Drivers and vendors may struggle to change large denominations', 'Small cash payments remain common.', 'UG', NULL, NULL, 'MONEY, CASH, PRACTICAL_INFORMATION'),
    ('63', 'f05019fc-cc5a-501e-9e5c-0b1e20581e65', 'PRACTICAL_TIP', 'Mobile money', 'Confirm the recipient’s name before sending mobile money', 'Payments may be made to personal telephone numbers.', 'UG', NULL, NULL, 'MONEY, MOBILE_MONEY, PRACTICAL_INFORMATION'),
    ('64', 'ce789c30-2581-585a-ad7d-b0522fccb922', 'PRACTICAL_TIP', 'Kampala traffic', 'Allow more time than the distance suggests', 'Rush hour and heavy rain can change journey times sharply.', 'UG', 'KAMPALA', NULL, 'TRANSPORT, TRAFFIC, KAMPALA'),
    ('65', '68e4c513-554e-5dae-aaf2-dee59c42fe84', 'PRACTICAL_TIP', 'Taking a boda', 'Wear a helmet and use a trusted or app-booked rider', 'Confirm the fare before setting off if the journey is not booked through an app.', 'UG', NULL, NULL, 'TRANSPORT, BODA_BODA, SAFETY'),
    ('66', '8e664dcb-d281-5d0a-bc8b-ce39bb900bfd', 'PRACTICAL_TIP', 'Driving in Uganda', 'Traffic keeps to the left', 'Watch for motorcycles passing beside or between stationary vehicles.', 'UG', NULL, NULL, 'TRANSPORT, DRIVING, ROAD_SAFETY'),
    ('67', '08468225-a0dd-5714-b134-22c377dc084f', 'PRACTICAL_TIP', 'Plug sockets', 'Uganda mainly uses British-style Type G plugs', 'The sockets take three rectangular pins and normally supply 240 volts.', 'UG', NULL, NULL, 'ELECTRICITY, PLUGS, PRACTICAL_INFORMATION'),
    ('68', 'c4b12351-4b6e-560b-80f1-ba88a5aee500', 'PRACTICAL_TIP', 'Pack for rain', 'Carry a light waterproof layer', 'A clear morning can still become a wet afternoon.', 'UG', NULL, NULL, 'WEATHER, PACKING, RAIN'),
    ('69', '53c01266-2536-5292-97c6-f0df8ec5920f', 'PRACTICAL_TIP', 'Nonstop tip', 'Book gorilla and chimpanzee tracking permits in advance', 'Permits are limited—but Kampala Nonstop can help you secure one and plan the rest of your trip around it.', 'UG', NULL, NULL, 'WILDLIFE, SAFARI, NATIONAL_PARKS, MOUNTAIN_GORILLAS, CHIMPANZEES, PERMITS, KAMPALA_NONSTOP'),
    ('70', '3b398af3-2583-5786-82de-958e6b915916', 'PRACTICAL_TIP', 'Drinking water', 'Choose sealed bottled or properly treated water', 'Check that the bottle cap and safety seal are intact before drinking.', 'UG', NULL, NULL, 'HEALTH, WATER, PRACTICAL_INFORMATION'),
    ('71', 'ff5d4d1d-bdd9-5488-87d0-d51f113f399a', 'INSIDER_TIP', 'Nonstop tip', 'Context matters when asking for a rolex', 'One is street food. The other requires a very different budget.', 'UG', NULL, NULL, 'FOOD, STREET_FOOD, ROLEX, HUMOUR'),
    ('72', 'a191ccbc-4ee4-560e-9c0d-9d2a85c60b8d', 'INSIDER_TIP', 'Follow the queue', 'A busy food stall with regular customers is usually telling you something', NULL, 'UG', NULL, NULL, 'FOOD, STREET_FOOD, LOCAL_LIFE'),
    ('73', 'a6277e8f-d418-5f9d-99d9-90492c106e42', 'INSIDER_TIP', 'Before taking a boda', 'Agree the fare before setting off', 'It avoids an energetic roadside negotiation at the other end.', 'UG', NULL, NULL, 'TRANSPORT, BODA_BODA, MONEY'),
    ('74', '6bb6ced7-2d49-583e-9783-eba9146c560a', 'INSIDER_TIP', 'Rain rewrites Kampala', 'Leave early when rain is expected—even a short shower can change traffic quickly', NULL, 'UG', 'KAMPALA', NULL, 'WEATHER, RAIN, TRAFFIC, KAMPALA'),
    ('75', '3b9823dd-2794-5dbf-9ce2-c341fbe8db51', 'INSIDER_TIP', 'Getting around', 'Give the destination, then add a landmark', 'A nearby building, junction or business may be more useful than a street number.', 'UG', NULL, NULL, 'TRANSPORT, DIRECTIONS, LANDMARKS'),
    ('76', 'cce2d3f4-7dd6-5bba-8ede-6b676085a330', 'INSIDER_TIP', 'Getting around', 'Let the driver call', 'A quick telephone conversation may solve the final directions faster.', 'UG', NULL, NULL, 'TRANSPORT, DIRECTIONS'),
    ('77', '924b4af3-bd7f-50c8-9d77-59f9e0300cf1', 'INSIDER_TIP', 'Fresh juice', 'Ask whether sugar has already been added', '“No sugar” works best before the blender starts.', 'UG', NULL, NULL, 'FOOD, DRINKS, JUICE'),
    ('78', 'ccbb6031-3a84-5fe7-add4-60984fde29f1', 'INSIDER_TIP', 'Plan the journey home', 'Arrange late-night transport before heading out', 'Availability, prices and pickup points may differ from daytime journeys.', 'UG', NULL, NULL, 'TRANSPORT, NIGHTLIFE, SAFETY'),
    ('79', '23ec4c8a-e46d-52e8-bc0d-e7481e54a20e', 'CULTURAL_CONTEXT', 'Why greetings matter', 'Greetings establish respect before the conversation becomes transactional', NULL, 'UG', NULL, NULL, 'CULTURE, GREETINGS, SOCIAL_CUSTOMS'),
    ('80', 'f6727736-b865-5b37-84e3-831b44a7d3d8', 'CULTURAL_CONTEXT', 'Why is it called a rolex?', 'The name is generally understood as a play on “rolled eggs”', 'The omelette is rolled inside a chapati.', 'UG', NULL, NULL, 'FOOD, ROLEX, PLACE_NAMES'),
    ('81', '12e01376-0e8c-58d0-a968-9f4d5ee53ef0', 'CULTURAL_CONTEXT', 'What is a kwanjula?', 'A formal introduction ceremony in Buganda culture that brings two families together', 'It publicly recognises a couple’s relationship.', 'UG', 'BUGANDA', NULL, 'CULTURE, BUGANDA, KWANJULA, CEREMONIES'),
    ('82', '18a94214-1dae-528a-b562-f211a9af878a', 'CULTURAL_CONTEXT', 'What is a gomesi?', 'A formal dress associated with women in Buganda', 'It is often worn at weddings, introductions and important celebrations.', 'UG', 'BUGANDA', NULL, 'CULTURE, BUGANDA, GOMESI, CLOTHING'),
    ('83', '20326962-501b-5a59-a451-cad6fc224646', 'CULTURAL_CONTEXT', 'What is a kanzu?', 'A long formal garment commonly worn by Ugandan men', 'It is particularly visible at weddings, religious occasions and cultural ceremonies.', 'UG', NULL, NULL, 'CULTURE, KANZU, CLOTHING, CEREMONIES'),
    ('84', '8f693fbb-a9bf-5fd9-8f12-3fd17539969f', 'CULTURAL_CONTEXT', 'Barkcloth', 'Traditional Ugandan barkcloth is made from the mutuba tree', 'Its production carries longstanding cultural knowledge and craftsmanship.', 'UG', NULL, NULL, 'CULTURE, BARKCLOTH, CRAFTS, HERITAGE'),
    ('85', 'fd2b9864-1f58-5e1f-b371-64501f28e58b', 'CULTURAL_CONTEXT', 'Clan identity', 'remains important in many Ugandan communities', 'Depending on the community, it may shape ancestry, names, marriage conventions, totems and cultural responsibilities.', 'UG', NULL, NULL, 'CULTURE, CLANS, SOCIAL_CUSTOMS'),
    ('86', 'd413acec-ce4f-5fa7-acde-9b34875e4697', 'CULTURAL_CONTEXT', 'Matooke', 'is more than an everyday staple in central Uganda', 'The steamed cooking banana also carries strong social and cultural significance.', 'UG', 'CENTRAL', NULL, 'FOOD, UGANDAN_CUISINE, MATOOKE, CULTURE'),
    ('87', '6f6bce29-b9c4-53fb-bceb-ea0de8498de0', 'CULTURAL_CONTEXT', 'The wider community', 'Major life events often extend beyond the immediate family', 'Weddings, introductions and funerals may involve a much broader community.', 'UG', NULL, NULL, 'CULTURE, COMMUNITY, CEREMONIES'),
    ('88', 'e0f566c8-c320-581a-b934-4465676f8dad', 'CULTURAL_CONTEXT', 'Respect for elders', 'Age commonly carries social authority', 'Greetings, titles and speaking order may reflect that respect.', 'UG', NULL, NULL, 'CULTURE, ELDERS, ETIQUETTE');

-- Abort the entire transaction if reference data is missing or ambiguous.
DO $validate$
BEGIN
    IF (SELECT count(*) FROM _kn_lk_v0_import) <> 87 THEN
        RAISE EXCEPTION 'Expected 87 Local Knowledge rows';
    END IF;
    IF EXISTS (
        SELECT 1 FROM _kn_lk_v0_import s
        WHERE NOT EXISTS (SELECT 1 FROM local_knowledge_types t WHERE t.code=s.type_code)
    ) THEN
        RAISE EXCEPTION 'Missing Local Knowledge types: run 4_1 seed script first';
    END IF;
    IF EXISTS (
        SELECT 1 FROM _kn_lk_v0_import s
        WHERE s.area_code IS NOT NULL AND
          (SELECT count(*) FROM geographic_areas g
           WHERE g.code=s.area_code AND g.country_code=s.country_code) <> 1
    ) THEN
        RAISE EXCEPTION 'Missing or ambiguous geographic area: run geographic seed script first';
    END IF;
    IF EXISTS (
        SELECT 1 FROM _kn_lk_v0_import s
        WHERE s.language_code IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM local_language_countries l
            WHERE l.language_code=s.language_code AND l.country_code=s.country_code)
    ) THEN
        RAISE EXCEPTION 'Missing language/country mapping';
    END IF;
    IF EXISTS (
        SELECT 1 FROM _kn_lk_v0_import s
        CROSS JOIN LATERAL unnest(string_to_array(s.tag_codes, ',')) AS codes(code)
        WHERE NOT EXISTS (SELECT 1 FROM local_knowledge_tags t WHERE t.code=btrim(codes.code))
    ) THEN
        RAISE EXCEPTION 'Missing tag reference';
    END IF;
END;
$validate$;

INSERT INTO local_knowledge (
    id, local_knowledge_type_id, country_code, geographic_area_id,
    local_language_code, title, content, explanation
)
SELECT s.id, t.id, s.country_code, g.id,
       s.language_code, s.title, s.content, s.explanation
FROM _kn_lk_v0_import s
JOIN local_knowledge_types t ON t.code=s.type_code
LEFT JOIN geographic_areas g ON g.code=s.area_code AND g.country_code=s.country_code
ORDER BY s.sheet_row
ON CONFLICT (id) DO NOTHING;

INSERT INTO local_knowledge_tag_links (local_knowledge_id, tag_id)
SELECT s.id, t.id
FROM _kn_lk_v0_import s
CROSS JOIN LATERAL unnest(string_to_array(s.tag_codes, ',')) AS codes(code)
JOIN local_knowledge_tags t ON t.code=btrim(codes.code)
ON CONFLICT (local_knowledge_id, tag_id) DO NOTHING;

-- Also correct this entry if the earlier version of this script was already run.
UPDATE local_knowledge
SET local_language_code = 'nyn', updated_at = CURRENT_TIMESTAMP
WHERE id = 'a78123a0-cb82-5c35-b726-0d28672b3e8b'::uuid
  AND local_language_code IS DISTINCT FROM 'nyn';

COMMIT;
