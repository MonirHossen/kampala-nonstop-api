-- Kampala Nonstop / Africa Nonstop
-- Uganda Country Guide Essentials population script
-- PostgreSQL
--
-- Canonical population is database/seeders/CountryGuideUgandaSeeder.php
-- (25 live values: 13 narrative sections + 12 fact tiles).
-- This script mirrors that seeder for non-Laravel environments.
--
-- Prerequisite:
--   country_guide_essential_types must already be populated
--   (see 5_1_kampala_nonstop_country_guide_lookup_seed.sql).
--
-- Idempotent:
--   Re-running this script updates existing Uganda values by
--   (country_code, essential_type_id).

BEGIN;

WITH essential_values (
    essential_type_code,
    value_text,
    value_data,
    is_live
) AS (
    VALUES
        (
            'ABOUT',
            E'Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.\n\nDubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.',
            '{"blocks":[{"text":"Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.","type":"paragraph"},{"text":"Dubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.","type":"paragraph"}],"display":"narrative","heading":"About Uganda","paragraphs":["Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.","Dubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders."]}'::jsonb,
            TRUE
        ),
        (
            'HISTORY',
            E'Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.\n\nBefore modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.\n\nUganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.\n\nToday, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.',
            '{"blocks":[{"text":"Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.","type":"paragraph"},{"text":"Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.","type":"paragraph"},{"text":"Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.","type":"paragraph"},{"text":"Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.","type":"paragraph"}],"display":"narrative","heading":"History of Uganda","paragraphs":["Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.","Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.","Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.","Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence."]}'::jsonb,
            TRUE
        ),
        (
            'CULTURE_TRADITIONS',
            E'Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.\n\nYou’ll notice a few cultural constants quickly:\n\nGreetings matter; people acknowledge each other properly.\n\nHumour is dry, teasing and often self-aware.\n\nMusic is constant — taxis, salons, bars, weddings.\n\nFood is social and shared.\n\nBeing addressed as “my brother” or “my sister” shortly after meeting someone isn’t metaphorical. It’s how social ease is established.',
            '{"blocks":[{"text":"Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.","type":"paragraph"},{"text":"You’ll notice a few cultural constants quickly:","type":"paragraph"},{"type":"list","items":[{"text":"Greetings matter; people acknowledge each other properly."},{"text":"Humour is dry, teasing and often self-aware."},{"text":"Music is constant — taxis, salons, bars, weddings."},{"text":"Food is social and shared."},{"text":"Being addressed as “my brother” or “my sister” shortly after meeting someone isn’t metaphorical. It’s how social ease is established."}]}],"display":"narrative","heading":"Culture & Traditions","paragraphs":["Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.","You’ll notice a few cultural constants quickly:"]}'::jsonb,
            TRUE
        ),
        (
            'FOOD_DRINK_SOCIAL',
            E'Food in Uganda is practical, filling and deeply social.\n\nEveryday staples and rituals include:\n\nRolex — A freshly made chapati rolled with eggs and vegetables, cooked to order — often with nyanya mbisi (raw tomatoes) added — and eaten on the go. A fan favourite with foreign visitors, often one of the first foods people actively seek out again after leaving Uganda.\n\nGrilled meats (nyama choma) — Goat, beef or chicken, usually shared late into the evening.\n\nMatooke — Steamed green bananas, groundnut sauces and smoked fish near lakes and rivers.\n\nUganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.\n\nDrinking here is rarely rushed. Conversations usually outlast the drinks.',
            '{"blocks":[{"text":"Food in Uganda is practical, filling and deeply social.","type":"paragraph"},{"text":"Everyday staples and rituals include:","type":"paragraph"},{"type":"list","items":[{"text":"A freshly made chapati rolled with eggs and vegetables, cooked to order — often with nyanya mbisi (raw tomatoes) added — and eaten on the go. A fan favourite with foreign visitors, often one of the first foods people actively seek out again after leaving Uganda.","label":"Rolex"},{"text":"Goat, beef or chicken, usually shared late into the evening.","label":"Grilled meats (nyama choma)"},{"text":"Steamed green bananas, groundnut sauces and smoked fish near lakes and rivers.","label":"Matooke"}]},{"text":"Uganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.","type":"paragraph"},{"text":"Drinking here is rarely rushed. Conversations usually outlast the drinks.","type":"paragraph"}],"display":"narrative","heading":"Food, Drink & Social Life","paragraphs":["Food in Uganda is practical, filling and deeply social.","Everyday staples and rituals include:","Uganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.","Drinking here is rarely rushed. Conversations usually outlast the drinks."]}'::jsonb,
            TRUE
        ),
        (
            'LANGUAGES_COMMUNICATION',
            E'English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.\n\nLuganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.\n\nVisitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:\n\nWebale — Thank you.\n\nSsebo — A respectful form of address for a man.\n\nNnyabo — A respectful form of address for a woman.\n\nThey signal politeness and are universally appreciated.',
            '{"blocks":[{"text":"English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.","type":"paragraph"},{"text":"Luganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.","type":"paragraph"},{"text":"Visitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:","type":"paragraph"},{"type":"list","items":[{"text":"Thank you.","label":"Webale"},{"text":"A respectful form of address for a man.","label":"Ssebo"},{"text":"A respectful form of address for a woman.","label":"Nnyabo"}]},{"text":"They signal politeness and are universally appreciated.","type":"paragraph"}],"display":"narrative","heading":"Languages & Communication","paragraphs":["English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.","Luganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.","Visitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:","They signal politeness and are universally appreciated."]}'::jsonb,
            TRUE
        ),
        (
            'GEOGRAPHY_CLIMATE',
            E'Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.\n\nKey features include:\n\nLake Victoria — Africa’s largest lake by surface area\n\nThe source of the Nile at Jinja\n\nSavannah landscapes in the north and west\n\nRainforests and mountain ranges in the southwest\n\nClimate\n\nWarm year-round (average 25–28°C)\n\nTwo rainy seasons: March–May and September–November\n\nRain is usually brief rather than constant\n\nThis fertile environment supports year-round agriculture and an abundance of fresh food across the country.',
            '{"blocks":[{"text":"Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.","type":"paragraph"},{"text":"Key features include:","type":"paragraph"},{"type":"list","items":[{"text":"Lake Victoria — Africa’s largest lake by surface area"},{"text":"The source of the Nile at Jinja"},{"text":"Savannah landscapes in the north and west"},{"text":"Rainforests and mountain ranges in the southwest"}]},{"text":"Climate","type":"subheading"},{"type":"list","items":[{"text":"Warm year-round (average 25–28°C)"},{"text":"Two rainy seasons: March–May and September–November"},{"text":"Rain is usually brief rather than constant"}]},{"text":"This fertile environment supports year-round agriculture and an abundance of fresh food across the country.","type":"paragraph"}],"display":"narrative","heading":"Geography & Climate","paragraphs":["Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.","Key features include:","This fertile environment supports year-round agriculture and an abundance of fresh food across the country."]}'::jsonb,
            TRUE
        ),
        (
            'MAJOR_DESTINATIONS',
            E'Uganda’s key destinations are spread across the country and serve different roles:\n\nKampala — The capital and primary international city; centre of government, business, nightlife, culture and events.\n\nEntebbe — International gateway on Lake Victoria, home to the main airport and a calmer lakeside pace.\n\nJinja — Adventure and leisure hub, known globally as the source of the Nile and for white-water rafting.\n\nGulu — The main city of northern Uganda, culturally distinct, with historical significance and a growing urban scene shaped by resilience, creativity and a slower, more expansive rhythm of life.\n\nWestern Uganda — The country’s most diverse region, bringing together savannah wildlife, primate forests, crater lakes, mountain landscapes, iconic road trips and pastoral Ankole culture within a single journey.\n\nMurchison Falls National Park — Flagship wildlife destination combining dramatic landscapes with classic safari experiences.\n\nQueen Elizabeth National Park — Biodiversity hotspot with savannah, lakes and renowned birdlife.\n\nBwindi Impenetrable Forest — One of the world’s few places for mountain gorilla trekking.\n\nFort Portal & the Rwenzori region — Crater lakes, highlands and access to mountain hiking.',
            '{"blocks":[{"text":"Uganda’s key destinations are spread across the country and serve different roles:","type":"paragraph"},{"type":"list","items":[{"text":"The capital and primary international city; centre of government, business, nightlife, culture and events.","label":"Kampala"},{"text":"International gateway on Lake Victoria, home to the main airport and a calmer lakeside pace.","label":"Entebbe"},{"text":"Adventure and leisure hub, known globally as the source of the Nile and for white-water rafting.","label":"Jinja"},{"text":"The main city of northern Uganda, culturally distinct, with historical significance and a growing urban scene shaped by resilience, creativity and a slower, more expansive rhythm of life.","label":"Gulu"},{"text":"The country’s most diverse region, bringing together savannah wildlife, primate forests, crater lakes, mountain landscapes, iconic road trips and pastoral Ankole culture within a single journey.","label":"Western Uganda"},{"text":"Flagship wildlife destination combining dramatic landscapes with classic safari experiences.","label":"Murchison Falls National Park"},{"text":"Biodiversity hotspot with savannah, lakes and renowned birdlife.","label":"Queen Elizabeth National Park"},{"text":"One of the world’s few places for mountain gorilla trekking.","label":"Bwindi Impenetrable Forest"},{"text":"Crater lakes, highlands and access to mountain hiking.","label":"Fort Portal & the Rwenzori region"}]}],"display":"narrative","heading":"Major Destinations & Regional Anchors","paragraphs":["Uganda’s key destinations are spread across the country and serve different roles:"]}'::jsonb,
            TRUE
        ),
        (
            'TOURISM_GLANCE',
            E'Uganda is internationally recognised for:\n\nMountain gorilla and chimpanzee trekking\n\nClassic safaris (elephants, lions, buffalo, giraffes)\n\nBirdlife, including the crested crane\n\nAdventure tourism (rafting, hiking, cycling)',
            '{"blocks":[{"text":"Uganda is internationally recognised for:","type":"paragraph"},{"type":"list","items":[{"text":"Mountain gorilla and chimpanzee trekking"},{"text":"Classic safaris (elephants, lions, buffalo, giraffes)"},{"text":"Birdlife, including the crested crane"},{"text":"Adventure tourism (rafting, hiking, cycling)"}]}],"display":"narrative","heading":"Tourism at a Glance","paragraphs":["Uganda is internationally recognised for:"]}'::jsonb,
            TRUE
        ),
        (
            'KAMPALA_CITY_LIFE',
            E'Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.\n\nHospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them.',
            '{"blocks":[{"text":"Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.","type":"paragraph"},{"text":"Hospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them.","type":"paragraph"}],"display":"narrative","heading":"Kampala: City Life Snapshot","paragraphs":["Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.","Hospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them."]}'::jsonb,
            TRUE
        ),
        (
            'SAFETY_REASSURANCE',
            E'Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.\n\nAs with any destination:\n\nBe aware of your surroundings\n\nAvoid displaying valuables unnecessarily\n\nUse reputable transport and accommodation\n\nHospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful.',
            '{"blocks":[{"text":"Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.","type":"paragraph"},{"text":"As with any destination:","type":"paragraph"},{"type":"list","items":[{"text":"Be aware of your surroundings"},{"text":"Avoid displaying valuables unnecessarily"},{"text":"Use reputable transport and accommodation"}]},{"text":"Hospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful.","type":"paragraph"}],"display":"narrative","heading":"Safety & Practical Reassurance","paragraphs":["Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.","As with any destination:","Hospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful."]}'::jsonb,
            TRUE
        ),
        (
            'COST_OF_LIVING',
            E'The local currency is the Ugandan shilling (UGX).\n\nAs a rough guide (rates fluctuate):\n\n1 USD: UGX 3,800–4,000\n\n1 GBP: UGX 4,700–5,000\n\n1 EUR: UGX 4,100–4,400\n\nUganda offers strong value:\n\nEveryday food and transport are inexpensive\n\nMid-range dining and hotels are affordable\n\nHigh-end hospitality offers good value by international standards\n\nCards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal.',
            '{"blocks":[{"text":"The local currency is the Ugandan shilling (UGX).","type":"paragraph"},{"text":"As a rough guide (rates fluctuate):","type":"paragraph"},{"rows":[{"range":"UGX 3,800–4,000","currency":"1 USD"},{"range":"UGX 4,700–5,000","currency":"1 GBP"},{"range":"UGX 4,100–4,400","currency":"1 EUR"}],"type":"rates"},{"text":"Uganda offers strong value:","type":"paragraph"},{"type":"list","items":[{"text":"Everyday food and transport are inexpensive"},{"text":"Mid-range dining and hotels are affordable"},{"text":"High-end hospitality offers good value by international standards"}]},{"text":"Cards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal.","type":"paragraph"}],"display":"narrative","heading":"Cost of Living & Currency","paragraphs":["The local currency is the Ugandan shilling (UGX).","As a rough guide (rates fluctuate):","Uganda offers strong value:","Cards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal."]}'::jsonb,
            TRUE
        ),
        (
            'PUBLIC_HOLIDAYS',
            E'Uganda observes national, religious and cultural holidays, including:\n\nIndependence Day (9 October)\n\nEaster and Christmas\n\nEid holidays\n\nMartyrs’ Day (3 June), a major pilgrimage event\n\nBeyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning.',
            '{"blocks":[{"text":"Uganda observes national, religious and cultural holidays, including:","type":"paragraph"},{"type":"list","items":[{"text":"Independence Day (9 October)"},{"text":"Easter and Christmas"},{"text":"Eid holidays"},{"text":"Martyrs’ Day (3 June), a major pilgrimage event"}]},{"text":"Beyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning.","type":"paragraph"}],"display":"narrative","heading":"Public Holidays & Festivals","paragraphs":["Uganda observes national, religious and cultural holidays, including:","Beyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning."]}'::jsonb,
            TRUE
        ),
        (
            'LOCAL_ETIQUETTE',
            E'What visitors should know\n\nTime is flexible; events often peak later than advertised.\n\nDress matters in social settings — Kampala is style-conscious.\n\nPublic displays of affection are modest.\n\nAlways ask before photographing people or security locations.\n\nTipping is not mandatory, but appreciation for good service is welcomed.',
            '{"blocks":[{"text":"What visitors should know","type":"subheading"},{"type":"list","items":[{"text":"Time is flexible; events often peak later than advertised."},{"text":"Dress matters in social settings — Kampala is style-conscious."},{"text":"Public displays of affection are modest."},{"text":"Always ask before photographing people or security locations."},{"text":"Tipping is not mandatory, but appreciation for good service is welcomed."}]}],"display":"narrative","heading":"Local Etiquette","paragraphs":[]}'::jsonb,
            TRUE
        ),
        (
            'CAPITAL',
            'Kampala',
            '{"name":"Kampala"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY',
            'Ugandan Shilling',
            '{"name":"Ugandan Shilling"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY_CODE',
            'UGX',
            '{"code":"UGX"}'::jsonb,
            TRUE
        ),
        (
            'LANGUAGES',
            'English; Swahili (second official language); Luganda widely spoken',
            '{"official":["English"],"widely_spoken":["Luganda"],"second_official":["Swahili"]}'::jsonb,
            TRUE
        ),
        (
            'TIME_ZONE',
            'East Africa Time (EAT), UTC+3',
            '{"name":"East Africa Time","utc_offset":"+03:00","abbreviation":"EAT"}'::jsonb,
            TRUE
        ),
        (
            'CALLING_CODE',
            '+256',
            '{"calling_code":"+256"}'::jsonb,
            TRUE
        ),
        (
            'DRIVING_SIDE',
            'Left',
            '{"side":"LEFT"}'::jsonb,
            TRUE
        ),
        (
            'ELECTRICITY',
            '240 V, 50 Hz',
            '{"voltage":240,"frequency_hz":50}'::jsonb,
            TRUE
        ),
        (
            'PLUG_TYPE',
            'Type G',
            '{"types":["G"]}'::jsonb,
            TRUE
        ),
        (
            'MAIN_AIRPORT',
            'Entebbe International Airport (EBB)',
            '{"name":"Entebbe International Airport","iata_code":"EBB"}'::jsonb,
            TRUE
        ),
        (
            'EMERGENCY_NUMBERS',
            'General emergency: 112 or 999; Fire & Rescue: 0800 121 222; Traffic: 0800 199 099',
            '{"general":["112","999"],"traffic":"0800199099","fire_rescue":"0800121222"}'::jsonb,
            TRUE
        ),
        (
            'MOBILE_INTERNET',
            '2G, 3G and 4G mobile services are available; 4G coverage is not yet nationwide.',
            '{"4g_nationwide":false,"available_networks":["2G","3G","4G"]}'::jsonb,
            TRUE
        )
)
UPDATE country_guide_essential_values AS v
SET
    value_text = ev.value_text,
    value_data = ev.value_data,
    is_live = ev.is_live,
    updated_at = CURRENT_TIMESTAMP
