<?php

namespace App\Support;

/**
 * Maps the public Discover labels onto existing catalogue codes.
 * Editorial themes are not new taxonomy rows.
 */
final class DiscoverCatalogueMap
{
    /**
     * @var array<string, string>
     */
    public const TYPE_LABELS = [
        'EXPERIENCE' => 'Experiences',
        'ACTIVITY' => 'Activities',
        'EVENT' => 'Events',
        'TOUR' => 'Tours',
        'SERVICE' => 'Services',
    ];

    /**
     * @var array<string, list<string>>
     */
    public const CATEGORY_CODES = [
        'Food & Local Life' => ['RESTAURANTS_FOOD'],
        'Culture & Heritage' => ['CULTURE_HERITAGE'],
        'Music, Nightlife & Entertainment' => ['NIGHTLIFE_ENTERTAINMENT'],
        'Nature & Wildlife' => ['WILDLIFE_NATURE'],
        'Wellness & Relaxation' => ['WELLNESS_BEAUTY'],
        'Sports & Recreation' => ['SPORTS_RECREATION'],
        'Shopping' => ['SHOPPING'],
        'Community & Impact' => ['COMMUNITY_IMPACT'],
    ];

    /**
     * @var array<string, list<string>>
     */
    public const SUBCATEGORY_CODES = [
        'Adventure & Outdoors' => ['SPORTS_RECREATION_ADVENTURE_AND_OUTDOOR_CENTRES'],
    ];

    /**
     * @var array<string, string>
     */
    public const INTEREST_LISTING_TYPES = [
        'Events & Festivals' => 'EVENT',
    ];

    /**
     * @return list<string>
     */
    public static function acceptedTypes(): array
    {
        return array_values(array_unique([
            ...array_keys(self::TYPE_LABELS),
            ...array_values(self::TYPE_LABELS),
        ]));
    }

    /**
     * @return list<string>
     */
    public static function interests(): array
    {
        return array_values(array_unique([
            ...array_keys(self::CATEGORY_CODES),
            ...array_keys(self::SUBCATEGORY_CODES),
            ...array_keys(self::INTEREST_LISTING_TYPES),
        ]));
    }

    public static function listingTypeCode(?string $type): ?string
    {
        if ($type === null || trim($type) === '') {
            return null;
        }

        $trimmed = trim($type);
        $upper = strtoupper($trimmed);

        if (isset(self::TYPE_LABELS[$upper])) {
            return $upper;
        }

        foreach (self::TYPE_LABELS as $code => $label) {
            if (strcasecmp($label, $trimmed) === 0) {
                return $code;
            }
        }

        return null;
    }
}
