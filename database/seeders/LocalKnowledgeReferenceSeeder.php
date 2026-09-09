<?php

namespace Database\Seeders;

use App\Models\LocalKnowledgeTag;
use App\Models\LocalKnowledgeType;
use App\Models\LocalLanguage;
use App\Models\PageContext;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Local Knowledge lookup catalogues: types, languages, tags, page contexts.
 *
 * Idempotent: matches on `code`.
 */
class LocalKnowledgeReferenceSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedTypes();
        $this->seedLanguages();
        $this->seedTags();
        $this->seedPageContexts();
    }

    private function seedTypes(): void
    {
        $types = [
            ['code' => 'FUN_FACT', 'name' => 'Fun Fact', 'description' => 'Interesting trivia or surprising information.'],
            ['code' => 'PHRASE', 'name' => 'Local Phrase', 'description' => 'A local-language word or phrase with its translation and contextual explanation.'],
            ['code' => 'ETIQUETTE', 'name' => 'Etiquette', 'description' => 'Social conventions, manners and cultural expectations useful to visitors.'],
            ['code' => 'PRACTICAL_TIP', 'name' => 'Practical Tip', 'description' => 'Useful visitor knowledge such as money, transport, connectivity or other practical guidance.'],
            ['code' => 'CULTURAL_CONTEXT', 'name' => 'Cultural Context', 'description' => 'Explains customs, traditions or why something is done.'],
            ['code' => 'INSIDER_TIP', 'name' => 'Insider Tip', 'description' => 'Locally informed advice that is not obvious from ordinary travel information.'],
        ];

        foreach ($types as $type) {
            LocalKnowledgeType::query()->updateOrCreate(
                ['code' => $type['code']],
                [
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'is_active' => true,
                ],
            );
        }
    }

    private function seedLanguages(): void
    {
        $languages = [
            ['code' => 'en', 'name' => 'English', 'native_name' => 'English'],
            ['code' => 'lg', 'name' => 'Luganda', 'native_name' => 'Luganda'],
            ['code' => 'sw', 'name' => 'Swahili', 'native_name' => 'Kiswahili'],
        ];

        foreach ($languages as $language) {
            LocalLanguage::query()->updateOrCreate(
                ['code' => $language['code']],
                [
                    'name' => $language['name'],
                    'native_name' => $language['native_name'],
                    'is_active' => true,
                ],
            );
        }

        foreach (['en', 'lg', 'sw'] as $code) {
            DB::table('local_language_countries')->updateOrInsert(
                ['language_code' => $code, 'country_code' => 'UG'],
                [],
            );
        }
    }

    private function seedTags(): void
    {
        $tags = [
            ['code' => 'TRANSPORT', 'name' => 'Transport', 'description' => 'Transport, mobility and movement-related knowledge.'],
            ['code' => 'GETTING_AROUND', 'name' => 'Getting Around', 'description' => 'Practical knowledge about moving around a destination.'],
            ['code' => 'ARRIVAL', 'name' => 'Arrival', 'description' => 'Airport, entry and first-arrival context.'],
            ['code' => 'MONEY', 'name' => 'Money', 'description' => 'Currency, cash and general money-related knowledge.'],
            ['code' => 'PAYMENTS', 'name' => 'Payments', 'description' => 'Cards, mobile money and payment practices.'],
            ['code' => 'MOBILE_MONEY', 'name' => 'Mobile Money', 'description' => 'Knowledge specifically related to mobile-money use.'],
            ['code' => 'CULTURE', 'name' => 'Culture', 'description' => 'Cultural practices, norms and context.'],
            ['code' => 'ETIQUETTE', 'name' => 'Etiquette', 'description' => 'Social etiquette and visitor behaviour.'],
            ['code' => 'LANGUAGE', 'name' => 'Language', 'description' => 'Languages, phrases and communication-related knowledge.'],
            ['code' => 'FOOD', 'name' => 'Food', 'description' => 'Food, eating and local culinary culture.'],
            ['code' => 'NIGHTLIFE', 'name' => 'Nightlife', 'description' => 'Nightlife, entertainment and late-evening culture.'],
            ['code' => 'HISTORY', 'name' => 'History', 'description' => 'Historical context and facts.'],
            ['code' => 'SAFETY', 'name' => 'Safety', 'description' => 'Practical personal-safety context.'],
            ['code' => 'HEALTH', 'name' => 'Health', 'description' => 'Health-related local context distinct from formal medical advice.'],
            ['code' => 'CONNECTIVITY', 'name' => 'Connectivity', 'description' => 'SIM cards, mobile networks, data and internet-related knowledge.'],
            ['code' => 'WEATHER', 'name' => 'Weather & Climate', 'description' => 'Climate, seasons and weather-related local context.'],
            ['code' => 'ACCOMMODATION', 'name' => 'Accommodation', 'description' => 'Knowledge relevant to where visitors stay.'],
            ['code' => 'SHOPPING', 'name' => 'Shopping', 'description' => 'Shopping practices, markets and retail-related knowledge.'],
        ];

        foreach ($tags as $tag) {
            LocalKnowledgeTag::query()->updateOrCreate(
                ['code' => $tag['code']],
                [
                    'name' => $tag['name'],
                    'description' => $tag['description'],
                    'is_active' => true,
                ],
            );
        }
    }

    private function seedPageContexts(): void
    {
        $contexts = [
            ['code' => 'HOME', 'name' => 'Home', 'description' => 'Homepage Local Knowledge tooltip context.'],
            ['code' => 'GUIDE', 'name' => 'Guide', 'description' => 'General Guide pages and Guide landing experience.'],
            ['code' => 'GUIDE_OVERVIEW', 'name' => 'Guide Overview', 'description' => 'Country or destination overview content within Guide.'],
            ['code' => 'GUIDE_ESSENTIALS', 'name' => 'Guide Essentials', 'description' => 'Structured country essentials and quick-reference Guide content.'],
            ['code' => 'GUIDE_TRAVEL_GUIDE', 'name' => 'Guide Travel Guide', 'description' => 'Long-form Travel Guide topics such as arrival, transport, money, health, connectivity, weather and etiquette.'],
            ['code' => 'GUIDE_TRAVEL_INFORMATION', 'name' => 'Guide Travel Information', 'description' => 'Operational Travel Information such as visas, visa-free entry and visa costs.'],
            ['code' => 'GUIDE_REGION', 'name' => 'Guide Region', 'description' => 'Regional and destination-level Guide pages.'],
            ['code' => 'DISCOVER', 'name' => 'Discover', 'description' => 'Discovery catalogue and related browsing surfaces.'],
            ['code' => 'LISTING_DETAIL', 'name' => 'Listing Detail', 'description' => 'Individual listing detail pages.'],
            ['code' => 'TRIP_PLANNER', 'name' => 'Trip Planner', 'description' => 'Trip planning and orchestration surfaces.'],
        ];

        foreach ($contexts as $context) {
            PageContext::query()->updateOrCreate(
                ['code' => $context['code']],
                [
                    'name' => $context['name'],
                    'description' => $context['description'],
                    'is_active' => true,
                ],
            );
        }
    }
}
