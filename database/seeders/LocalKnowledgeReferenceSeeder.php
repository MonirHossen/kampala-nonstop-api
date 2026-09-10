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
 * Tags/languages include the V0 spreadsheet set from sql/4_2_kampala_nonstop_local_knowledge_v0.sql.
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
            ['code' => 'ach', 'name' => 'Acholi', 'native_name' => 'Acholi'],
            ['code' => 'cgg', 'name' => 'Rukiga', 'native_name' => 'Rukiga'],
            ['code' => 'nyn', 'name' => 'Runyankole', 'native_name' => 'Runyankole'],
            ['code' => 'teo', 'name' => 'Ateso', 'native_name' => 'Ateso'],
            ['code' => 'xog', 'name' => 'Lusoga', 'native_name' => 'Lusoga'],
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

        foreach (array_column($languages, 'code') as $code) {
            DB::table('local_language_countries')->updateOrInsert(
                ['language_code' => $code, 'country_code' => 'UG'],
                [],
            );
        }
    }

    private function seedTags(): void
    {
        $tags = [
            ['code' => 'ACADEMY_AWARDS', 'name' => 'Academy Awards', 'description' => 'Local Knowledge about academy awards.'],
            ['code' => 'ACCOMMODATION', 'name' => 'Accommodation', 'description' => 'Knowledge relevant to where visitors stay.'],
            ['code' => 'ACHOLI', 'name' => 'Acholi', 'description' => 'Local Knowledge about acholi.'],
            ['code' => 'ACHOLILAND', 'name' => 'Acholiland', 'description' => 'Local Knowledge about acholiland.'],
            ['code' => 'ANKOLE', 'name' => 'Ankole', 'description' => 'Local Knowledge about ankole.'],
            ['code' => 'ARRIVAL', 'name' => 'Arrival', 'description' => 'Airport, entry and first-arrival context.'],
            ['code' => 'ATESO', 'name' => 'Ateso', 'description' => 'Local Knowledge about ateso.'],
            ['code' => 'AWARDS', 'name' => 'Awards', 'description' => 'Recognition received through formal awards and honours.'],
            ['code' => 'BARKCLOTH', 'name' => 'Barkcloth', 'description' => 'Local Knowledge about barkcloth.'],
            ['code' => 'BET_AWARDS', 'name' => 'Bet Awards', 'description' => 'Local Knowledge about bet awards.'],
            ['code' => 'BIRDS', 'name' => 'Birds', 'description' => 'Local Knowledge about birds.'],
            ['code' => 'BLACK_PANTHER', 'name' => 'Black Panther', 'description' => 'Local Knowledge about black panther.'],
            ['code' => 'BODA_BODA', 'name' => 'Boda Boda', 'description' => 'Local Knowledge about boda boda.'],
            ['code' => 'BORDERS', 'name' => 'Borders', 'description' => 'Local Knowledge about borders.'],
            ['code' => 'BUGANDA', 'name' => 'Buganda', 'description' => 'Local Knowledge about buganda.'],
            ['code' => 'BUSOGA', 'name' => 'Busoga', 'description' => 'Local Knowledge about busoga.'],
            ['code' => 'BWINDI', 'name' => 'Bwindi', 'description' => 'Local Knowledge about bwindi.'],
            ['code' => 'CASH', 'name' => 'Cash', 'description' => 'Local Knowledge about cash.'],
            ['code' => 'CEREMONIES', 'name' => 'Ceremonies', 'description' => 'Local Knowledge about ceremonies.'],
            ['code' => 'CHESS', 'name' => 'Chess', 'description' => 'Local Knowledge about chess.'],
            ['code' => 'CHIMPANZEES', 'name' => 'Chimpanzees', 'description' => 'Local Knowledge about chimpanzees.'],
            ['code' => 'CLANS', 'name' => 'Clans', 'description' => 'Local Knowledge about clans.'],
            ['code' => 'CLOTHING', 'name' => 'Clothing', 'description' => 'Local Knowledge about clothing.'],
            ['code' => 'COMMUNITY', 'name' => 'Community', 'description' => 'Local Knowledge about community.'],
            ['code' => 'CONNECTIVITY', 'name' => 'Connectivity', 'description' => 'SIM cards, mobile networks, data and internet-related knowledge.'],
            ['code' => 'CRAFTS', 'name' => 'Crafts', 'description' => 'Local Knowledge about crafts.'],
            ['code' => 'CRATER_LAKES', 'name' => 'Crater Lakes', 'description' => 'Local Knowledge about crater lakes.'],
            ['code' => 'CULTURE', 'name' => 'Culture', 'description' => 'Local Knowledge about culture.'],
            ['code' => 'DINING', 'name' => 'Dining', 'description' => 'Local Knowledge about dining.'],
            ['code' => 'DIRECTIONS', 'name' => 'Directions', 'description' => 'Local Knowledge about directions.'],
            ['code' => 'DRINKS', 'name' => 'Drinks', 'description' => 'Local Knowledge about drinks.'],
            ['code' => 'DRIVING', 'name' => 'Driving', 'description' => 'Local Knowledge about driving.'],
            ['code' => 'EASTERN_UGANDA', 'name' => 'Eastern Uganda', 'description' => 'Local Knowledge about eastern uganda.'],
            ['code' => 'EAST_AFRICA', 'name' => 'East Africa', 'description' => 'Local Knowledge about east africa.'],
            ['code' => 'EDDY_KENZO', 'name' => 'Eddy Kenzo', 'description' => 'Local Knowledge about eddy kenzo.'],
            ['code' => 'ELDERS', 'name' => 'Elders', 'description' => 'Local Knowledge about elders.'],
            ['code' => 'ELECTRICITY', 'name' => 'Electricity', 'description' => 'Local Knowledge about electricity.'],
            ['code' => 'EQUATOR', 'name' => 'Equator', 'description' => 'Local Knowledge about equator.'],
            ['code' => 'ETIQUETTE', 'name' => 'Etiquette', 'description' => 'Local Knowledge about etiquette.'],
            ['code' => 'FILM', 'name' => 'Film', 'description' => 'Local Knowledge about film.'],
            ['code' => 'FLORENCE_KASUMBA', 'name' => 'Florence Kasumba', 'description' => 'Local Knowledge about florence kasumba.'],
            ['code' => 'FOOD', 'name' => 'Food', 'description' => 'Local Knowledge about food.'],
            ['code' => 'FOREST_WHITAKER', 'name' => 'Forest Whitaker', 'description' => 'Local Knowledge about forest whitaker.'],
            ['code' => 'FRIED_TOMATOES', 'name' => 'Fried Tomatoes', 'description' => 'Local Knowledge about fried tomatoes.'],
            ['code' => 'GEOGRAPHY', 'name' => 'Geography', 'description' => 'Local Knowledge about geography.'],
            ['code' => 'GEOLOGY', 'name' => 'Geology', 'description' => 'Local Knowledge about geology.'],
            ['code' => 'GETTING_AROUND', 'name' => 'Getting Around', 'description' => 'Practical knowledge about moving around a destination.'],
            ['code' => 'GHETTO_KIDS', 'name' => 'Ghetto Kids', 'description' => 'Local Knowledge about ghetto kids.'],
            ['code' => 'GOMESI', 'name' => 'Gomesi', 'description' => 'Local Knowledge about gomesi.'],
            ['code' => 'GOSSIP_GIRL', 'name' => 'Gossip Girl', 'description' => 'Local Knowledge about gossip girl.'],
            ['code' => 'GREETINGS', 'name' => 'Greetings', 'description' => 'Local Knowledge about greetings.'],
            ['code' => 'GREY_CROWNED_CRANE', 'name' => 'Grey Crowned Crane', 'description' => 'Local Knowledge about grey crowned crane.'],
            ['code' => 'HEALTH', 'name' => 'Health', 'description' => 'Local Knowledge about health.'],
            ['code' => 'HERITAGE', 'name' => 'Heritage', 'description' => 'Local Knowledge about heritage.'],
            ['code' => 'HISTORY', 'name' => 'History', 'description' => 'Local Knowledge about history.'],
            ['code' => 'HUMOUR', 'name' => 'Humour', 'description' => 'Local Knowledge about humour.'],
            ['code' => 'ISLANDS', 'name' => 'Islands', 'description' => 'Local Knowledge about islands.'],
            ['code' => 'JUICE', 'name' => 'Juice', 'description' => 'Local Knowledge about juice.'],
            ['code' => 'KAMPALA', 'name' => 'Kampala', 'description' => 'Local Knowledge about kampala.'],
            ['code' => 'KAMPALA_NONSTOP', 'name' => 'Kampala Nonstop', 'description' => 'Local Knowledge about kampala nonstop.'],
            ['code' => 'KANZU', 'name' => 'Kanzu', 'description' => 'Local Knowledge about kanzu.'],
            ['code' => 'KATWE', 'name' => 'Katwe', 'description' => 'Local Knowledge about katwe.'],
            ['code' => 'KAZINGA_CHANNEL', 'name' => 'Kazinga Channel', 'description' => 'Local Knowledge about kazinga channel.'],
            ['code' => 'KIGEZI', 'name' => 'Kigezi', 'description' => 'Local Knowledge about kigezi.'],
            ['code' => 'KWANJULA', 'name' => 'Kwanjula', 'description' => 'Local Knowledge about kwanjula.'],
            ['code' => 'LAKES', 'name' => 'Lakes', 'description' => 'Local Knowledge about lakes.'],
            ['code' => 'LAKE_ALBERT', 'name' => 'Lake Albert', 'description' => 'Local Knowledge about lake albert.'],
            ['code' => 'LAKE_BUNYONYI', 'name' => 'Lake Bunyonyi', 'description' => 'Local Knowledge about lake bunyonyi.'],
            ['code' => 'LAKE_MUTANDA', 'name' => 'Lake Mutanda', 'description' => 'Local Knowledge about lake mutanda.'],
            ['code' => 'LAKE_VICTORIA', 'name' => 'Lake Victoria', 'description' => 'Local Knowledge about lake victoria.'],
            ['code' => 'LANDMARKS', 'name' => 'Landmarks', 'description' => 'Local Knowledge about landmarks.'],
            ['code' => 'LANGUAGE', 'name' => 'Language', 'description' => 'Local Knowledge about language.'],
            ['code' => 'LIONS', 'name' => 'Lions', 'description' => 'Local Knowledge about lions.'],
            ['code' => 'LOCAL_LIFE', 'name' => 'Local Life', 'description' => 'Local Knowledge about local life.'],
            ['code' => 'LUGANDA', 'name' => 'Luganda', 'description' => 'Local Knowledge about luganda.'],
            ['code' => 'LUSOGA', 'name' => 'Lusoga', 'description' => 'Local Knowledge about lusoga.'],
            ['code' => 'MADINA_NALWANGA', 'name' => 'Madina Nalwanga', 'description' => 'Local Knowledge about madina nalwanga.'],
            ['code' => 'MARVEL', 'name' => 'Marvel', 'description' => 'Local Knowledge about marvel.'],
            ['code' => 'MATOOKE', 'name' => 'Matooke', 'description' => 'Local Knowledge about matooke.'],
            ['code' => 'MGAHINGA', 'name' => 'Mgahinga', 'description' => 'Local Knowledge about mgahinga.'],
            ['code' => 'MOBILE_MONEY', 'name' => 'Mobile Money', 'description' => 'Local Knowledge about mobile money.'],
            ['code' => 'MONEY', 'name' => 'Money', 'description' => 'Local Knowledge about money.'],
            ['code' => 'MOUNTAINS', 'name' => 'Mountains', 'description' => 'Local Knowledge about mountains.'],
            ['code' => 'MOUNTAIN_GORILLAS', 'name' => 'Mountain Gorillas', 'description' => 'Local Knowledge about mountain gorillas.'],
            ['code' => 'MURCHISON_FALLS', 'name' => 'Murchison Falls', 'description' => 'Local Knowledge about murchison falls.'],
            ['code' => 'MUSIC', 'name' => 'Music', 'description' => 'Local Knowledge about music.'],
            ['code' => 'NATIONAL_IDENTITY', 'name' => 'National Identity', 'description' => 'Local Knowledge about national identity.'],
            ['code' => 'NATIONAL_PARKS', 'name' => 'National Parks', 'description' => 'Protected national parks, their landscapes, wildlife and visitor experiences.'],
            ['code' => 'NATIONAL_SYMBOLS', 'name' => 'National Symbols', 'description' => 'Local Knowledge about national symbols.'],
            ['code' => 'NATURE', 'name' => 'Nature', 'description' => 'Local Knowledge about nature.'],
            ['code' => 'NIGHTLIFE', 'name' => 'Nightlife', 'description' => 'Local Knowledge about nightlife.'],
            ['code' => 'NORTHERN_UGANDA', 'name' => 'Northern Uganda', 'description' => 'Local Knowledge about northern uganda.'],
            ['code' => 'NOTABLE_PEOPLE', 'name' => 'Notable People', 'description' => 'People recognised for significant public, cultural, professional or historical achievements.'],
            ['code' => 'NYANYA_MBISI', 'name' => 'Nyanya Mbisi', 'description' => 'Local Knowledge about nyanya mbisi.'],
            ['code' => 'OLIVIER_AWARDS', 'name' => 'Olivier Awards', 'description' => 'Local Knowledge about olivier awards.'],
            ['code' => 'PACKING', 'name' => 'Packing', 'description' => 'Local Knowledge about packing.'],
            ['code' => 'PAYMENTS', 'name' => 'Payments', 'description' => 'Cards, mobile money and payment practices.'],
            ['code' => 'PEOPLE', 'name' => 'People', 'description' => 'Local Knowledge concerning named individuals or groups of people.'],
            ['code' => 'PERMITS', 'name' => 'Permits', 'description' => 'Local Knowledge about permits.'],
            ['code' => 'PHIONA_MUTESI', 'name' => 'Phiona Mutesi', 'description' => 'Local Knowledge about phiona mutesi.'],
            ['code' => 'PHOTOGRAPHY', 'name' => 'Photography', 'description' => 'Local Knowledge about photography.'],
            ['code' => 'PLACES_OF_WORSHIP', 'name' => 'Places Of Worship', 'description' => 'Local Knowledge about places of worship.'],
            ['code' => 'PLACE_NAMES', 'name' => 'Place Names', 'description' => 'Local Knowledge about place names.'],
            ['code' => 'PLUGS', 'name' => 'Plugs', 'description' => 'Local Knowledge about plugs.'],
            ['code' => 'PRACTICAL_INFORMATION', 'name' => 'Practical Information', 'description' => 'Local Knowledge about practical information.'],
            ['code' => 'QUEEN_ELIZABETH_NATIONAL_PARK', 'name' => 'Queen Elizabeth National Park', 'description' => 'Local Knowledge about queen elizabeth national park.'],
            ['code' => 'QUEEN_OF_KATWE', 'name' => 'Queen Of Katwe', 'description' => 'Local Knowledge about queen of katwe.'],
            ['code' => 'RAIN', 'name' => 'Rain', 'description' => 'Local Knowledge about rain.'],
            ['code' => 'ROAD_SAFETY', 'name' => 'Road Safety', 'description' => 'Local Knowledge about road safety.'],
            ['code' => 'ROLEX', 'name' => 'Rolex', 'description' => 'Local Knowledge about rolex.'],
            ['code' => 'RUKIGA', 'name' => 'Rukiga', 'description' => 'Local Knowledge about rukiga.'],
            ['code' => 'RUNYANKOLE', 'name' => 'Runyankole', 'description' => 'Local Knowledge about runyankole.'],
            ['code' => 'RWENZORI_MOUNTAINS', 'name' => 'Rwenzori Mountains', 'description' => 'Local Knowledge about rwenzori mountains.'],
            ['code' => 'SAFARI', 'name' => 'Safari', 'description' => 'Wildlife-viewing and nature experiences associated with safari travel.'],
            ['code' => 'SAFETY', 'name' => 'Safety', 'description' => 'Local Knowledge about safety.'],
            ['code' => 'SHEILA_ATIM', 'name' => 'Sheila Atim', 'description' => 'Local Knowledge about sheila atim.'],
            ['code' => 'SHOEBILL', 'name' => 'Shoebill', 'description' => 'Local Knowledge about shoebill.'],
            ['code' => 'SHOPPING', 'name' => 'Shopping', 'description' => 'Shopping practices, markets and retail-related knowledge.'],
            ['code' => 'SITYA_LOSS', 'name' => 'Sitya Loss', 'description' => 'Local Knowledge about sitya loss.'],
            ['code' => 'SOCIAL_CUSTOMS', 'name' => 'Social Customs', 'description' => 'Local Knowledge about social customs.'],
            ['code' => 'SPORT', 'name' => 'Sport', 'description' => 'Local Knowledge concerning sport, athletes and sporting achievement.'],
            ['code' => 'SSESE_ISLANDS', 'name' => 'Ssese Islands', 'description' => 'Local Knowledge about ssese islands.'],
            ['code' => 'STREET_FOOD', 'name' => 'Street Food', 'description' => 'Local Knowledge about street food.'],
            ['code' => 'TELEVISION', 'name' => 'Television', 'description' => 'Local Knowledge about television.'],
            ['code' => 'TESO', 'name' => 'Teso', 'description' => 'Local Knowledge about teso.'],
            ['code' => 'THEATRE', 'name' => 'Theatre', 'description' => 'Local Knowledge about theatre.'],
            ['code' => 'THE_AFRICAN_QUEEN', 'name' => 'The African Queen', 'description' => 'Local Knowledge about the african queen.'],
            ['code' => 'THE_LAST_KING_OF_SCOTLAND', 'name' => 'The Last King Of Scotland', 'description' => 'Local Knowledge about the last king of scotland.'],
            ['code' => 'TRAFFIC', 'name' => 'Traffic', 'description' => 'Local Knowledge about traffic.'],
            ['code' => 'TRANSPORT', 'name' => 'Transport', 'description' => 'Local Knowledge about transport.'],
            ['code' => 'UGANDAN_CUISINE', 'name' => 'Ugandan Cuisine', 'description' => 'Local Knowledge about ugandan cuisine.'],
            ['code' => 'UGANDA_KOB', 'name' => 'Uganda Kob', 'description' => 'Local Knowledge about uganda kob.'],
            ['code' => 'VIRUNGA_MOUNTAINS', 'name' => 'Virunga Mountains', 'description' => 'Local Knowledge about virunga mountains.'],
            ['code' => 'VISITORS', 'name' => 'Visitors', 'description' => 'Local Knowledge about visitors.'],
            ['code' => 'VOLCANOES', 'name' => 'Volcanoes', 'description' => 'Local Knowledge about volcanoes.'],
            ['code' => 'WAKALIWOOD', 'name' => 'Wakaliwood', 'description' => 'Local Knowledge about wakaliwood.'],
            ['code' => 'WATER', 'name' => 'Water', 'description' => 'Local Knowledge about water.'],
            ['code' => 'WEATHER', 'name' => 'Weather', 'description' => 'Local Knowledge about weather.'],
            ['code' => 'WETLANDS', 'name' => 'Wetlands', 'description' => 'Local Knowledge about wetlands.'],
            ['code' => 'WHITNEY_PEAK', 'name' => 'Whitney Peak', 'description' => 'Local Knowledge about whitney peak.'],
            ['code' => 'WHO_KILLED_CAPTAIN_ALEX', 'name' => 'Who Killed Captain Alex', 'description' => 'Local Knowledge about who killed captain alex.'],
            ['code' => 'WILDLIFE', 'name' => 'Wildlife', 'description' => 'Local Knowledge about wildlife.'],
            ['code' => 'YOUNG_CARDAMOM_AND_HAB', 'name' => 'Young Cardamom And Hab', 'description' => 'Local Knowledge about young cardamom and hab.'],
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
