-- Kampala Nonstop / Africa Nonstop
-- Uganda Local Knowledge sample content
-- PostgreSQL
--
-- Canonical population is database/seeders/LocalKnowledgeUgandaSeeder.php
-- (46 live items across all six types, with tags and page-context links).
-- This script seeds a representative subset for non-Laravel environments.
--
-- Prerequisite: 6_1 lookup seed and geographic areas must already exist.
-- Idempotent: matches on (country_code, title).

BEGIN;

WITH items (
    type_code,
    title,
    content,
    explanation,
    language_code,
    area_code
) AS (
    VALUES
        ('FUN_FACT', 'Pearl of Africa',
         'Winston Churchill called Uganda the “Pearl of Africa” after travelling through East Africa in 1907 — the nickname still fits the lakes, hills and wildlife packed into a relatively small country.',
         NULL, NULL, NULL),
        ('FUN_FACT', 'Source of the Nile',
         'Jinja, on Lake Victoria, is widely recognised as the source of the Nile — the river then runs north through Uganda before continuing towards the Mediterranean.',
         NULL, NULL, NULL),
        ('FUN_FACT', 'Boda boda origin',
         '“Boda boda” originally described border-to-border motorcycle taxis. In Kampala it now means almost any motorbike-for-hire weaving through traffic.',
         NULL, NULL, 'UG-KAMPALA'),
        ('PHRASE', 'Oli otya?',
         'Oli otya?',
         'The everyday Luganda greeting: “How are you?” A typical reply is “Gyendi” (I’m fine). Using it, even once, usually gets a warmer response than jumping straight to English.',
         'lg', NULL),
        ('PHRASE', 'Webale',
         'Webale',
         'Luganda for “thank you.” Add “nyo” for “thank you very much”: Webale nyo.',
         'lg', NULL),
        ('PHRASE', 'Jambo',
         'Jambo',
         'A Swahili hello used across East Africa. English is more common in Kampala, but Jambo still works as a friendly, widely understood greeting.',
         'sw', NULL),
        ('ETIQUETTE', 'Greet before you ask',
         'Start with a greeting before a request — even a short “hello, how are you?” Matters in shops, taxis and offices. Jumping straight to business can read as abrupt.',
         NULL, NULL, NULL),
        ('ETIQUETTE', 'Right hand for exchange',
         'Give and receive money, food and gifts with your right hand, or with both hands. The left hand is still considered less polite for that kind of exchange.',
         NULL, NULL, NULL),
        ('PRACTICAL_TIP', 'Agree the boda fare first',
         'Agree the fare before you sit on a boda boda. Ride-hailing apps (SafeBoda, Uber, Bolt) remove most of that negotiation in Kampala and keep a record of the trip.',
         NULL, NULL, 'UG-KAMPALA'),
        ('PRACTICAL_TIP', 'Cash still matters',
         'Cards work in many hotels, restaurants and supermarkets in Kampala. Carry some Ugandan shillings anyway — markets, bodas and smaller eateries are still cash-first.',
         NULL, NULL, NULL),
        ('PRACTICAL_TIP', 'Yellow fever certificate',
         'A yellow fever vaccination certificate is commonly requested on entry. Keep it with your passport rather than packed in hold luggage.',
         NULL, NULL, NULL),
        ('CULTURAL_CONTEXT', 'The Rolex is not a watch',
         'A Rolex is Uganda’s iconic street wrap: chapati rolled around eggs, cabbage and tomato. Cheap, filling, and available from roadside stoves from breakfast until late.',
         NULL, NULL, 'UG-KAMPALA'),
        ('CULTURAL_CONTEXT', 'Buganda hospitality',
         'Kampala sits in Buganda, historically a powerful kingdom. Politeness, greeting rituals and respect for elders still shape everyday interaction, even in a busy capital.',
         NULL, NULL, 'UG-CENTRAL'),
        ('INSIDER_TIP', 'Leave Kampala before the Friday rush',
         'If you are heading west to Queen Elizabeth or Bwindi, leave Kampala early on Friday — or better, Thursday. Weekend traffic on the Masaka road can erase a whole afternoon.',
         NULL, NULL, 'UG-CENTRAL'),
        ('INSIDER_TIP', 'Forex beats the hotel desk',
         'Kampala forex bureaux on Kampala Road and around Nakasero usually beat hotel exchange rates. Count your notes at the window; reputable desks are used to visitors doing exactly that.',
         NULL, NULL, 'UG-KAMPALA')
)
INSERT INTO local_knowledge (
    country_code,
    local_knowledge_type_id,
    title,
    content,
    explanation,
    local_language_code,
    geographic_area_id,
    is_live
)
SELECT
    'UG',
    t.id,
    i.title,
    i.content,
    i.explanation,
    i.language_code,
    a.id,
    TRUE
FROM items i
JOIN local_knowledge_types t ON t.code = i.type_code
LEFT JOIN geographic_areas a ON a.code = i.area_code
WHERE NOT EXISTS (
    SELECT 1
    FROM local_knowledge existing
    WHERE existing.country_code = 'UG'
      AND existing.title = i.title
);

COMMIT;
