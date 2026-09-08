<?php

namespace Database\Seeders;

use App\Models\CountryGuideEssentialType;
use App\Models\CountryGuideEssentialValue;
use App\Models\CountryRegionGuide;
use App\Models\CountryTravelGuide;
use App\Models\CountryTravelInformation;
use App\Models\GeographicArea;
use App\Models\TravelGuideTopic;
use App\Models\TravelInformationType;
use Illuminate\Database\Seeder;

/**
 * Uganda (UG) Country Guide sample content for V0 composition.
 *
 * Idempotent: matches on country_code + type/topic/area.
 */
class CountryGuideUgandaSeeder extends Seeder
{
    private const COUNTRY = 'UG';

    public function run(): void
    {
        $this->seedEssentials();
        $this->seedTravelGuides();
        $this->seedTravelInformation();
        $this->seedRegionGuides();
    }

    private function seedEssentials(): void
    {
        $values = [
            'CAPITAL' => [
                'value_text' => 'Kampala',
                'value_data' => null,
            ],
            'CURRENCY' => [
                'value_text' => 'Ugandan Shilling (UGX)',
                'value_data' => ['currency_code' => 'UGX', 'currency_name' => 'Ugandan Shilling'],
            ],
            'LANGUAGES' => [
                'value_text' => 'English (official), Luganda and other local languages',
                'value_data' => ['languages' => ['en', 'lg']],
            ],
            'TIME_ZONE' => [
                'value_text' => 'East Africa Time (EAT, UTC+3)',
                'value_data' => ['timezone' => 'Africa/Kampala', 'utc_offset' => '+03:00'],
            ],
            'CALLING_CODE' => [
                'value_text' => '+256',
                'value_data' => ['calling_code' => '+256'],
            ],
            'DRIVING_SIDE' => [
                'value_text' => 'Left',
                'value_data' => ['driving_side' => 'left'],
            ],
            'ELECTRICITY' => [
                'value_text' => '240V, Type G plugs (UK-style three-pin)',
                'value_data' => ['voltage' => 240, 'plug_types' => ['G']],
            ],
            'MAIN_AIRPORT' => [
                'value_text' => 'Entebbe International Airport (EBB)',
                'value_data' => ['iata' => 'EBB', 'name' => 'Entebbe International Airport'],
            ],
            'EMERGENCY_NUMBERS' => [
                'value_text' => 'Police 999 / 112; Ambulance 911',
                'value_data' => ['police' => ['999', '112'], 'ambulance' => ['911']],
            ],
            'MOBILE_INTERNET' => [
                'value_text' => 'Local SIMs from MTN, Airtel and others are widely available; mobile data covers major towns.',
                'value_data' => null,
            ],
        ];

        foreach ($values as $code => $payload) {
            $typeId = CountryGuideEssentialType::query()->where('code', $code)->value('id');
            if ($typeId === null) {
                continue;
            }

            CountryGuideEssentialValue::query()->updateOrCreate(
                [
                    'country_code' => self::COUNTRY,
                    'essential_type_id' => $typeId,
                ],
                [
                    'value_text' => $payload['value_text'],
                    'value_data' => $payload['value_data'],
                    'is_live' => true,
                ],
            );
        }
    }

    private function seedTravelGuides(): void
    {
        $guides = [
            'ENTRY_VISAS' => 'Most visitors need a visa or electronic authorisation before travel. Check current Uganda Immigration requirements for your nationality, including passport validity and yellow fever certificate rules where they apply.',
            'ARRIVAL' => 'Most international travellers arrive at Entebbe International Airport (EBB), about 40 km from Kampala. Immigration, baggage reclaim and ground transport options are available airside and landside; allow time for road traffic into the city.',
            'GETTING_AROUND' => 'Within Kampala, boda bodas (motorcycle taxis), ride-hailing apps, taxis and matatus are common. For longer journeys, coaches and domestic flights serve major destinations. Plan extra time for traffic in the capital.',
            'MONEY_PAYMENTS' => 'Ugandan Shillings (UGX) are the everyday currency. Cards are accepted in many hotels, restaurants and larger shops in Kampala; cash remains useful for markets, bodas and smaller vendors. Mobile money is widely used locally.',
            'EXCHANGE_RATE' => 'Use published mid-market rates only for rough trip budgeting. Rates at banks, forex bureaux and hotels can differ, and this Guide figure is not a live FX quote or a promise of the rate you will receive.',
            'HEALTH_SAFETY' => 'Speak with a travel clinician before departure about vaccinations and malaria prevention. Drink bottled or treated water, use reputable transport at night, and follow current local advice for your itinerary.',
            'MOBILE_INTERNET' => 'Buy a local prepaid SIM or eSIM on arrival for affordable data. Coverage is strong in Kampala and major towns; expect thinner coverage in remote parks. Hotel and café Wi-Fi quality varies.',
            'WEATHER' => 'Uganda has a tropical climate moderated by altitude. Kampala is often warm with two wetter seasons roughly around March–May and September–November. Pack light layers and rain protection year-round.',
            'CULTURE_ETIQUETTE' => 'Greetings matter; a friendly hello goes a long way. Dress modestly for religious sites and rural visits. Ask before photographing people, and be patient with flexible timekeeping in social settings.',
            'WHAT_TO_PACK' => 'Pack light, breathable clothing for warm days, a light jacket for cooler evenings at altitude, sturdy walking shoes, a Type G plug adapter, rain protection, sun protection, and any personal medication with copies of prescriptions. For safari or park days, muted colours and closed shoes are practical.',
        ];

        foreach ($guides as $code => $content) {
            $topicId = TravelGuideTopic::query()->where('code', $code)->value('id');
            if ($topicId === null) {
                continue;
            }

            CountryTravelGuide::query()->updateOrCreate(
                [
                    'country_code' => self::COUNTRY,
                    'topic_id' => $topicId,
                ],
                [
                    'content' => $content,
                    'image_link' => null,
                    'is_live' => true,
                ],
            );
        }
    }

