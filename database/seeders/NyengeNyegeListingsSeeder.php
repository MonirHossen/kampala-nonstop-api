<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Ensures NYENGE_NYEGE tag exists and is attached to Magma festival experience packages.
 */
class NyengeNyegeListingsSeeder extends Seeder
{
    public const TAG_CODE = 'NYENGE_NYEGE';

    /** @var list<string> */
    public const EXPERIENCE_SLUGS = [
        'budget-camp-crew',
        'comfort-shared-stay',
        'premium-riverside-escape',
        'recovery-day-bundle',
    ];

    public function run(): void
    {
        if (! Schema::hasTable('tags') || ! Schema::hasTable('listings') || ! Schema::hasTable('listing_tags')) {
            return;
        }

        $now = now();
        $tagId = DB::table('tags')->where('code', self::TAG_CODE)->value('id');

        if ($tagId === null) {
            $tagId = (string) Str::uuid();
            $row = [
                'id' => $tagId,
                'code' => self::TAG_CODE,
                'name' => 'Nyenge Nyenge',
                'is_live' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ];
            if (Schema::hasColumn('tags', 'created_by')) {
                $row['created_by'] = 'nyenge-seeder';
            }
            if (Schema::hasColumn('tags', 'updated_by')) {
                $row['updated_by'] = 'nyenge-seeder';
            }
            DB::table('tags')->insert($row);
        }

        $listingIds = DB::table('listings')
            ->whereIn('slug', self::EXPERIENCE_SLUGS)
            ->pluck('id');

        foreach ($listingIds as $listingId) {
            $exists = DB::table('listing_tags')
                ->where('listing_id', $listingId)
                ->where('tag_id', $tagId)
                ->exists();

            if ($exists) {
                continue;
            }

            $pivot = [
                'listing_id' => $listingId,
                'tag_id' => $tagId,
                'created_at' => $now,
                'updated_at' => $now,
            ];
            if (Schema::hasColumn('listing_tags', 'created_by')) {
                $pivot['created_by'] = 'nyenge-seeder';
            }
            if (Schema::hasColumn('listing_tags', 'updated_by')) {
                $pivot['updated_by'] = 'nyenge-seeder';
            }

            DB::table('listing_tags')->insert($pivot);
        }
    }
}