FROM essential_values ev
JOIN country_guide_essential_types t
    ON t.code = ev.essential_type_code
WHERE v.country_code = 'UG'
  AND v.essential_type_id = t.id;

WITH essential_values (
    essential_type_code,
    value_text,
    value_data,
    is_live
) AS (
    VALUES
        (
            'ABOUT',
            E'Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.\n\nDubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.',
            '{"blocks":[{"text":"Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.","type":"paragraph"},{"text":"Dubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.","type":"paragraph"}],"display":"narrative","heading":"About Uganda","paragraphs":["Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.","Dubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders."]}'::jsonb,
            TRUE
        ),
        (
            'HISTORY',
            E'Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.\n\nBefore modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.\n\nUganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.\n\nToday, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.',
            '{"blocks":[{"text":"Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.","type":"paragraph"},{"text":"Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.","type":"paragraph"},{"text":"Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.","type":"paragraph"},{"text":"Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.","type":"paragraph"}],"display":"narrative","heading":"History of Uganda","paragraphs":["Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.","Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.","Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.","Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence."]}'::jsonb,
            TRUE
        ),
        (
            'CULTURE_TRADITIONS',
            E'Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.\n\nYou’ll notice a few cultural constants quickly:\n\nGreetings matter; people acknowledge each other properly.\n\nHumour is dry, teasing and often self-aware.\n\nMusic is constant — taxis, salons, bars, weddings.\n\nFood is social and shared.\n\nBeing addressed as “my brother” or “my sister” shortly after meeting someone isn’t metaphorical. It’s how social ease is established.',
            '{"blocks":[{"text":"Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.","type":"paragraph"},{"text":"You’ll notice a few cultural constants quickly:","type":"paragraph"},{"type":"list","items":[{"text":"Greetings matter; people acknowledge each other properly."},{"text":"Humour is dry, teasing and often self-aware."},{"text":"Music is constant — taxis, salons, bars, weddings."},{"text":"Food is social and shared."},{"text":"Being addressed as “my brother” or “my sister” shortly after meeting someone isn’t metaphorical. It’s how social ease is established."}]}],"display":"narrative","heading":"Culture & Traditions","paragraphs":["Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.","You’ll notice a few cultural constants quickly:"]}'::jsonb,
            TRUE
        ),
        (
            'FOOD_DRINK_SOCIAL',
            E'Food in Uganda is practical, filling and deeply social.\n\nEveryday staples and rituals include:\n\nRolex — A freshly made chapati rolled with eggs and vegetables, cooked to order — often with nyanya mbisi (raw tomatoes) added — and eaten on the go. A fan favourite with foreign visitors, often one of the first foods people actively seek out again after leaving Uganda.\n\nGrilled meats (nyama choma) — Goat, beef or chicken, usually shared late into the evening.\n\nMatooke — Steamed green bananas, groundnut sauces and smoked fish near lakes and rivers.\n\nUganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.\n\nDrinking here is rarely rushed. Conversations usually outlast the drinks.',
            '{"blocks":[{"text":"Food in Uganda is practical, filling and deeply social.","type":"paragraph"},{"text":"Everyday staples and rituals include:","type":"paragraph"},{"type":"list","items":[{"text":"A freshly made chapati rolled with eggs and vegetables, cooked to order — often with nyanya mbisi (raw tomatoes) added — and eaten on the go. A fan favourite with foreign visitors, often one of the first foods people actively seek out again after leaving Uganda.","label":"Rolex"},{"text":"Goat, beef or chicken, usually shared late into the evening.","label":"Grilled meats (nyama choma)"},{"text":"Steamed green bananas, groundnut sauces and smoked fish near lakes and rivers.","label":"Matooke"}]},{"text":"Uganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.","type":"paragraph"},{"text":"Drinking here is rarely rushed. Conversations usually outlast the drinks.","type":"paragraph"}],"display":"narrative","heading":"Food, Drink & Social Life","paragraphs":["Food in Uganda is practical, filling and deeply social.","Everyday staples and rituals include:","Uganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.","Drinking here is rarely rushed. Conversations usually outlast the drinks."]}'::jsonb,
            TRUE
        ),
        (
            'LANGUAGES_COMMUNICATION',
            E'English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.\n\nLuganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.\n\nVisitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:\n\nWebale — Thank you.\n\nSsebo — A respectful form of address for a man.\n\nNnyabo — A respectful form of address for a woman.\n\nThey signal politeness and are universally appreciated.',
            '{"blocks":[{"text":"English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.","type":"paragraph"},{"text":"Luganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.","type":"paragraph"},{"text":"Visitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:","type":"paragraph"},{"type":"list","items":[{"text":"Thank you.","label":"Webale"},{"text":"A respectful form of address for a man.","label":"Ssebo"},{"text":"A respectful form of address for a woman.","label":"Nnyabo"}]},{"text":"They signal politeness and are universally appreciated.","type":"paragraph"}],"display":"narrative","heading":"Languages & Communication","paragraphs":["English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.","Luganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.","Visitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:","They signal politeness and are universally appreciated."]}'::jsonb,
            TRUE
        ),
        (
            'GEOGRAPHY_CLIMATE',
            E'Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.\n\nKey features include:\n\nLake Victoria — Africa’s largest lake by surface area\n\nThe source of the Nile at Jinja\n\nSavannah landscapes in the north and west\n\nRainforests and mountain ranges in the southwest\n\nClimate\n\nWarm year-round (average 25–28°C)\n\nTwo rainy seasons: March–May and September–November\n\nRain is usually brief rather than constant\n\nThis fertile environment supports year-round agriculture and an abundance of fresh food across the country.',
            '{"blocks":[{"text":"Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.","type":"paragraph"},{"text":"Key features include:","type":"paragraph"},{"type":"list","items":[{"text":"Lake Victoria — Africa’s largest lake by surface area"},{"text":"The source of the Nile at Jinja"},{"text":"Savannah landscapes in the north and west"},{"text":"Rainforests and mountain ranges in the southwest"}]},{"text":"Climate","type":"subheading"},{"type":"list","items":[{"text":"Warm year-round (average 25–28°C)"},{"text":"Two rainy seasons: March–May and September–November"},{"text":"Rain is usually brief rather than constant"}]},{"text":"This fertile environment supports year-round agriculture and an abundance of fresh food across the country.","type":"paragraph"}],"display":"narrative","heading":"Geography & Climate","paragraphs":["Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.","Key features include:","This fertile environment supports year-round agriculture and an abundance of fresh food across the country."]}'::jsonb,
            TRUE
        ),
        (
            'MAJOR_DESTINATIONS',
            E'Uganda’s key destinations are spread across the country and serve different roles:\n\nKampala — The capital and primary international city; centre of government, business, nightlife, culture and events.\n\nEntebbe — International gateway on Lake Victoria, home to the main airport and a calmer lakeside pace.\n\nJinja — Adventure and leisure hub, known globally as the source of the Nile and for white-water rafting.\n\nGulu — The main city of northern Uganda, culturally distinct, with historical significance and a growing urban scene shaped by resilience, creativity and a slower, more expansive rhythm of life.\n\nWestern Uganda — The country’s most diverse region, bringing together savannah wildlife, primate forests, crater lakes, mountain landscapes, iconic road trips and pastoral Ankole culture within a single journey.\n\nMurchison Falls National Park — Flagship wildlife destination combining dramatic landscapes with classic safari experiences.\n\nQueen Elizabeth National Park — Biodiversity hotspot with savannah, lakes and renowned birdlife.\n\nBwindi Impenetrable Forest — One of the world’s few places for mountain gorilla trekking.\n\nFort Portal & the Rwenzori region — Crater lakes, highlands and access to mountain hiking.',
            '{"blocks":[{"text":"Uganda’s key destinations are spread across the country and serve different roles:","type":"paragraph"},{"type":"list","items":[{"text":"The capital and primary international city; centre of government, business, nightlife, culture and events.","label":"Kampala"},{"text":"International gateway on Lake Victoria, home to the main airport and a calmer lakeside pace.","label":"Entebbe"},{"text":"Adventure and leisure hub, known globally as the source of the Nile and for white-water rafting.","label":"Jinja"},{"text":"The main city of northern Uganda, culturally distinct, with historical significance and a growing urban scene shaped by resilience, creativity and a slower, more expansive rhythm of life.","label":"Gulu"},{"text":"The country’s most diverse region, bringing together savannah wildlife, primate forests, crater lakes, mountain landscapes, iconic road trips and pastoral Ankole culture within a single journey.","label":"Western Uganda"},{"text":"Flagship wildlife destination combining dramatic landscapes with classic safari experiences.","label":"Murchison Falls National Park"},{"text":"Biodiversity hotspot with savannah, lakes and renowned birdlife.","label":"Queen Elizabeth National Park"},{"text":"One of the world’s few places for mountain gorilla trekking.","label":"Bwindi Impenetrable Forest"},{"text":"Crater lakes, highlands and access to mountain hiking.","label":"Fort Portal & the Rwenzori region"}]}],"display":"narrative","heading":"Major Destinations & Regional Anchors","paragraphs":["Uganda’s key destinations are spread across the country and serve different roles:"]}'::jsonb,
            TRUE
        ),
        (
            'TOURISM_GLANCE',
            E'Uganda is internationally recognised for:\n\nMountain gorilla and chimpanzee trekking\n\nClassic safaris (elephants, lions, buffalo, giraffes)\n\nBirdlife, including the crested crane\n\nAdventure tourism (rafting, hiking, cycling)',
            '{"blocks":[{"text":"Uganda is internationally recognised for:","type":"paragraph"},{"type":"list","items":[{"text":"Mountain gorilla and chimpanzee trekking"},{"text":"Classic safaris (elephants, lions, buffalo, giraffes)"},{"text":"Birdlife, including the crested crane"},{"text":"Adventure tourism (rafting, hiking, cycling)"}]}],"display":"narrative","heading":"Tourism at a Glance","paragraphs":["Uganda is internationally recognised for:"]}'::jsonb,
            TRUE
        ),
        (
            'KAMPALA_CITY_LIFE',
            E'Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.\n\nHospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them.',
            '{"blocks":[{"text":"Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.","type":"paragraph"},{"text":"Hospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them.","type":"paragraph"}],"display":"narrative","heading":"Kampala: City Life Snapshot","paragraphs":["Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.","Hospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them."]}'::jsonb,
            TRUE
        ),
        (
            'SAFETY_REASSURANCE',
            E'Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.\n\nAs with any destination:\n\nBe aware of your surroundings\n\nAvoid displaying valuables unnecessarily\n\nUse reputable transport and accommodation\n\nHospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful.',
            '{"blocks":[{"text":"Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.","type":"paragraph"},{"text":"As with any destination:","type":"paragraph"},{"type":"list","items":[{"text":"Be aware of your surroundings"},{"text":"Avoid displaying valuables unnecessarily"},{"text":"Use reputable transport and accommodation"}]},{"text":"Hospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful.","type":"paragraph"}],"display":"narrative","heading":"Safety & Practical Reassurance","paragraphs":["Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.","As with any destination:","Hospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful."]}'::jsonb,
            TRUE
        ),
        (
            'COST_OF_LIVING',
            E'The local currency is the Ugandan shilling (UGX).\n\nAs a rough guide (rates fluctuate):\n\n1 USD: UGX 3,800–4,000\n\n1 GBP: UGX 4,700–5,000\n\n1 EUR: UGX 4,100–4,400\n\nUganda offers strong value:\n\nEveryday food and transport are inexpensive\n\nMid-range dining and hotels are affordable\n\nHigh-end hospitality offers good value by international standards\n\nCards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal.',
            '{"blocks":[{"text":"The local currency is the Ugandan shilling (UGX).","type":"paragraph"},{"text":"As a rough guide (rates fluctuate):","type":"paragraph"},{"rows":[{"range":"UGX 3,800–4,000","currency":"1 USD"},{"range":"UGX 4,700–5,000","currency":"1 GBP"},{"range":"UGX 4,100–4,400","currency":"1 EUR"}],"type":"rates"},{"text":"Uganda offers strong value:","type":"paragraph"},{"type":"list","items":[{"text":"Everyday food and transport are inexpensive"},{"text":"Mid-range dining and hotels are affordable"},{"text":"High-end hospitality offers good value by international standards"}]},{"text":"Cards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal.","type":"paragraph"}],"display":"narrative","heading":"Cost of Living & Currency","paragraphs":["The local currency is the Ugandan shilling (UGX).","As a rough guide (rates fluctuate):","Uganda offers strong value:","Cards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal."]}'::jsonb,
            TRUE
        ),
        (
            'PUBLIC_HOLIDAYS',
            E'Uganda observes national, religious and cultural holidays, including:\n\nIndependence Day (9 October)\n\nEaster and Christmas\n\nEid holidays\n\nMartyrs’ Day (3 June), a major pilgrimage event\n\nBeyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning.',
            '{"blocks":[{"text":"Uganda observes national, religious and cultural holidays, including:","type":"paragraph"},{"type":"list","items":[{"text":"Independence Day (9 October)"},{"text":"Easter and Christmas"},{"text":"Eid holidays"},{"text":"Martyrs’ Day (3 June), a major pilgrimage event"}]},{"text":"Beyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning.","type":"paragraph"}],"display":"narrative","heading":"Public Holidays & Festivals","paragraphs":["Uganda observes national, religious and cultural holidays, including:","Beyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning."]}'::jsonb,
            TRUE
        ),
        (
            'LOCAL_ETIQUETTE',
            E'What visitors should know\n\nTime is flexible; events often peak later than advertised.\n\nDress matters in social settings — Kampala is style-conscious.\n\nPublic displays of affection are modest.\n\nAlways ask before photographing people or security locations.\n\nTipping is not mandatory, but appreciation for good service is welcomed.',
            '{"blocks":[{"text":"What visitors should know","type":"subheading"},{"type":"list","items":[{"text":"Time is flexible; events often peak later than advertised."},{"text":"Dress matters in social settings — Kampala is style-conscious."},{"text":"Public displays of affection are modest."},{"text":"Always ask before photographing people or security locations."},{"text":"Tipping is not mandatory, but appreciation for good service is welcomed."}]}],"display":"narrative","heading":"Local Etiquette","paragraphs":[]}'::jsonb,
            TRUE
        ),
        (
            'CAPITAL',
            'Kampala',
            '{"name":"Kampala"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY',
            'Ugandan Shilling',
            '{"name":"Ugandan Shilling"}'::jsonb,
            TRUE
        ),
        (
            'CURRENCY_CODE',
            'UGX',
            '{"code":"UGX"}'::jsonb,
            TRUE
        ),
        (
            'LANGUAGES',
            'English; Swahili (second official language); Luganda widely spoken',
            '{"official":["English"],"widely_spoken":["Luganda"],"second_official":["Swahili"]}'::jsonb,
            TRUE
        ),
        (
            'TIME_ZONE',
            'East Africa Time (EAT), UTC+3',
            '{"name":"East Africa Time","utc_offset":"+03:00","abbreviation":"EAT"}'::jsonb,
            TRUE
        ),
        (
            'CALLING_CODE',
            '+256',
            '{"calling_code":"+256"}'::jsonb,
            TRUE
        ),
        (
            'DRIVING_SIDE',
            'Left',
            '{"side":"LEFT"}'::jsonb,
            TRUE
        ),
        (
            'ELECTRICITY',
            '240 V, 50 Hz',
            '{"voltage":240,"frequency_hz":50}'::jsonb,
            TRUE
        ),
        (
            'PLUG_TYPE',
            'Type G',
            '{"types":["G"]}'::jsonb,
            TRUE
        ),
        (
            'MAIN_AIRPORT',
            'Entebbe International Airport (EBB)',
            '{"name":"Entebbe International Airport","iata_code":"EBB"}'::jsonb,
            TRUE
        ),
        (
            'EMERGENCY_NUMBERS',
            'General emergency: 112 or 999; Fire & Rescue: 0800 121 222; Traffic: 0800 199 099',
            '{"general":["112","999"],"traffic":"0800199099","fire_rescue":"0800121222"}'::jsonb,
            TRUE
        ),
        (
            'MOBILE_INTERNET',
            '2G, 3G and 4G mobile services are available; 4G coverage is not yet nationwide.',
            '{"4g_nationwide":false,"available_networks":["2G","3G","4G"]}'::jsonb,
            TRUE
        )
)
INSERT INTO country_guide_essential_values (
    id,
    country_code,
    essential_type_id,
    value_text,
    value_data,
    is_live
)
SELECT
    gen_random_uuid(),
    'UG',
    t.id,
    ev.value_text,
    ev.value_data,
    ev.is_live
FROM essential_values ev
JOIN country_guide_essential_types t
    ON t.code = ev.essential_type_code
WHERE NOT EXISTS (
    SELECT 1
    FROM country_guide_essential_values existing
    WHERE existing.country_code = 'UG'
      AND existing.essential_type_id = t.id
);

COMMIT;
