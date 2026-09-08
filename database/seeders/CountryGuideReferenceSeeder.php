<?php

namespace Database\Seeders;

use App\Models\CountryGuideEssentialType;
use App\Models\CountryTravelGuide;
use App\Models\TravelGuideTopic;
use App\Models\TravelInformationType;
use Illuminate\Database\Seeder;

/**
 * Country Guide reference catalogues (types / topics).
 *
 * Idempotent: matches on `code`. Travel guide topics follow the Africa Nonstop
 * Travel Guide Topics catalogue (codes, names, descriptions, sort order).
 */
class CountryGuideReferenceSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedEssentialTypes();
        $this->seedTravelGuideTopics();
        $this->seedTravelInformationTypes();
    }

    private function seedEssentialTypes(): void
    {
        $types = [
            ['code' => 'CAPITAL', 'name' => 'Capital', 'description' => 'National capital city', 'sort_order' => 10],
            ['code' => 'CURRENCY', 'name' => 'Currency', 'description' => 'Currency name and ISO code', 'sort_order' => 20],
            ['code' => 'LANGUAGES', 'name' => 'Languages', 'description' => 'Official and commonly spoken languages', 'sort_order' => 30],
            ['code' => 'TIME_ZONE', 'name' => 'Time zone', 'description' => 'Primary time zone used in the country', 'sort_order' => 40],
            ['code' => 'CALLING_CODE', 'name' => 'International calling code', 'description' => 'Country dialling code', 'sort_order' => 50],
            ['code' => 'DRIVING_SIDE', 'name' => 'Driving side', 'description' => 'Left or right side of the road', 'sort_order' => 60],
            ['code' => 'ELECTRICITY', 'name' => 'Electricity / plug type', 'description' => 'Mains voltage and common plug types', 'sort_order' => 70],
            ['code' => 'MAIN_AIRPORT', 'name' => 'Main international airport', 'description' => 'Primary international gateway', 'sort_order' => 80],
            ['code' => 'EMERGENCY_NUMBERS', 'name' => 'Emergency numbers', 'description' => 'Key emergency contact numbers', 'sort_order' => 90],
            ['code' => 'MOBILE_INTERNET', 'name' => 'Mobile & internet basics', 'description' => 'Short SIM, data and connectivity summary', 'sort_order' => 100],
        ];

        foreach ($types as $type) {
            CountryGuideEssentialType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'sort_order' => $type['sort_order'],
                    'is_active' => true,
                ],
            );

            CountryGuideEssentialType::query()
                ->where('code', $type['code'])
                ->whereNull('description')
                ->update(['description' => $type['description']]);
        }
    }

    private function seedTravelGuideTopics(): void
    {
        // Africa Nonstop Travel Guide Topics catalogue (codes + copy).
        $topics = [
            [
                'code' => 'ENTRY_VISAS',
                'name' => 'Entry & Visas',
                'description' => 'Long-form guidance on entry requirements, visas and related visitor considerations.',
                'sort_order' => 10,
            ],
            [
                'code' => 'ARRIVAL',
                'name' => 'Getting Here & Arrival',
                'description' => 'Long-form guidance on arriving in the country, airports and practical arrival considerations.',
                'sort_order' => 20,
            ],
            [
                'code' => 'GETTING_AROUND',
                'name' => 'Getting Around',
                'description' => 'Long-form guidance on local transport, road travel and moving around the country.',
                'sort_order' => 30,
            ],
            [
                'code' => 'MONEY_PAYMENTS',
                'name' => 'Money & Payments',
                'description' => 'Long-form guidance on cash, cards, mobile money, tipping and payment practices.',
                'sort_order' => 40,
            ],
            [
                'code' => 'EXCHANGE_RATE',
                'name' => 'Exchange Rate',
                'description' => 'Indicative exchange-rate guidance and context for travellers; not intended to be a guaranteed live rate.',
                'sort_order' => 50,
            ],
            [
                'code' => 'HEALTH_SAFETY',
                'name' => 'Health & Safety',
                'description' => 'Long-form practical guidance on health preparation, safety and traveller precautions.',
                'sort_order' => 60,
            ],
            [
                'code' => 'MOBILE_INTERNET',
                'name' => 'Mobile & Internet',
                'description' => 'Long-form guidance on mobile networks, SIM/eSIM options, data, Wi-Fi, roaming and internet access.',
                'sort_order' => 70,
            ],
            [
                'code' => 'WEATHER',
                'name' => 'Weather',
                'description' => 'General weather overview, seasonal patterns and practical context for visitors.',
                'sort_order' => 80,
            ],
            [
                'code' => 'CULTURE_ETIQUETTE',
                'name' => 'Culture & Etiquette',
                'description' => 'Long-form guidance on local customs, etiquette, social behaviour and cultural context.',
                'sort_order' => 90,
            ],
            [
                'code' => 'WHAT_TO_PACK',
                'name' => 'What to Pack',
                'description' => 'Long-form guidance on appropriate clothing, footwear, adapters, medication/personal items, rain protection and destination-specific practicalities.',
                'sort_order' => 100,
            ],
        ];

        $this->migrateLegacyGettingHereTopic();

        foreach ($topics as $topic) {
            TravelGuideTopic::query()->updateOrCreate(
                ['code' => $topic['code']],
                [
                    'name' => $topic['name'],
                    'description' => $topic['description'],
                    'sort_order' => $topic['sort_order'],
                    'is_active' => true,
                ],
            );
        }
    }

    /**
     * Legacy V0 code was GETTING_HERE; catalogue standard is ARRIVAL.
     */
    private function migrateLegacyGettingHereTopic(): void
    {
        $legacy = TravelGuideTopic::query()->where('code', 'GETTING_HERE')->first();
        if ($legacy === null) {
            return;
        }

        $arrival = TravelGuideTopic::query()->where('code', 'ARRIVAL')->first();

        if ($arrival === null) {
            $legacy->update([
                'code' => 'ARRIVAL',
                'name' => 'Getting Here & Arrival',
                'description' => 'Long-form guidance on arriving in the country, airports and practical arrival considerations.',
                'sort_order' => 20,
                'is_active' => true,
            ]);

            return;
        }

        CountryTravelGuide::query()
            ->where('topic_id', $legacy->id)
            ->each(function (CountryTravelGuide $guide) use ($arrival): void {
                $exists = CountryTravelGuide::query()
                    ->where('country_code', $guide->country_code)
                    ->where('topic_id', $arrival->id)
                    ->exists();

                if ($exists) {
                    $guide->delete();

                    return;
                }

                $guide->update(['topic_id' => $arrival->id]);
            });

        $legacy->delete();
    }

    private function seedTravelInformationTypes(): void
    {
        $types = [
            ['code' => 'EXCHANGE_RATE', 'name' => 'Exchange Rate', 'description' => 'Current or indicative FX snapshot', 'sort_order' => 10],
            ['code' => 'WEATHER', 'name' => 'Weather', 'description' => 'Current weather overview', 'sort_order' => 20],
            ['code' => 'LOCAL_TIME', 'name' => 'Local Time', 'description' => 'Current local time context', 'sort_order' => 30],
            ['code' => 'ENTRY_VISA_STATUS', 'name' => 'Entry / Visa Status', 'description' => 'Current entry and visa operational notes', 'sort_order' => 40],
            ['code' => 'TRAVEL_ADVISORY', 'name' => 'Current Travel Advisory', 'description' => 'Current travel advisory summary', 'sort_order' => 50],
        ];

        foreach ($types as $type) {
            TravelInformationType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'sort_order' => $type['sort_order'],
                    'is_active' => true,
                ],
            );

            TravelInformationType::query()
                ->where('code', $type['code'])
                ->whereNull('description')
                ->update(['description' => $type['description']]);
        }
    }
}
