<?php

namespace Database\Seeders;

use App\Models\ActivityType;
use App\Models\Category;
use App\Models\EventType;
use App\Models\Subcategory;
use Illuminate\Database\Seeder;

/**
 * Canonical listing catalogue reference data.
 *
 * Idempotent: re-running matches on `code` and updates name/is_live in place.
 * Descriptions are intentionally not overwritten so the data dictionary can evolve.
 */
class ListingReferenceSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedCategories();
        $this->seedSubcategories();
        $this->seedActivityTypes();
        $this->seedEventTypes();
    }

    private function seedCategories(): void
    {
        $categories = [
            ['code' => 'ACCOMMODATION', 'name' => 'Accommodation', 'is_live' => true],
            ['code' => 'RESTAURANTS_FOOD', 'name' => 'Restaurants & Food', 'is_live' => true],
            ['code' => 'NIGHTLIFE_ENTERTAINMENT', 'name' => 'Nightlife & Entertainment', 'is_live' => true],
            ['code' => 'WILDLIFE_NATURE', 'name' => 'Wildlife & Nature', 'is_live' => true],
            ['code' => 'CULTURE_HERITAGE', 'name' => 'Culture & Heritage', 'is_live' => true],
            ['code' => 'SHOPPING', 'name' => 'Shopping', 'is_live' => true],
            ['code' => 'WELLNESS_BEAUTY', 'name' => 'Wellness & Beauty', 'is_live' => true],
            ['code' => 'BUSINESS_CORPORATE', 'name' => 'Business & Corporate', 'is_live' => true],
            ['code' => 'TRANSPORT_MOBILITY', 'name' => 'Transport & Mobility', 'is_live' => true],
            ['code' => 'COMMUNITY_IMPACT', 'name' => 'Community & Impact', 'is_live' => true],
            ['code' => 'SPORTS_RECREATION', 'name' => 'Sports & Recreation', 'is_live' => true],
            ['code' => 'MEDICAL_HEALTHCARE', 'name' => 'Medical & Healthcare', 'is_live' => true],
        ];

        foreach ($categories as $category) {
            Category::query()->updateOrCreate(
                ['code' => $category['code']],
                [
                    'name' => $category['name'],
                    'is_live' => $category['is_live'],
                ],
            );
        }
    }

    private function seedSubcategories(): void
    {
        $subcategories = [
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_HOTELS', 'name' => 'Hotels', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_BOUTIQUE_HOTELS', 'name' => 'Boutique Hotels', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_RESORTS', 'name' => 'Resorts', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_SAFARI_LODGES', 'name' => 'Safari Lodges', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_GUESTHOUSES_AND_B_AND_BS', 'name' => 'Guesthouses & B&Bs', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_APARTMENTS_AND_SERVICED_APARTMENTS', 'name' => 'Apartments & Serviced Apartments', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_HOLIDAY_RENTALS', 'name' => 'Holiday Rentals', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_HOSTELS', 'name' => 'Hostels', 'is_live' => true],
            ['category_code' => 'ACCOMMODATION', 'code' => 'ACCOMMODATION_CAMPS_AND_TENTED_LODGES', 'name' => 'Camps & Tented Lodges', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_RESTAURANTS', 'name' => 'Restaurants', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_CAFES_AND_COFFEE_SHOPS', 'name' => 'Cafés & Coffee Shops', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_BAKERIES_AND_PATISSERIES', 'name' => 'Bakeries & Patisseries', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_STREET_FOOD', 'name' => 'Street Food', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_FAST_FOOD_QUICK_SERVICE', 'name' => 'Fast Food / Quick Service', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_FOOD_MARKETS', 'name' => 'Food Markets', 'is_live' => true],
            ['category_code' => 'RESTAURANTS_FOOD', 'code' => 'RESTAURANTS_FOOD_DELIS_AND_SPECIALTY_FOOD', 'name' => 'Delis & Specialty Food', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_NIGHTCLUBS', 'name' => 'Nightclubs', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_BARS_AND_LOUNGES', 'name' => 'Bars & Lounges', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_LIVE_MUSIC_VENUES', 'name' => 'Live Music Venues', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_COMEDY_CLUBS', 'name' => 'Comedy Clubs', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_THEATRES_AND_PERFORMANCE_VENUES', 'name' => 'Theatres & Performance Venues', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_CINEMAS', 'name' => 'Cinemas', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_CASINOS_AND_GAMING_VENUES', 'name' => 'Casinos & Gaming Venues', 'is_live' => true],
            ['category_code' => 'NIGHTLIFE_ENTERTAINMENT', 'code' => 'NIGHTLIFE_ENTERTAINMENT_ENTERTAINMENT_CENTRES', 'name' => 'Entertainment Centres', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_NATIONAL_PARKS_AND_RESERVES', 'name' => 'National Parks & Reserves', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_WILDLIFE_CENTRES_AND_SANCTUARIES', 'name' => 'Wildlife Centres & Sanctuaries', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_ZOOS_AND_ANIMAL_PARKS', 'name' => 'Zoos & Animal Parks', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_FORESTS_AND_WETLANDS', 'name' => 'Forests & Wetlands', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_MOUNTAINS_AND_HILLS', 'name' => 'Mountains & Hills', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_LAKES_RIVERS_AND_WATERFALLS', 'name' => 'Lakes, Rivers & Waterfalls', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_PARKS_AND_GARDENS', 'name' => 'Parks & Gardens', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_FARMS_AND_AGRICULTURAL_ATTRACTIONS', 'name' => 'Farms & Agricultural Attractions', 'is_live' => true],
            ['category_code' => 'WILDLIFE_NATURE', 'code' => 'WILDLIFE_NATURE_SCENIC_AND_NATURAL_ATTRACTIONS', 'name' => 'Scenic & Natural Attractions', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_MUSEUMS', 'name' => 'Museums', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_HISTORICAL_SITES', 'name' => 'Historical Sites', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_ART_GALLERIES', 'name' => 'Art Galleries', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_CULTURAL_CENTRES', 'name' => 'Cultural Centres', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_HERITAGE_SITES', 'name' => 'Heritage Sites', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_TRADITIONAL_AND_CULTURAL_ATTRACTIONS', 'name' => 'Traditional & Cultural Attractions', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_ARTS_AND_CRAFT_CENTRES', 'name' => 'Arts & Craft Centres', 'is_live' => true],
            ['category_code' => 'CULTURE_HERITAGE', 'code' => 'CULTURE_HERITAGE_CULTURAL_WORKSHOPS', 'name' => 'Cultural Workshops', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_MARKETS', 'name' => 'Markets', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_SHOPPING_CENTRES_AND_MALLS', 'name' => 'Shopping Centres & Malls', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_BOUTIQUES', 'name' => 'Boutiques', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_SPECIALTY_STORES', 'name' => 'Specialty Stores', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_CONCEPT_STORES', 'name' => 'Concept Stores', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_DEPARTMENT_STORES', 'name' => 'Department Stores', 'is_live' => true],
            ['category_code' => 'SHOPPING', 'code' => 'SHOPPING_SUPERMARKETS_AND_GROCERY_STORES', 'name' => 'Supermarkets & Grocery Stores', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_SPAS', 'name' => 'Spas', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_SALONS', 'name' => 'Salons', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_BARBERSHOPS', 'name' => 'Barbershops', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_WELLNESS_CENTRES', 'name' => 'Wellness Centres', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_GYMS_AND_FITNESS_CENTRES', 'name' => 'Gyms & Fitness Centres', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_YOGA_AND_MEDITATION_CENTRES', 'name' => 'Yoga & Meditation Centres', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_WELLNESS_RETREATS', 'name' => 'Wellness Retreats', 'is_live' => true],
            ['category_code' => 'WELLNESS_BEAUTY', 'code' => 'WELLNESS_BEAUTY_BEAUTY_AND_AESTHETIC_CLINICS', 'name' => 'Beauty & Aesthetic Clinics', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_CONFERENCE_VENUES', 'name' => 'Conference Venues', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_MEETING_AND_BOARDROOM_SPACES', 'name' => 'Meeting & Boardroom Spaces', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_CO_WORKING_SPACES', 'name' => 'Co-Working Spaces', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_BUSINESS_CENTRES', 'name' => 'Business Centres', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_EVENT_VENUES', 'name' => 'Event Venues', 'is_live' => false],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_PROFESSIONAL_SERVICES', 'name' => 'Professional Services', 'is_live' => true],
            ['category_code' => 'BUSINESS_CORPORATE', 'code' => 'BUSINESS_CORPORATE_PRODUCTION_AND_CREATIVE_SERVICES', 'name' => 'Production & Creative Services', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_AIRPORT_TRANSFERS', 'name' => 'Airport Transfers', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_SELF_DRIVE_CAR_HIRE', 'name' => 'Self-Drive Car Hire', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_CHAUFFEUR_AND_EXECUTIVE_TRANSPORT', 'name' => 'Chauffeur & Executive Transport', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_TAXI_AND_RIDE_HAILING', 'name' => 'Taxi & Ride-Hailing', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_BUS_AND_COACH_SERVICES', 'name' => 'Bus & Coach Services', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_DOMESTIC_AIRLINES', 'name' => 'Domestic Airlines', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_BOAT_AND_FERRY_SERVICES', 'name' => 'Boat & Ferry Services', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_SPECIALIST_VEHICLE_HIRE', 'name' => 'Specialist Vehicle Hire', 'is_live' => true],
            ['category_code' => 'TRANSPORT_MOBILITY', 'code' => 'TRANSPORT_MOBILITY_OTHER_TRANSPORT_SERVICES', 'name' => 'Other Transport Services', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_COMMUNITY_ORGANISATIONS', 'name' => 'Community Organisations', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_CHARITIES_AND_NGOS', 'name' => 'Charities & NGOs', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_SOCIAL_ENTERPRISES', 'name' => 'Social Enterprises', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_COMMUNITY_TOURISM_PROJECTS', 'name' => 'Community Tourism Projects', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_VOLUNTEER_ORGANISATIONS', 'name' => 'Volunteer Organisations', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_CHILDRENS_HOMES_AND_CARE_CENTRES', 'name' => 'Children’s Homes & Care Centres', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_YOUTH_SUPPORT_ORGANISATIONS', 'name' => 'Youth Support Organisations', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_EDUCATION_AND_SKILLS_PROJECTS', 'name' => 'Education & Skills Projects', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_WOMEN_AND_FAMILY_INITIATIVES', 'name' => 'Women & Family Initiatives', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_FAITH_AND_MISSION_ORGANISATIONS', 'name' => 'Faith & Mission Organisations', 'is_live' => true],
            ['category_code' => 'COMMUNITY_IMPACT', 'code' => 'COMMUNITY_IMPACT_CONSERVATION_AND_ENVIRONMENTAL_PROJECTS', 'name' => 'Conservation & Environmental Projects', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_STADIUMS_AND_ARENAS', 'name' => 'Stadiums & Arenas', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_SPORTS_CLUBS', 'name' => 'Sports Clubs', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_GOLF_COURSES_AND_CLUBS', 'name' => 'Golf Courses & Clubs', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_GYMS_AND_TRAINING_FACILITIES', 'name' => 'Gyms & Training Facilities', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_COURTS_AND_SPORTS_CENTRES', 'name' => 'Courts & Sports Centres', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_SWIMMING_AND_AQUATIC_CENTRES', 'name' => 'Swimming & Aquatic Centres', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_ADVENTURE_AND_OUTDOOR_CENTRES', 'name' => 'Adventure & Outdoor Centres', 'is_live' => true],
            ['category_code' => 'SPORTS_RECREATION', 'code' => 'SPORTS_RECREATION_SPORTS_ACADEMIES', 'name' => 'Sports Academies', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_HOSPITALS', 'name' => 'Hospitals', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_CLINICS_AND_MEDICAL_CENTRES', 'name' => 'Clinics & Medical Centres', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_DENTAL_CLINICS', 'name' => 'Dental Clinics', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_OPTICAL_AND_EYE_CARE', 'name' => 'Optical & Eye Care', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_PHARMACIES', 'name' => 'Pharmacies', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_DIAGNOSTIC_AND_LABORATORY_CENTRES', 'name' => 'Diagnostic & Laboratory Centres', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_SPECIALIST_CENTRES', 'name' => 'Specialist Centres', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_REHABILITATION_AND_PHYSIOTHERAPY', 'name' => 'Rehabilitation & Physiotherapy', 'is_live' => true],
            ['category_code' => 'MEDICAL_HEALTHCARE', 'code' => 'MEDICAL_HEALTHCARE_EMERGENCY_AND_URGENT_CARE', 'name' => 'Emergency & Urgent Care', 'is_live' => true],
        ];

        $categoryIds = Category::query()->pluck('id', 'code');

        foreach ($subcategories as $subcategory) {
            $categoryId = $categoryIds->get($subcategory['category_code']);

            if ($categoryId === null) {
                continue;
            }

            Subcategory::query()->updateOrCreate(
                ['code' => $subcategory['code']],
                [
                    'category_id' => $categoryId,
                    'name' => $subcategory['name'],
                    'is_live' => $subcategory['is_live'],
                ],
            );
        }
    }

    private function seedActivityTypes(): void
    {
        $activityTypes = [
            ['code' => 'COOKING_CLASS', 'name' => 'Cooking Class', 'is_live' => true],
            ['code' => 'STREET_FOOD_TASTING', 'name' => 'Street Food Tasting', 'is_live' => true],
            ['code' => 'FOOD_MARKET_VISIT', 'name' => 'Food Market Visit', 'is_live' => true],
            ['code' => 'GUIDED_CULTURAL_TOUR', 'name' => 'Guided Cultural Tour', 'is_live' => true],
            ['code' => 'MUSEUM_TOUR', 'name' => 'Museum Tour', 'is_live' => true],
            ['code' => 'HISTORICAL_TOUR', 'name' => 'Historical Tour', 'is_live' => true],
            ['code' => 'GALLERY_VISIT', 'name' => 'Gallery Visit', 'is_live' => true],
            ['code' => 'CRAFT_WORKSHOP', 'name' => 'Craft Workshop', 'is_live' => true],
            ['code' => 'TEXTILE_WORKSHOP', 'name' => 'Textile Workshop', 'is_live' => true],
            ['code' => 'DANCE_CLASS', 'name' => 'Dance Class', 'is_live' => true],
            ['code' => 'DRUMMING_SESSION', 'name' => 'Drumming Session', 'is_live' => true],
            ['code' => 'STORYTELLING_SESSION', 'name' => 'Storytelling Session', 'is_live' => true],
            ['code' => 'LANGUAGE_SESSION', 'name' => 'Language Session', 'is_live' => true],
            ['code' => 'MEET_LOCAL_ARTISANS', 'name' => 'Meet Local Artisans', 'is_live' => true],
            ['code' => 'VILLAGE_VISIT', 'name' => 'Village Visit', 'is_live' => true],
            ['code' => 'GORILLA_TREKKING', 'name' => 'Gorilla Trekking', 'is_live' => true],
            ['code' => 'CHIMPANZEE_TRACKING', 'name' => 'Chimpanzee Tracking', 'is_live' => true],
            ['code' => 'GAME_VIEWING_SAFARI', 'name' => 'Game Viewing / Safari', 'is_live' => true],
            ['code' => 'BIRDWATCHING', 'name' => 'Birdwatching', 'is_live' => true],
            ['code' => 'NATURE_WALK', 'name' => 'Nature Walk', 'is_live' => true],
            ['code' => 'HIKING', 'name' => 'Hiking', 'is_live' => true],
            ['code' => 'CLIMBING', 'name' => 'Climbing', 'is_live' => true],
            ['code' => 'CAMPING', 'name' => 'Camping', 'is_live' => true],
            ['code' => 'FISHING', 'name' => 'Fishing', 'is_live' => true],
            ['code' => 'BOATING', 'name' => 'Boating', 'is_live' => true],
            ['code' => 'KAYAKING', 'name' => 'Kayaking', 'is_live' => true],
            ['code' => 'NATURE_WILDLIFE_PHOTOGRAPHY', 'name' => 'Nature / Wildlife Photography', 'is_live' => true],
            ['code' => 'MASSAGE', 'name' => 'Massage', 'is_live' => true],
            ['code' => 'FACIAL', 'name' => 'Facial', 'is_live' => true],
            ['code' => 'MANICURE_PEDICURE', 'name' => 'Manicure / Pedicure', 'is_live' => true],
            ['code' => 'HAIR_STYLING_BRAIDING', 'name' => 'Hair Styling / Braiding', 'is_live' => true],
            ['code' => 'BARBERING', 'name' => 'Barbering', 'is_live' => true],
            ['code' => 'YOGA_CLASS', 'name' => 'Yoga Class', 'is_live' => true],
            ['code' => 'PERSONAL_TRAINING', 'name' => 'Personal Training', 'is_live' => true],
            ['code' => 'MEDITATION_SESSION', 'name' => 'Meditation Session', 'is_live' => true],
            ['code' => 'PLAY_TRAIN', 'name' => 'Play / Train', 'is_live' => true],
            ['code' => 'TAKE_A_LESSON', 'name' => 'Take a Lesson', 'is_live' => true],
            ['code' => 'WATCH_LIVE_SPORT', 'name' => 'Watch Live Sport', 'is_live' => true],
            ['code' => 'COMPETE', 'name' => 'Compete', 'is_live' => true],
            ['code' => 'GP_GENERAL_CONSULTATION', 'name' => 'GP / General Consultation', 'is_live' => true],
            ['code' => 'SPECIALIST_CONSULTATION', 'name' => 'Specialist Consultation', 'is_live' => true],
            ['code' => 'DENTAL_CHECK_UP', 'name' => 'Dental Check-up', 'is_live' => true],
            ['code' => 'EYE_TEST', 'name' => 'Eye Test', 'is_live' => true],
            ['code' => 'VACCINATION', 'name' => 'Vaccination', 'is_live' => true],
            ['code' => 'DIAGNOSTIC_TEST', 'name' => 'Diagnostic Test', 'is_live' => true],
            ['code' => 'PHYSIOTHERAPY', 'name' => 'Physiotherapy', 'is_live' => true],
        ];

        foreach ($activityTypes as $activityType) {
            ActivityType::query()->updateOrCreate(
                ['code' => $activityType['code']],
                [
                    'name' => $activityType['name'],
                    'is_live' => $activityType['is_live'],
                ],
            );
        }
    }

    private function seedEventTypes(): void
    {
        $eventTypes = [
            ['code' => 'FESTIVAL', 'name' => 'Festival', 'is_live' => true],
            ['code' => 'CONFERENCE', 'name' => 'Conference', 'is_live' => true],
            ['code' => 'MEETUP', 'name' => 'Meetup', 'is_live' => true],
            ['code' => 'WORKSHOP', 'name' => 'Workshop', 'is_live' => true],
            ['code' => 'TALK_SEMINAR', 'name' => 'Talk / Seminar', 'is_live' => true],
            ['code' => 'NETWORKING', 'name' => 'Networking', 'is_live' => true],
            ['code' => 'EXHIBITION_EXPO', 'name' => 'Exhibition / Expo', 'is_live' => true],
            ['code' => 'PERFORMANCE', 'name' => 'Performance', 'is_live' => true],
            ['code' => 'COMPETITION', 'name' => 'Competition', 'is_live' => true],
            ['code' => 'CEREMONY', 'name' => 'Ceremony', 'is_live' => true],
            ['code' => 'PARTY_SOCIAL', 'name' => 'Party / Social', 'is_live' => true],
            ['code' => 'MARKET_FAIR', 'name' => 'Market / Fair', 'is_live' => true],
            ['code' => 'GATHERING', 'name' => 'Gathering', 'is_live' => true],
        ];

        foreach ($eventTypes as $eventType) {
            EventType::query()->updateOrCreate(
                ['code' => $eventType['code']],
                [
                    'name' => $eventType['name'],
                    'is_live' => $eventType['is_live'],
                ],
            );
        }
    }
}
