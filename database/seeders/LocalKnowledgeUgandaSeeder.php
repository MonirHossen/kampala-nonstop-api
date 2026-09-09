<?php

namespace Database\Seeders;

use App\Models\GeographicArea;
use App\Models\LocalKnowledge;
use App\Models\LocalKnowledgeTag;
use App\Models\LocalKnowledgeType;
use App\Models\PageContext;
use Illuminate\Database\Seeder;

/**
 * Uganda Local Knowledge sample content for the public random popup.
 *
 * Idempotent: matches on country_code + title.
 */
class LocalKnowledgeUgandaSeeder extends Seeder
{
    private const COUNTRY = 'UG';

    public function run(): void
    {
        $typeIds = LocalKnowledgeType::query()->pluck('id', 'code');
        $tagIds = LocalKnowledgeTag::query()->pluck('id', 'code');
        $contextIds = PageContext::query()->pluck('id', 'code');
        $areaIds = GeographicArea::query()->pluck('id', 'code');

        foreach ($this->items() as $item) {
            $typeId = $typeIds->get($item['type']);
            if ($typeId === null) {
                continue;
            }

            $record = LocalKnowledge::query()->updateOrCreate(
                [
                    'country_code' => self::COUNTRY,
                    'title' => $item['title'],
                ],
                [
                    'local_knowledge_type_id' => $typeId,
                    'geographic_area_id' => isset($item['area']) ? $areaIds->get($item['area']) : null,
                    'local_language_code' => $item['language'] ?? null,
                    'content' => $item['content'],
                    'explanation' => $item['explanation'] ?? null,
                    'image_link' => null,
                    'source_url' => $item['source_url'] ?? null,
                    'is_live' => $item['is_live'] ?? true,
                ],
            );

            $record->tags()->sync(
                collect($item['tags'] ?? [])
                    ->map(fn (string $code) => $tagIds->get($code))
                    ->filter()
                    ->values()
                    ->all()
            );

            $record->pageContexts()->sync(
                collect($item['contexts'] ?? [])
                    ->map(fn (string $code) => $contextIds->get($code))
                    ->filter()
                    ->values()
                    ->all()
            );
        }
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function items(): array
    {
        return [
            [
                'type' => 'FUN_FACT',
                'title' => 'Pearl of Africa',
                'content' => 'Winston Churchill called Uganda the “Pearl of Africa” after travelling through East Africa in 1907 — the nickname still fits the lakes, hills and wildlife packed into a relatively small country.',
                'tags' => ['HISTORY', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE_OVERVIEW', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Source of the Nile',
                'content' => 'Jinja, on Lake Victoria, is widely recognised as the source of the Nile — the river then runs north through Uganda before continuing towards the Mediterranean.',
                'tags' => ['HISTORY'],
                'contexts' => ['HOME', 'GUIDE_REGION'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Equator crossing',
                'content' => 'The equator crosses Uganda just south of Kampala. Many travellers stop at the marked crossing on the Kampala–Masaka road for photos and the classic water-drain demonstration.',
                'tags' => ['GETTING_AROUND'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Mountain gorillas',
                'content' => 'Uganda is one of only a handful of countries where you can trek to see mountain gorillas, mainly in Bwindi Impenetrable National Park and Mgahinga in the south-west.',
                'tags' => ['CULTURE'],
                'area' => 'UG-WEST',
                'contexts' => ['GUIDE_REGION', 'HOME'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'A young country',
                'content' => 'Uganda has one of the youngest populations in the world. That energy shows up in Kampala’s music, start-ups, nightlife and street food as much as in official statistics.',
                'tags' => ['CULTURE'],
                'contexts' => ['HOME', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Lake Victoria scale',
                'content' => 'Lake Victoria is Africa’s largest lake by area. Entebbe sits on its northern shore, which is why the international airport feels more lakeside town than inland capital.',
                'tags' => ['ARRIVAL'],
                'area' => 'UG-CENTRAL',
                'contexts' => ['GUIDE_REGION', 'HOME'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Fifty-plus languages',
                'content' => 'Uganda has more than 50 living languages. English is official, Swahili is a second official language, and Luganda is the one you will hear most around Kampala.',
                'tags' => ['LANGUAGE'],
                'contexts' => ['GUIDE_ESSENTIALS', 'HOME'],
            ],
            [
                'type' => 'FUN_FACT',
                'title' => 'Boda boda origin',
                'content' => '“Boda boda” originally described border-to-border motorcycle taxis. In Kampala it now means almost any motorbike-for-hire weaving through traffic.',
                'tags' => ['TRANSPORT'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],

            [
                'type' => 'PHRASE',
                'title' => 'Oli otya?',
                'content' => 'Oli otya?',
                'explanation' => 'The everyday Luganda greeting: “How are you?” A typical reply is “Gyendi” (I’m fine). Using it, even once, usually gets a warmer response than jumping straight to English.',
                'language' => 'lg',
                'tags' => ['LANGUAGE', 'ETIQUETTE'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Webale',
                'content' => 'Webale',
                'explanation' => 'Luganda for “thank you.” Add “nyo” for “thank you very much”: Webale nyo.',
                'language' => 'lg',
                'tags' => ['LANGUAGE', 'ETIQUETTE'],
                'contexts' => ['HOME', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Ssebo and Nnyabo',
                'content' => 'Ssebo / Nnyabo',
                'explanation' => 'Polite Luganda forms of address: Ssebo for a man, Nnyabo for a woman. Useful with taxi drivers, market vendors and hotel staff.',
                'language' => 'lg',
                'tags' => ['LANGUAGE', 'ETIQUETTE'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Tusanyuse okukulaba',
                'content' => 'Tusanyuse okukulaba',
                'explanation' => '“We are happy to see you.” A warm welcome you may hear from hosts — worth recognising even if you do not say it yourself.',
                'language' => 'lg',
                'tags' => ['LANGUAGE', 'CULTURE'],
                'contexts' => ['HOME'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Kale',
                'content' => 'Kale',
                'explanation' => 'A flexible Luganda yes / OK / alright. You will hear it constantly in Kampala conversation as agreement or a soft close to a discussion.',
                'language' => 'lg',
                'tags' => ['LANGUAGE'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Jambo',
                'content' => 'Jambo',
                'explanation' => 'A Swahili hello used across East Africa. English is more common in Kampala, but Jambo still works as a friendly, widely understood greeting.',
                'language' => 'sw',
                'tags' => ['LANGUAGE'],
                'contexts' => ['HOME', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Asante',
                'content' => 'Asante',
                'explanation' => 'Swahili for “thank you.” Asante sana means “thank you very much.” Handy beyond Kampala, especially towards Kenya and Tanzania.',
                'language' => 'sw',
                'tags' => ['LANGUAGE', 'ETIQUETTE'],
                'contexts' => ['HOME'],
            ],
            [
                'type' => 'PHRASE',
                'title' => 'Mzungu',
                'content' => 'Mzungu',
                'explanation' => 'A Swahili-origin word for a foreigner, especially a white visitor. It is usually descriptive rather than hostile; a smile and a greeting still go a long way.',
                'language' => 'sw',
                'tags' => ['LANGUAGE', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE'],
            ],

            [
                'type' => 'ETIQUETTE',
                'title' => 'Greet before you ask',
                'content' => 'Start with a greeting before a request — even a short “hello, how are you?” Matters in shops, taxis and offices. Jumping straight to business can read as abrupt.',
                'tags' => ['ETIQUETTE', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Right hand for exchange',
                'content' => 'Give and receive money, food and gifts with your right hand, or with both hands. The left hand is still considered less polite for that kind of exchange.',
                'tags' => ['ETIQUETTE', 'MONEY'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Ask before photographing people',
                'content' => 'Always ask before photographing people, especially in markets, places of worship and rural communities. A nod and a greeting usually suffice; some vendors will expect a small purchase.',
                'tags' => ['ETIQUETTE', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Modest dress at religious sites',
                'content' => 'Cover shoulders and knees for mosques, churches and traditional shrines. Kampala streetwear is relaxed; sacred spaces are not.',
                'tags' => ['ETIQUETTE', 'CULTURE'],
                'contexts' => ['GUIDE_TRAVEL_GUIDE', 'HOME'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Patience with time',
                'content' => 'Appointments can run late without anyone treating it as a crisis. Build buffer into plans, especially around Kampala traffic, and stay polite rather than pushing.',
                'tags' => ['ETIQUETTE', 'GETTING_AROUND'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Public affection',
                'content' => 'Kampala is more relaxed than rural Uganda, but overt public affection still draws attention. A little discretion is the local default.',
                'tags' => ['ETIQUETTE'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME'],
            ],
            [
                'type' => 'ETIQUETTE',
                'title' => 'Tipping is a thank-you, not a bill',
                'content' => 'Tipping is appreciated rather than automatic. Rounding up a taxi fare, leaving 5–10% in a sit-down restaurant, or a small cash thank-you to a guide is typical.',
                'tags' => ['ETIQUETTE', 'MONEY', 'PAYMENTS'],
                'contexts' => ['GUIDE_TRAVEL_GUIDE', 'HOME'],
            ],

            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Agree the boda fare first',
                'content' => 'Agree the fare before you sit on a boda boda. Ride-hailing apps (SafeBoda, Uber, Bolt) remove most of that negotiation in Kampala and keep a record of the trip.',
                'tags' => ['TRANSPORT', 'GETTING_AROUND', 'SAFETY'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Cash still matters',
                'content' => 'Cards work in many hotels, restaurants and supermarkets in Kampala. Carry some Ugandan shillings anyway — markets, bodas and smaller eateries are still cash-first.',
                'tags' => ['MONEY', 'PAYMENTS'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Mobile money is everywhere',
                'content' => 'MTN MoMo and Airtel Money booths are on almost every Kampala street. Locals use them for everything from school fees to market stalls. Visitors can often pay a vendor who then pays onward by mobile money.',
                'tags' => ['MOBILE_MONEY', 'PAYMENTS'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Buy a local SIM on arrival',
                'content' => 'MTN and Airtel kiosks sit just after baggage reclaim at Entebbe. Bring your passport. Data is inexpensive and coverage is strong in Kampala and major towns.',
                'tags' => ['CONNECTIVITY', 'ARRIVAL'],
                'contexts' => ['GUIDE_TRAVEL_GUIDE', 'HOME'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Entebbe to Kampala takes longer than the map suggests',
                'content' => 'The airport is about 40 km from Kampala. In light traffic that can be 45–60 minutes; in the evening peak it can double. Build slack around flight times.',
                'tags' => ['ARRIVAL', 'TRANSPORT'],
                'area' => 'UG-CENTRAL',
                'contexts' => ['GUIDE_TRAVEL_GUIDE', 'GUIDE_REGION', 'HOME'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Drink bottled or treated water',
                'content' => 'Stick to sealed bottled water or a filter bottle. Ice in established restaurants is usually fine; be more cautious with street-side juices if you have a sensitive stomach.',
                'tags' => ['HEALTH'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Pack a Type G adapter',
                'content' => 'Uganda uses Type G sockets (the UK three-pin) at 240 V. A single adapter covers hotels, offices and most guesthouses.',
                'tags' => ['ACCOMMODATION'],
                'contexts' => ['GUIDE_ESSENTIALS', 'GUIDE_TRAVEL_GUIDE', 'HOME'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Two rainy seasons, not a monsoon',
                'content' => 'Kampala’s wetter months are roughly March–May and September–November. Rain often arrives as a heavy burst rather than an all-day washout — a light jacket still earns its bag space.',
                'tags' => ['WEATHER'],
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'PRACTICAL_TIP',
                'title' => 'Yellow fever certificate',
                'content' => 'A yellow fever vaccination certificate is commonly requested on entry. Keep it with your passport rather than packed in hold luggage.',
                'tags' => ['HEALTH', 'ARRIVAL'],
                'contexts' => ['GUIDE_TRAVEL_INFORMATION', 'GUIDE_TRAVEL_GUIDE', 'HOME'],
            ],

            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Buganda hospitality',
                'content' => 'Kampala sits in Buganda, historically a powerful kingdom. Politeness, greeting rituals and respect for elders still shape everyday interaction, even in a busy capital.',
                'tags' => ['CULTURE', 'HISTORY'],
                'area' => 'UG-CENTRAL',
                'contexts' => ['GUIDE_ESSENTIALS', 'GUIDE_REGION', 'HOME'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'The Rolex is not a watch',
                'content' => 'A Rolex is Uganda’s iconic street wrap: chapati rolled around eggs, cabbage and tomato. Cheap, filling, and available from roadside stoves from breakfast until late.',
                'tags' => ['FOOD', 'CULTURE'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Matooke on the table',
                'content' => 'Steamed green bananas — matooke — are the staple of central Uganda. Served mashed with a groundnut or meat sauce, it is comfort food rather than a tourist dish.',
                'tags' => ['FOOD', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Church and mosque side by side',
                'content' => 'Uganda is religiously mixed: Christianity is the majority, Islam is well established, and traditional practice continues. Friday prayers and Sunday services both shape the city’s rhythm.',
                'tags' => ['CULTURE'],
                'contexts' => ['HOME', 'GUIDE_ESSENTIALS'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Kampala after dark',
                'content' => 'Nightlife clusters in areas such as Kabalagala, Kololo and the city centre. Live music and outdoor bars run late on weekends; weeknights are quieter but not empty.',
                'tags' => ['NIGHTLIFE', 'CULTURE'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'LISTING_DETAIL'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Markets set the price conversation',
                'content' => 'In markets, a first quoted price is often an opening. Stay friendly, know a rough fair range, and be willing to walk away. Supermarkets and malls are fixed-price.',
                'tags' => ['SHOPPING', 'MONEY'],
                'contexts' => ['HOME', 'GUIDE'],
            ],
            [
                'type' => 'CULTURAL_CONTEXT',
                'title' => 'Tea and coffee country',
                'content' => 'Uganda grows both tea and specialty coffee. A cup in Kampala is everyday fuel; a visit to a Mount Elgon or western coffee farm is a trip in its own right.',
                'tags' => ['FOOD', 'CULTURE'],
                'contexts' => ['HOME', 'GUIDE_REGION'],
            ],

            [
                'type' => 'INSIDER_TIP',
                'title' => 'Leave Kampala before the Friday rush',
                'content' => 'If you are heading west to Queen Elizabeth or Bwindi, leave Kampala early on Friday — or better, Thursday. Weekend traffic on the Masaka road can erase a whole afternoon.',
                'tags' => ['TRANSPORT', 'GETTING_AROUND'],
                'area' => 'UG-CENTRAL',
                'contexts' => ['GUIDE_REGION', 'TRIP_PLANNER', 'HOME'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Owino for the real city',
                'content' => 'St. Balikuddembe Market (Owino) is chaotic, cheap and local. Go with a guide or a Kampala friend the first time; it is the opposite of a mall, and that is the point.',
                'tags' => ['SHOPPING'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'DISCOVER'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Sunset at the lake, not the mall',
                'content' => 'For a first evening, skip the mall food court and go to a lakeside spot in Entebbe or Ggaba. Kampala’s hills are dramatic; the lake is where the day actually ends.',
                'tags' => ['NIGHTLIFE', 'FOOD'],
                'area' => 'UG-CENTRAL',
                'contexts' => ['HOME', 'GUIDE_REGION'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Forex beats the hotel desk',
                'content' => 'Kampala forex bureaux on Kampala Road and around Nakasero usually beat hotel exchange rates. Count your notes at the window; reputable desks are used to visitors doing exactly that.',
                'tags' => ['MONEY'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Sim-sim and muchomo after dark',
                'content' => 'Roadside muchomo (grilled meat) and sim-sim (sesame) snacks appear as the sun drops. Follow the busiest stall rather than the quietest — turnover is your hygiene cue.',
                'tags' => ['FOOD', 'NIGHTLIFE'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'LISTING_DETAIL'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Sipi over the obvious waterfall stop',
                'content' => 'If you have a spare day in the east, Sipi Falls on the slopes of Mount Elgon is the overnight people remember — coffee tours, cliff views and cooler air than Kampala.',
                'tags' => ['GETTING_AROUND'],
                'area' => 'UG-EAST',
                'contexts' => ['GUIDE_REGION', 'TRIP_PLANNER', 'HOME'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Murchison is closer than it feels',
                'content' => 'Murchison Falls is a long day from Kampala, but an overnight turns it from a rush into the classic Nile-and-savannah trip most first-time visitors actually want.',
                'tags' => ['GETTING_AROUND'],
                'area' => 'UG-NORTH',
                'contexts' => ['GUIDE_REGION', 'TRIP_PLANNER', 'HOME'],
            ],
            [
                'type' => 'INSIDER_TIP',
                'title' => 'Share your live location on night rides',
                'content' => 'For late boda or taxi rides, share a live location with someone. It is normal caution rather than alarmism, and drivers used to visitors will not take offence.',
                'tags' => ['SAFETY', 'TRANSPORT'],
                'area' => 'UG-KAMPALA',
                'contexts' => ['HOME', 'GUIDE_TRAVEL_GUIDE'],
            ],
        ];
    }
}
