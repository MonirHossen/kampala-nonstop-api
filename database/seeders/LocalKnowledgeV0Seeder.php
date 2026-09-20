<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

/**
 * Spreadsheet Local Knowledge V0 content (87 entries).
 *
 * Applies the knowledge import from sql/4_2_kampala_nonstop_local_knowledge_v0.sql
 * after geography and LocalKnowledgeReferenceSeeder.
 *
 * Tag/language inserts from that file are skipped: Laravel tables require
 * application-generated UUIDs, and LocalKnowledgeReferenceSeeder already
 * loads the full V0 reference set. Fixed knowledge UUIDs make reruns safe.
 *
 * The SQL file's BEGIN/COMMIT are stripped so this seeder can run inside
 * Laravel transactions (including PHPUnit RefreshDatabase) without ending them.
 */
class LocalKnowledgeV0Seeder extends Seeder
{
    public function run(): void
    {
        $path = base_path('sql/4_2_kampala_nonstop_local_knowledge_v0.sql');

        if (! is_readable($path)) {
            throw new RuntimeException("Local Knowledge V0 SQL not found: {$path}");
        }

        $sql = file_get_contents($path);

        if ($sql === false || trim($sql) === '') {
            throw new RuntimeException("Local Knowledge V0 SQL is empty: {$path}");
        }

        $sql = $this->prepareSql($sql);

        DB::transaction(function () use ($sql): void {
            DB::unprepared($sql);
        });
    }

    /**
     * Keep the temp import, validation, knowledge rows, and tag links.
     * Drop catalogue inserts (need UUID PKs) and transaction wrappers.
     */
    private function prepareSql(string $sql): string
    {
        $patterns = [
            '/-- Add missing spreadsheet reference data;.*?(?=-- Temporary import data)/s',
            '/INSERT INTO local_knowledge_tags\b.*?;\s*/s',
            '/INSERT INTO local_languages\b.*?;\s*/s',
            '/INSERT INTO local_language_countries\b.*?;\s*/s',
            '/^\s*BEGIN\s*;\s*/mi',
            '/^\s*COMMIT\s*;\s*/mi',
            '/^\s*SET LOCAL\b.*?;\s*/mi',
        ];

        foreach ($patterns as $pattern) {
            $sql = preg_replace($pattern, "\n", $sql) ?? $sql;
        }

        return $sql;
    }
}
