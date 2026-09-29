-- ============================================================================
-- Kampala Nonstop / Africa Nonstop
-- Listing Catalogue + Listing Detail - Reference Data Population
--
-- Seeded from the current canonical taxonomy.
-- Safe to rerun: code is the stable conflict key.
--
-- NOTE:
-- * tags, attributes and amenities are intentionally not populated yet.
--   Their canonical controlled values have not been locked.
-- * descriptions are deliberately not overwritten by this initial seed script.
--   This lets the data dictionary evolve independently without changing codes.
-- ============================================================================

BEGIN;

-- categories
INSERT INTO categories (code, name, is_live)
VALUES
    ('ACCOMMODATION', 'Accommodation', TRUE),
    ('RESTAURANTS_FOOD', 'Restaurants & Food', TRUE),
    ('NIGHTLIFE_ENTERTAINMENT', 'Nightlife & Entertainment', TRUE),
    ('WILDLIFE_NATURE', 'Wildlife & Nature', TRUE),
    ('CULTURE_HERITAGE', 'Culture & Heritage', TRUE),
    ('SHOPPING', 'Shopping', TRUE),
    ('WELLNESS_BEAUTY', 'Wellness & Beauty', TRUE),
    ('BUSINESS_CORPORATE', 'Business & Corporate', TRUE),
    ('TRANSPORT_MOBILITY', 'Transport & Mobility', TRUE),
    ('COMMUNITY_IMPACT', 'Community & Impact', TRUE),
    ('SPORTS_RECREATION', 'Sports & Recreation', TRUE),
    ('MEDICAL_HEALTHCARE', 'Medical & Healthcare', TRUE)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

