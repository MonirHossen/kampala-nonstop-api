<?php

namespace Database\Seeders;

use App\Models\CountryGuideEssentialType;
use Illuminate\Database\Seeder;

/**
 * Country Guide essential-type catalogue.
 *
 * Idempotent: matches on `code`.
 */
class CountryGuideReferenceSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            ['code' => 'ABOUT', 'name' => 'About Uganda', 'description' => 'Long-form country introduction covering people, culture and geography.', 'sort_order' => 1],
            ['code' => 'HISTORY', 'name' => 'History of Uganda', 'description' => 'Long-form historical overview shown with the About Uganda tab.', 'sort_order' => 2],
            ['code' => 'CULTURE_TRADITIONS', 'name' => 'Culture & Traditions', 'description' => 'Ethnic diversity, greetings, humour, music and everyday social norms.', 'sort_order' => 3],
            ['code' => 'FOOD_DRINK_SOCIAL', 'name' => 'Food, Drink & Social Life', 'description' => 'Staples, street food, sharing meals and drinking culture.', 'sort_order' => 4],
            ['code' => 'LANGUAGES_COMMUNICATION', 'name' => 'Languages & Communication', 'description' => 'Official and local languages, plus useful polite phrases.', 'sort_order' => 5],
            ['code' => 'GEOGRAPHY_CLIMATE', 'name' => 'Geography & Climate', 'description' => 'Plateau, lakes, savannah, rainforest and seasonal rainfall.', 'sort_order' => 6],
            ['code' => 'MAJOR_DESTINATIONS', 'name' => 'Major Destinations & Regional Anchors', 'description' => 'Key cities, parks and regions that orient a first visit.', 'sort_order' => 7],
            ['code' => 'TOURISM_GLANCE', 'name' => 'Tourism at a Glance', 'description' => 'Wildlife, primates, birdlife and adventure in brief.', 'sort_order' => 8],
            ['code' => 'KAMPALA_CITY_LIFE', 'name' => 'Kampala: City Life Snapshot', 'description' => 'Pace, transport and hospitality in the capital.', 'sort_order' => 9],
            ['code' => 'SAFETY_REASSURANCE', 'name' => 'Safety & Practical Reassurance', 'description' => 'Day-to-day personal safety context for first-time visitors.', 'sort_order' => 11],
            ['code' => 'COST_OF_LIVING', 'name' => 'Cost of Living & Currency', 'description' => 'Shilling, indicative exchange ranges and everyday value.', 'sort_order' => 12],
            ['code' => 'PUBLIC_HOLIDAYS', 'name' => 'Public Holidays & Festivals', 'description' => 'National, religious and cultural dates plus the unofficial calendar.', 'sort_order' => 13],
            ['code' => 'LOCAL_ETIQUETTE', 'name' => 'Local Etiquette', 'description' => 'Timekeeping, dress, photography and tipping for visitors.', 'sort_order' => 14],
            ['code' => 'CAPITAL', 'name' => 'Capital', 'description' => 'The capital city of the country.', 'sort_order' => 20],
            ['code' => 'CURRENCY', 'name' => 'Currency', 'description' => 'The primary currency used in the country.', 'sort_order' => 30],
            ['code' => 'CURRENCY_CODE', 'name' => 'Currency Code', 'description' => 'The ISO currency code for the primary currency.', 'sort_order' => 40],
            ['code' => 'LANGUAGES', 'name' => 'Languages', 'description' => 'Main official and commonly used languages relevant to visitors.', 'sort_order' => 50],
            ['code' => 'TIME_ZONE', 'name' => 'Time Zone', 'description' => "The country's primary time zone.", 'sort_order' => 60],
            ['code' => 'CALLING_CODE', 'name' => 'International Calling Code', 'description' => 'The international telephone dialling code.', 'sort_order' => 70],
            ['code' => 'DRIVING_SIDE', 'name' => 'Driving Side', 'description' => 'The side of the road on which vehicles drive.', 'sort_order' => 80],
            ['code' => 'ELECTRICITY', 'name' => 'Electricity', 'description' => 'Standard electricity voltage and frequency.', 'sort_order' => 90],
            ['code' => 'PLUG_TYPE', 'name' => 'Plug Type', 'description' => 'Electrical plug/socket type commonly used.', 'sort_order' => 100],
            ['code' => 'MAIN_AIRPORT', 'name' => 'Main International Airport', 'description' => 'The principal international airport for the country.', 'sort_order' => 110],
            ['code' => 'EMERGENCY_NUMBERS', 'name' => 'Emergency Numbers', 'description' => 'Key emergency telephone numbers useful to visitors.', 'sort_order' => 120],
            ['code' => 'MOBILE_INTERNET', 'name' => 'Mobile & Internet Basics', 'description' => 'Short practical overview of mobile network and internet access.', 'sort_order' => 130],
        ];

        foreach ($types as $type) {
            CountryGuideEssentialType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'sort_order' => $type['sort_order'],
                    'is_active' => true,
                ],
            );
        }
    }
}