    private function seedTravelInformation(): void
    {
        $items = [
            'EXCHANGE_RATE' => [
                'value_text' => 'Indicative planning rate: roughly 3,700 UGX per 1 USD (manual snapshot; not a live quote).',
                'value_data' => ['base' => 'USD', 'quote' => 'UGX', 'rate' => 3700, 'source' => 'manual'],
            ],
            'WEATHER' => [
                'value_text' => 'Kampala is typically warm with daytime highs around 25–28°C; expect occasional showers in wetter months.',
                'value_data' => ['location' => 'Kampala', 'summary' => 'warm_with_showers'],
            ],
            'LOCAL_TIME' => [
                'value_text' => 'Uganda uses East Africa Time (UTC+3) year-round; there is no daylight saving change.',
                'value_data' => ['timezone' => 'Africa/Kampala'],
            ],
            'ENTRY_VISA_STATUS' => [
                'value_text' => 'Visa and e-visa rules vary by nationality. Confirm requirements with Uganda Immigration before you travel.',
                'value_data' => null,
            ],
            'TRAVEL_ADVISORY' => [
                'value_text' => 'Check your government travel advisory for Uganda and follow local guidance for the regions on your itinerary.',
                'value_data' => null,
            ],
        ];

        foreach ($items as $code => $payload) {
            $typeId = TravelInformationType::query()->where('code', $code)->value('id');
            if ($typeId === null) {
                continue;
            }

            CountryTravelInformation::query()->updateOrCreate(
                [
                    'country_code' => self::COUNTRY,
                    'info_type_id' => $typeId,
                ],
                [
                    'value_text' => $payload['value_text'],
                    'value_data' => $payload['value_data'],
                    'is_live' => true,
                ],
            );
        }
    }

    private function seedRegionGuides(): void
    {
        $regions = [
            'UG-CENTRAL' => [
                'title' => 'Central',
                'summary' => 'Home to Kampala and Entebbe, Central Uganda is the main gateway: city energy, lakeshore access and the densest cluster of visitor services.',
                'is_featured' => true,
            ],
            'UG-WEST' => [
                'title' => 'West',
                'summary' => 'Western Uganda is known for mountain gorilla and chimpanzee experiences, crater lakes and the dramatic landscapes of the Albertine Rift.',
                'is_featured' => true,
            ],
            'UG-EAST' => [
                'title' => 'East',
                'summary' => 'Eastern Uganda offers Mount Elgon, Sipi Falls and a quieter pace, with strong coffee and hiking culture around the highlands.',
                'is_featured' => false,
            ],
            'UG-NORTH' => [
                'title' => 'North',
                'summary' => 'Northern Uganda includes the Nile around Murchison Falls and wide savannah landscapes, with growing tourism infrastructure beyond the south.',
                'is_featured' => false,
            ],
        ];

        foreach ($regions as $areaCode => $payload) {
            $areaId = GeographicArea::query()->where('code', $areaCode)->value('id');
            if ($areaId === null) {
                continue;
            }

            CountryRegionGuide::query()->updateOrCreate(
                [
                    'country_code' => self::COUNTRY,
                    'geographic_area_id' => $areaId,
                ],
                [
                    'title' => $payload['title'],
                    'summary' => $payload['summary'],
                    'image_link' => null,
                    'is_featured' => $payload['is_featured'],
                    'is_live' => true,
                ],
            );
        }
    }
}