-- subcategories
WITH seed (category_code, code, name, is_live) AS (
    VALUES
        ('ACCOMMODATION', 'ACCOMMODATION_HOTELS', 'Hotels', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_BOUTIQUE_HOTELS', 'Boutique Hotels', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_RESORTS', 'Resorts', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_SAFARI_LODGES', 'Safari Lodges', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_GUESTHOUSES_AND_B_AND_BS', 'Guesthouses & B&Bs', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_APARTMENTS_AND_SERVICED_APARTMENTS', 'Apartments & Serviced Apartments', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_HOLIDAY_RENTALS', 'Holiday Rentals', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_HOSTELS', 'Hostels', TRUE),
        ('ACCOMMODATION', 'ACCOMMODATION_CAMPS_AND_TENTED_LODGES', 'Camps & Tented Lodges', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_RESTAURANTS', 'Restaurants', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_CAFES_AND_COFFEE_SHOPS', 'Cafés & Coffee Shops', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_BAKERIES_AND_PATISSERIES', 'Bakeries & Patisseries', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_STREET_FOOD', 'Street Food', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_FAST_FOOD_QUICK_SERVICE', 'Fast Food / Quick Service', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_FOOD_MARKETS', 'Food Markets', TRUE),
        ('RESTAURANTS_FOOD', 'RESTAURANTS_FOOD_DELIS_AND_SPECIALTY_FOOD', 'Delis & Specialty Food', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_NIGHTCLUBS', 'Nightclubs', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_BARS_AND_LOUNGES', 'Bars & Lounges', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_LIVE_MUSIC_VENUES', 'Live Music Venues', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_COMEDY_CLUBS', 'Comedy Clubs', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_THEATRES_AND_PERFORMANCE_VENUES', 'Theatres & Performance Venues', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_CINEMAS', 'Cinemas', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_CASINOS_AND_GAMING_VENUES', 'Casinos & Gaming Venues', TRUE),
        ('NIGHTLIFE_ENTERTAINMENT', 'NIGHTLIFE_ENTERTAINMENT_ENTERTAINMENT_CENTRES', 'Entertainment Centres', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_NATIONAL_PARKS_AND_RESERVES', 'National Parks & Reserves', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_WILDLIFE_CENTRES_AND_SANCTUARIES', 'Wildlife Centres & Sanctuaries', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_ZOOS_AND_ANIMAL_PARKS', 'Zoos & Animal Parks', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_FORESTS_AND_WETLANDS', 'Forests & Wetlands', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_MOUNTAINS_AND_HILLS', 'Mountains & Hills', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS', 'Lakes, Rivers & Waterfalls', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_PARKS_AND_GARDENS', 'Parks & Gardens', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_FARMS_AND_AGRICULTURAL_ATTRACTIONS', 'Farms & Agricultural Attractions', TRUE),
        ('WILDLIFE_NATURE', 'WILDLIFE_NATURE_SCENIC_AND_NATURAL_ATTRACTIONS', 'Scenic & Natural Attractions', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_MUSEUMS', 'Museums', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_HISTORICAL_SITES', 'Historical Sites', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_ART_GALLERIES', 'Art Galleries', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_CULTURAL_CENTRES', 'Cultural Centres', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_HERITAGE_SITES', 'Heritage Sites', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_TRADITIONAL_AND_CULTURAL_ATTRACTIONS', 'Traditional & Cultural Attractions', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_ARTS_AND_CRAFT_CENTRES', 'Arts & Craft Centres', TRUE),
        ('CULTURE_HERITAGE', 'CULTURE_HERITAGE_CULTURAL_WORKSHOPS', 'Cultural Workshops', TRUE),
        ('SHOPPING', 'SHOPPING_MARKETS', 'Markets', TRUE),
        ('SHOPPING', 'SHOPPING_SHOPPING_CENTRES_AND_MALLS', 'Shopping Centres & Malls', TRUE),
        ('SHOPPING', 'SHOPPING_BOUTIQUES', 'Boutiques', TRUE),
        ('SHOPPING', 'SHOPPING_SPECIALTY_STORES', 'Specialty Stores', TRUE),
        ('SHOPPING', 'SHOPPING_CONCEPT_STORES', 'Concept Stores', TRUE),
        ('SHOPPING', 'SHOPPING_DEPARTMENT_STORES', 'Department Stores', TRUE),
        ('SHOPPING', 'SHOPPING_SUPERMARKETS_AND_GROCERY_STORES', 'Supermarkets & Grocery Stores', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_SPAS', 'Spas', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_SALONS', 'Salons', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_BARBERSHOPS', 'Barbershops', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_WELLNESS_CENTRES', 'Wellness Centres', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_GYMS_AND_FITNESS_CENTRES', 'Gyms & Fitness Centres', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_YOGA_AND_MEDITATION_CENTRES', 'Yoga & Meditation Centres', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_WELLNESS_RETREATS', 'Wellness Retreats', TRUE),
        ('WELLNESS_BEAUTY', 'WELLNESS_BEAUTY_BEAUTY_AND_AESTHETIC_CLINICS', 'Beauty & Aesthetic Clinics', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_CONFERENCE_VENUES', 'Conference Venues', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_MEETING_AND_BOARDROOM_SPACES', 'Meeting & Boardroom Spaces', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_CO_WORKING_SPACES', 'Co-Working Spaces', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_BUSINESS_CENTRES', 'Business Centres', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_EVENT_VENUES', 'Event Venues', FALSE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_PROFESSIONAL_SERVICES', 'Professional Services', TRUE),
        ('BUSINESS_CORPORATE', 'BUSINESS_CORPORATE_PRODUCTION_AND_CREATIVE_SERVICES', 'Production & Creative Services', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_AIRPORT_TRANSFERS', 'Airport Transfers', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_SELF_DRIVE_CAR_HIRE', 'Self-Drive Car Hire', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_CHAUFFEUR_AND_EXECUTIVE_TRANSPORT', 'Chauffeur & Executive Transport', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_TAXI_AND_RIDE_HAILING', 'Taxi & Ride-Hailing', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_BUS_AND_COACH_SERVICES', 'Bus & Coach Services', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_DOMESTIC_AIRLINES', 'Domestic Airlines', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_BOAT_AND_FERRY_SERVICES', 'Boat & Ferry Services', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_SPECIALIST_VEHICLE_HIRE', 'Specialist Vehicle Hire', TRUE),
        ('TRANSPORT_MOBILITY', 'TRANSPORT_MOBILITY_OTHER_TRANSPORT_SERVICES', 'Other Transport Services', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_COMMUNITY_ORGANISATIONS', 'Community Organisations', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_CHARITIES_AND_NGOS', 'Charities & NGOs', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_SOCIAL_ENTERPRISES', 'Social Enterprises', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_COMMUNITY_TOURISM_PROJECTS', 'Community Tourism Projects', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_VOLUNTEER_ORGANISATIONS', 'Volunteer Organisations', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_CHILDRENS_HOMES_AND_CARE_CENTRES', 'Children’s Homes & Care Centres', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_YOUTH_SUPPORT_ORGANISATIONS', 'Youth Support Organisations', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_EDUCATION_AND_SKILLS_PROJECTS', 'Education & Skills Projects', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_WOMEN_AND_FAMILY_INITIATIVES', 'Women & Family Initiatives', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_FAITH_AND_MISSION_ORGANISATIONS', 'Faith & Mission Organisations', TRUE),
        ('COMMUNITY_IMPACT', 'COMMUNITY_IMPACT_CONSERVATION_AND_ENVIRONMENTAL_PROJECTS', 'Conservation & Environmental Projects', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_STADIUMS_AND_ARENAS', 'Stadiums & Arenas', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_SPORTS_CLUBS', 'Sports Clubs', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_GOLF_COURSES_AND_CLUBS', 'Golf Courses & Clubs', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_GYMS_AND_TRAINING_FACILITIES', 'Gyms & Training Facilities', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_COURTS_AND_SPORTS_CENTRES', 'Courts & Sports Centres', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_SWIMMING_AND_AQUATIC_CENTRES', 'Swimming & Aquatic Centres', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_ADVENTURE_AND_OUTDOOR_CENTRES', 'Adventure & Outdoor Centres', TRUE),
        ('SPORTS_RECREATION', 'SPORTS_RECREATION_SPORTS_ACADEMIES', 'Sports Academies', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_HOSPITALS', 'Hospitals', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_CLINICS_AND_MEDICAL_CENTRES', 'Clinics & Medical Centres', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_DENTAL_CLINICS', 'Dental Clinics', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_OPTICAL_AND_EYE_CARE', 'Optical & Eye Care', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_PHARMACIES', 'Pharmacies', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_DIAGNOSTIC_AND_LABORATORY_CENTRES', 'Diagnostic & Laboratory Centres', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_SPECIALIST_CENTRES', 'Specialist Centres', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_REHABILITATION_AND_PHYSIOTHERAPY', 'Rehabilitation & Physiotherapy', TRUE),
        ('MEDICAL_HEALTHCARE', 'MEDICAL_HEALTHCARE_EMERGENCY_AND_URGENT_CARE', 'Emergency & Urgent Care', TRUE)
)
INSERT INTO subcategories (category_id, code, name, is_live)
SELECT c.id, s.code, s.name, s.is_live
FROM seed s
JOIN categories c ON c.code = s.category_code
ON CONFLICT (code) DO UPDATE
SET category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

-- activity_types
INSERT INTO activity_types (code, name, is_live)
VALUES
    ('COOKING_CLASS', 'Cooking Class', TRUE),
    ('STREET_FOOD_TASTING', 'Street Food Tasting', TRUE),
    ('FOOD_MARKET_VISIT', 'Food Market Visit', TRUE),
    ('GUIDED_CULTURAL_TOUR', 'Guided Cultural Tour', TRUE),
    ('MUSEUM_TOUR', 'Museum Tour', TRUE),
    ('HISTORICAL_TOUR', 'Historical Tour', TRUE),
    ('GALLERY_VISIT', 'Gallery Visit', TRUE),
    ('CRAFT_WORKSHOP', 'Craft Workshop', TRUE),
    ('TEXTILE_WORKSHOP', 'Textile Workshop', TRUE),
    ('DANCE_CLASS', 'Dance Class', TRUE),
    ('DRUMMING_SESSION', 'Drumming Session', TRUE),
    ('STORYTELLING_SESSION', 'Storytelling Session', TRUE),
    ('LANGUAGE_SESSION', 'Language Session', TRUE),
    ('MEET_LOCAL_ARTISANS', 'Meet Local Artisans', TRUE),
    ('VILLAGE_VISIT', 'Village Visit', TRUE),
    ('GORILLA_TREKKING', 'Gorilla Trekking', TRUE),
    ('CHIMPANZEE_TRACKING', 'Chimpanzee Tracking', TRUE),
    ('GAME_VIEWING_SAFARI', 'Game Viewing / Safari', TRUE),
    ('BIRDWATCHING', 'Birdwatching', TRUE),
    ('NATURE_WALK', 'Nature Walk', TRUE),
    ('HIKING', 'Hiking', TRUE),
    ('CLIMBING', 'Climbing', TRUE),
    ('CAMPING', 'Camping', TRUE),
    ('FISHING', 'Fishing', TRUE),
    ('BOATING', 'Boating', TRUE),
    ('KAYAKING', 'Kayaking', TRUE),
    ('NATURE_WILDLIFE_PHOTOGRAPHY', 'Nature / Wildlife Photography', TRUE),
    ('MASSAGE', 'Massage', TRUE),
    ('FACIAL', 'Facial', TRUE),
    ('MANICURE_PEDICURE', 'Manicure / Pedicure', TRUE),
    ('HAIR_STYLING_BRAIDING', 'Hair Styling / Braiding', TRUE),
    ('BARBERING', 'Barbering', TRUE),
    ('YOGA_CLASS', 'Yoga Class', TRUE),
    ('PERSONAL_TRAINING', 'Personal Training', TRUE),
    ('MEDITATION_SESSION', 'Meditation Session', TRUE),
    ('PLAY_TRAIN', 'Play / Train', TRUE),
    ('TAKE_A_LESSON', 'Take a Lesson', TRUE),
    ('WATCH_LIVE_SPORT', 'Watch Live Sport', TRUE),
    ('COMPETE', 'Compete', TRUE),
    ('GP_GENERAL_CONSULTATION', 'GP / General Consultation', TRUE),
    ('SPECIALIST_CONSULTATION', 'Specialist Consultation', TRUE),
    ('DENTAL_CHECK_UP', 'Dental Check-up', TRUE),
    ('EYE_TEST', 'Eye Test', TRUE),
    ('VACCINATION', 'Vaccination', TRUE),
    ('DIAGNOSTIC_TEST', 'Diagnostic Test', TRUE),
    ('PHYSIOTHERAPY', 'Physiotherapy', TRUE)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

-- tags
-- No seed values yet: canonical tag list still needs approval.

-- attributes
-- No seed values yet: canonical attribute list still needs approval.

-- amenities
-- No seed values yet: canonical amenity list still needs approval.

-- event_types
-- Renamed from Event Formats because these values describe WHAT the event is.
INSERT INTO event_types (code, name, is_live)
VALUES
    ('FESTIVAL', 'Festival', TRUE),
    ('CONFERENCE', 'Conference', TRUE),
    ('MEETUP', 'Meetup', TRUE),
    ('WORKSHOP', 'Workshop', TRUE),
    ('TALK_SEMINAR', 'Talk / Seminar', TRUE),
    ('NETWORKING', 'Networking', TRUE),
    ('EXHIBITION_EXPO', 'Exhibition / Expo', TRUE),
    ('PERFORMANCE', 'Performance', TRUE),
    ('COMPETITION', 'Competition', TRUE),
    ('CEREMONY', 'Ceremony', TRUE),
    ('PARTY_SOCIAL', 'Party / Social', TRUE),
    ('MARKET_FAIR', 'Market / Fair', TRUE),
    ('GATHERING', 'Gathering', TRUE)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    is_live = EXCLUDED.is_live,
    updated_at = CURRENT_TIMESTAMP;

COMMIT;
