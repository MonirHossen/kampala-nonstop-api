<?php

namespace Database\Seeders;

use App\Models\CountryGuideEssentialType;
use App\Models\CountryGuideEssentialValue;
use Illuminate\Database\Seeder;

/**
 * Uganda (UG) Country Guide essentials.
 *
 * Idempotent: matches on country_code + essential_type_id.
 */
class CountryGuideUgandaSeeder extends Seeder
{
    private const COUNTRY = 'UG';

    public function run(): void
    {
        $values = array_merge($this->narratives(), $this->facts());

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

    /**
     * @return array<string, array{value_text: string, value_data: array<string, mixed>}>
     */
    private function narratives(): array
    {
        return [
            'ABOUT' => $this->narrative('About Uganda', [
                $this->paragraph('Uganda sits in the heart of East Africa, bordered by Kenya, Tanzania, Rwanda, South Sudan and the Democratic Republic of the Congo. Compact, green and varied, it combines lakes, savannah, rainforest, mountains and one of the region’s most energetic capitals within a relatively small area.'),
                $this->paragraph('Dubbed the “Pearl of Africa” by Winston Churchill, Uganda is often described as Africa in miniature. That phrase makes sense once you realise you can experience urban nightlife, adventure sports and world-class wildlife within the same trip — without crossing borders.'),
            ]),
            'HISTORY' => $this->narrative('History of Uganda', [
                $this->paragraph('Uganda’s modern identity is shaped by deep pre-colonial roots, colonial administration, independence and long-term stabilisation.'),
                $this->paragraph('Before modern borders, the region was organised around powerful kingdoms such as Buganda, Bunyoro and Ankole, each with established systems of governance, culture and trade.'),
                $this->paragraph('Uganda became a British protectorate in 1894 and gained independence in 1962. The following decades included periods of political change and instability, particularly in the 1970s, before a gradual return to stability and institutional continuity from the late 1980s onwards.'),
                $this->paragraph('Today, Uganda is politically stable, regionally connected and demographically young — focused on growth, infrastructure, entrepreneurship and cultural influence.'),
            ]),
            'CULTURE_TRADITIONS' => $this->narrative('Culture & Traditions', [
                $this->paragraph('Uganda is home to 50+ ethnic groups, each with distinct languages, foods, music and customs. Despite this diversity, daily life feels cohesive rather than fragmented.'),
                $this->paragraph('You’ll notice a few cultural constants quickly:'),
                $this->list([
                    'Greetings matter; people acknowledge each other properly.',
                    'Humour is dry, teasing and often self-aware.',
                    'Music is constant — taxis, salons, bars, weddings.',
                    'Food is social and shared.',
                    'Being addressed as “my brother” or “my sister” shortly after meeting someone isn’t metaphorical. It’s how social ease is established.',
                ]),
            ]),
            'FOOD_DRINK_SOCIAL' => $this->narrative('Food, Drink & Social Life', [
                $this->paragraph('Food in Uganda is practical, filling and deeply social.'),
                $this->paragraph('Everyday staples and rituals include:'),
                $this->labelledList([
                    ['Rolex', 'A freshly made chapati rolled with eggs and vegetables, cooked to order — often with nyanya mbisi (raw tomatoes) added — and eaten on the go. A fan favourite with foreign visitors, often one of the first foods people actively seek out again after leaving Uganda.'],
                    ['Grilled meats (nyama choma)', 'Goat, beef or chicken, usually shared late into the evening.'],
                    ['Matooke', 'Steamed green bananas, groundnut sauces and smoked fish near lakes and rivers.'],
                ]),
                $this->paragraph('Uganda also has a strong social drinking culture. The national spirit, waragi, is part of celebrations, conversations and nightlife — traditionally distilled, now produced both locally and commercially.'),
                $this->paragraph('Drinking here is rarely rushed. Conversations usually outlast the drinks.'),
            ]),
            'LANGUAGES_COMMUNICATION' => $this->narrative('Languages & Communication', [
                $this->paragraph('English is the official language and is widely spoken, particularly in urban areas and across the tourism sector.'),
                $this->paragraph('Luganda is the most commonly heard local language in central Uganda and Kampala, while other regions use languages such as Runyankole/Rukiga in the southwest and Acholi or Alur in the north. Swahili is also understood by many guides, rangers and regional operators.'),
                $this->paragraph('Visitors don’t need to speak local languages to get around. Respect matters more than fluency. Two words you’ll hear — and can safely use — are:'),
                $this->labelledList([
                    ['Webale', 'Thank you.'],
                    ['Ssebo', 'A respectful form of address for a man.'],
                    ['Nnyabo', 'A respectful form of address for a woman.'],
                ]),
                $this->paragraph('They signal politeness and are universally appreciated.'),
            ]),
            'GEOGRAPHY_CLIMATE' => $this->narrative('Geography & Climate', [
                $this->paragraph('Uganda lies almost entirely on a plateau, which explains its moderate climate despite being on the equator.'),
                $this->paragraph('Key features include:'),
                $this->list([
                    'Lake Victoria — Africa’s largest lake by surface area',
                    'The source of the Nile at Jinja',
                    'Savannah landscapes in the north and west',
                    'Rainforests and mountain ranges in the southwest',
                ]),
                $this->subheading('Climate'),
                $this->list([
                    'Warm year-round (average 25–28°C)',
                    'Two rainy seasons: March–May and September–November',
                    'Rain is usually brief rather than constant',
                ]),
                $this->paragraph('This fertile environment supports year-round agriculture and an abundance of fresh food across the country.'),
            ]),
            'MAJOR_DESTINATIONS' => $this->narrative('Major Destinations & Regional Anchors', [
                $this->paragraph('Uganda’s key destinations are spread across the country and serve different roles:'),
                $this->labelledList([
                    ['Kampala', 'The capital and primary international city; centre of government, business, nightlife, culture and events.'],
                    ['Entebbe', 'International gateway on Lake Victoria, home to the main airport and a calmer lakeside pace.'],
                    ['Jinja', 'Adventure and leisure hub, known globally as the source of the Nile and for white-water rafting.'],
                    ['Gulu', 'The main city of northern Uganda, culturally distinct, with historical significance and a growing urban scene shaped by resilience, creativity and a slower, more expansive rhythm of life.'],
                    ['Western Uganda', 'The country’s most diverse region, bringing together savannah wildlife, primate forests, crater lakes, mountain landscapes, iconic road trips and pastoral Ankole culture within a single journey.'],
                    ['Murchison Falls National Park', 'Flagship wildlife destination combining dramatic landscapes with classic safari experiences.'],
                    ['Queen Elizabeth National Park', 'Biodiversity hotspot with savannah, lakes and renowned birdlife.'],
                    ['Bwindi Impenetrable Forest', 'One of the world’s few places for mountain gorilla trekking.'],
                    ['Fort Portal & the Rwenzori region', 'Crater lakes, highlands and access to mountain hiking.'],
                ]),
            ]),
            'TOURISM_GLANCE' => $this->narrative('Tourism at a Glance', [
                $this->paragraph('Uganda is internationally recognised for:'),
                $this->list([
                    'Mountain gorilla and chimpanzee trekking',
                    'Classic safaris (elephants, lions, buffalo, giraffes)',
                    'Birdlife, including the crested crane',
                    'Adventure tourism (rafting, hiking, cycling)',
                ]),
            ]),
            'KAMPALA_CITY_LIFE' => $this->narrative('Kampala: City Life Snapshot', [
                $this->paragraph('Kampala is a fast-growing city of several million people, dense and youthful in character. Traffic can be busy and unpredictable, but distances are short and movement is constant via taxis, ride-hailing apps and boda bodas.'),
                $this->paragraph('Hospitality is concentrated and social life runs late. Cafés, bars, restaurants and hotels are active throughout the week, giving the city a rhythm that blends work, leisure and nightlife rather than separating them.'),
            ]),
            'SAFETY_REASSURANCE' => $this->narrative('Safety & Practical Reassurance', [
                $this->paragraph('Uganda is generally safe for visitors, including first-time travellers. For day-to-day personal safety, most visitors find it comparable to — and often calmer than — many major European and North American cities when standard urban precautions are followed.'),
                $this->paragraph('As with any destination:'),
                $this->list([
                    'Be aware of your surroundings',
                    'Avoid displaying valuables unnecessarily',
                    'Use reputable transport and accommodation',
                ]),
                $this->paragraph('Hospitality staff, guides and local communities are accustomed to visitors and are typically welcoming and helpful.'),
            ]),
            'COST_OF_LIVING' => $this->narrative('Cost of Living & Currency', [
                $this->paragraph('The local currency is the Ugandan shilling (UGX).'),
                $this->paragraph('As a rough guide (rates fluctuate):'),
                [
                    'type' => 'rates',
                    'rows' => [
                        ['currency' => '1 USD', 'range' => 'UGX 3,800–4,000'],
                        ['currency' => '1 GBP', 'range' => 'UGX 4,700–5,000'],
                        ['currency' => '1 EUR', 'range' => 'UGX 4,100–4,400'],
                    ],
                ],
                $this->paragraph('Uganda offers strong value:'),
                $this->list([
                    'Everyday food and transport are inexpensive',
                    'Mid-range dining and hotels are affordable',
                    'High-end hospitality offers good value by international standards',
                ]),
                $this->paragraph('Cards are accepted in hotels, malls and major restaurants, but cash remains important day-to-day. Mobile money is widely used and normal.'),
            ]),
            'PUBLIC_HOLIDAYS' => $this->narrative('Public Holidays & Festivals', [
                $this->paragraph('Uganda observes national, religious and cultural holidays, including:'),
                $this->list([
                    'Independence Day (9 October)',
                    'Easter and Christmas',
                    'Eid holidays',
                    'Martyrs’ Day (3 June), a major pilgrimage event',
                ]),
                $this->paragraph('Beyond official dates, music events, cultural festivals and pop-up parties appear frequently and with little warning.'),
            ]),
            'LOCAL_ETIQUETTE' => $this->narrative('Local Etiquette', [
                $this->subheading('What visitors should know'),
                $this->list([
                    'Time is flexible; events often peak later than advertised.',
                    'Dress matters in social settings — Kampala is style-conscious.',
                    'Public displays of affection are modest.',
                    'Always ask before photographing people or security locations.',
                    'Tipping is not mandatory, but appreciation for good service is welcomed.',
                ]),
            ]),
        ];
    }

    /**
     * @return array<string, array{value_text: string, value_data: array<string, mixed>}>
     */
    private function facts(): array
    {
        return [
            'CAPITAL' => [
                'value_text' => 'Kampala',
                'value_data' => ['name' => 'Kampala'],
            ],
            'CURRENCY' => [
                'value_text' => 'Ugandan Shilling',
                'value_data' => ['name' => 'Ugandan Shilling'],
            ],
            'CURRENCY_CODE' => [
                'value_text' => 'UGX',
                'value_data' => ['code' => 'UGX'],
            ],
            'LANGUAGES' => [
                'value_text' => 'English; Swahili (second official language); Luganda widely spoken',
                'value_data' => [
                    'official' => ['English'],
                    'second_official' => ['Swahili'],
                    'widely_spoken' => ['Luganda'],
                ],
            ],
            'TIME_ZONE' => [
                'value_text' => 'East Africa Time (EAT), UTC+3',
                'value_data' => [
                    'name' => 'East Africa Time',
                    'abbreviation' => 'EAT',
                    'utc_offset' => '+03:00',
                ],
            ],
            'CALLING_CODE' => [
                'value_text' => '+256',
                'value_data' => ['calling_code' => '+256'],
            ],
            'DRIVING_SIDE' => [
                'value_text' => 'Left',
                'value_data' => ['side' => 'LEFT'],
            ],
            'ELECTRICITY' => [
                'value_text' => '240 V, 50 Hz',
                'value_data' => [
                    'voltage' => 240,
                    'frequency_hz' => 50,
                ],
            ],
            'PLUG_TYPE' => [
                'value_text' => 'Type G',
                'value_data' => ['types' => ['G']],
            ],
            'MAIN_AIRPORT' => [
                'value_text' => 'Entebbe International Airport (EBB)',
                'value_data' => [
                    'name' => 'Entebbe International Airport',
                    'iata_code' => 'EBB',
                ],
            ],
            'EMERGENCY_NUMBERS' => [
                'value_text' => 'General emergency: 112 or 999; Fire & Rescue: 0800 121 222; Traffic: 0800 199 099',
                'value_data' => [
                    'general' => ['112', '999'],
                    'fire_rescue' => '0800121222',
                    'traffic' => '0800199099',
                ],
            ],
            'MOBILE_INTERNET' => [
                'value_text' => '2G, 3G and 4G mobile services are available; 4G coverage is not yet nationwide.',
                'value_data' => [
                    'available_networks' => ['2G', '3G', '4G'],
                    '4g_nationwide' => false,
                ],
            ],
        ];
    }

    /**
     * @param  list<array<string, mixed>>  $blocks
     * @return array{value_text: string, value_data: array<string, mixed>}
     */
    private function narrative(string $heading, array $blocks): array
    {
        $paragraphs = [];
        $plain = [];

        foreach ($blocks as $block) {
            $type = $block['type'] ?? '';
            if ($type === 'paragraph') {
                $paragraphs[] = $block['text'];
                $plain[] = $block['text'];
            } elseif ($type === 'subheading') {
                $plain[] = $block['text'];
            } elseif ($type === 'list') {
                foreach ($block['items'] as $item) {
                    if (! is_array($item)) {
                        $plain[] = (string) $item;
                        continue;
                    }

                    $plain[] = isset($item['label'])
                        ? $item['label'].' — '.$item['text']
                        : (string) ($item['text'] ?? '');
                }
            } elseif ($type === 'rates') {
                foreach ($block['rows'] as $row) {
                    $plain[] = $row['currency'].': '.$row['range'];
                }
            }
        }

        return [
            'value_text' => implode("\n\n", $plain),
            'value_data' => [
                'display' => 'narrative',
                'heading' => $heading,
                'paragraphs' => $paragraphs,
                'blocks' => $blocks,
            ],
        ];
    }

    /**
     * @return array{type: string, text: string}
     */
    private function paragraph(string $text): array
    {
        return ['type' => 'paragraph', 'text' => $text];
    }

    /**
     * @return array{type: string, text: string}
     */
    private function subheading(string $text): array
    {
        return ['type' => 'subheading', 'text' => $text];
    }

    /**
     * @param  list<string>  $items
     * @return array{type: string, items: list<array{text: string}>}
     */
    private function list(array $items): array
    {
        return [
            'type' => 'list',
            'items' => array_map(static fn (string $text): array => ['text' => $text], $items),
        ];
    }

    /**
     * @param  list<array{0: string, 1: string}>  $items
     * @return array{type: string, items: list<array{label: string, text: string}>}
     */
    private function labelledList(array $items): array
    {
        return [
            'type' => 'list',
            'items' => array_map(
                static fn (array $item): array => ['label' => $item[0], 'text' => $item[1]],
                $items,
            ),
        ];
    }
}
