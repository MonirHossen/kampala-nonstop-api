<?php

namespace Tests\Feature;

use App\Models\GeographicArea;
use App\Models\LocalKnowledge;
use App\Models\LocalKnowledgeTag;
use App\Models\LocalKnowledgeType;
use App\Models\PageContext;
use App\Models\User;
use Database\Seeders\GeographicAreaSeeder;
use Database\Seeders\LocalKnowledgeReferenceSeeder;
use Database\Seeders\LocalKnowledgeUgandaSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LocalKnowledgeTest extends TestCase
{
    use RefreshDatabase;

    private function seedKnowledge(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
            LocalKnowledgeUgandaSeeder::class,
        ]);
    }

    public function test_random_requires_country_code(): void
    {
        $this->seedKnowledge();

        $this->getJson('/api/v1/local-knowledge/random')
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['country_code']);
    }

    public function test_random_filters_by_country(): void
    {
        $this->seedKnowledge();

        $this->getJson('/api/v1/local-knowledge/random?country_code=KE')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $response = $this->getJson('/api/v1/local-knowledge/random?country_code=ug&limit=5');

        $response->assertOk();
        $this->assertNotEmpty($response->json('data'));
        $this->assertTrue(collect($response->json('data'))->every(
            fn (array $item): bool => $item['country_code'] === 'UG'
        ));
    }

    public function test_random_excludes_unpublished_items(): void
    {
        $this->seedKnowledge();

        LocalKnowledge::query()->update(['is_live' => false]);

        $this->getJson('/api/v1/local-knowledge/random?country_code=UG')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_untagged_page_context_is_eligible_everywhere(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
        ]);

        $typeId = LocalKnowledgeType::query()->where('code', 'FUN_FACT')->value('id');

        LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'title' => 'Global fun fact',
            'content' => 'Eligible on every page because it has no page-context links.',
            'is_live' => true,
        ]);

        $home = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&page_context=HOME');
        $guide = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&page_context=GUIDE_ESSENTIALS');

        $home->assertOk()->assertJsonPath('data.0.title', 'Global fun fact');
        $guide->assertOk()->assertJsonPath('data.0.title', 'Global fun fact');
    }

    public function test_page_context_matching_narrows_tagged_items(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
        ]);

        $typeId = LocalKnowledgeType::query()->where('code', 'FUN_FACT')->value('id');
        $homeId = PageContext::query()->where('code', 'HOME')->value('id');
        $essentialsId = PageContext::query()->where('code', 'GUIDE_ESSENTIALS')->value('id');

        $homeOnly = LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'title' => 'Home only',
            'content' => 'Only on the homepage.',
            'is_live' => true,
        ]);
        $homeOnly->pageContexts()->sync([$homeId]);

        $essentialsOnly = LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'title' => 'Essentials only',
            'content' => 'Only on Guide Essentials.',
            'is_live' => true,
        ]);
        $essentialsOnly->pageContexts()->sync([$essentialsId]);

        $home = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&page_context=HOME&limit=10');
        $essentials = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&page_context=GUIDE_ESSENTIALS&limit=10');

        $homeTitles = collect($home->json('data'))->pluck('title')->all();
        $essentialsTitles = collect($essentials->json('data'))->pluck('title')->all();

        $this->assertContains('Home only', $homeTitles);
        $this->assertNotContains('Essentials only', $homeTitles);
        $this->assertContains('Essentials only', $essentialsTitles);
        $this->assertNotContains('Home only', $essentialsTitles);
    }

    public function test_geographic_relevance_inherits_from_ancestors(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
        ]);

        $typeId = LocalKnowledgeType::query()->where('code', 'INSIDER_TIP')->value('id');
        $centralId = GeographicArea::query()->where('code', 'UG-CENTRAL')->value('id');
        $westId = GeographicArea::query()->where('code', 'UG-WEST')->value('id');

        LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'geographic_area_id' => $centralId,
            'title' => 'Central traffic',
            'content' => 'Anchored to Central, so it should still appear on Kampala pages.',
            'is_live' => true,
        ]);

        LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'geographic_area_id' => $westId,
            'title' => 'Western gorilla tip',
            'content' => 'Anchored to West, so it should not appear on Kampala pages.',
            'is_live' => true,
        ]);

        $kampala = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&geographic_area_code=UG-KAMPALA&limit=10');
        $titles = collect($kampala->json('data'))->pluck('title')->all();

        $kampala->assertOk();
        $this->assertContains('Central traffic', $titles);
        $this->assertNotContains('Western gorilla tip', $titles);
    }

    public function test_country_wide_items_appear_regardless_of_area(): void
    {
        $this->seed([
            GeographicAreaSeeder::class,
            LocalKnowledgeReferenceSeeder::class,
        ]);

        $typeId = LocalKnowledgeType::query()->where('code', 'PRACTICAL_TIP')->value('id');

        LocalKnowledge::query()->create([
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'UG',
            'geographic_area_id' => null,
            'title' => 'Nationwide tip',
            'content' => 'No geographic anchor means country-wide.',
            'is_live' => true,
        ]);

        $this->getJson('/api/v1/local-knowledge/random?country_code=UG&geographic_area_code=UG-KAMPALA')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Nationwide tip');
    }

    public function test_exclude_ids_are_honoured(): void
    {
        $this->seedKnowledge();

        $ids = LocalKnowledge::query()
            ->live()
            ->where('country_code', 'UG')
            ->pluck('id');

        $keep = $ids->last();
        $exclude = $ids->reject(fn (string $id): bool => $id === $keep)->implode(',');

        $response = $this->getJson(
            '/api/v1/local-knowledge/random?country_code=UG&limit=10&exclude_ids='.urlencode($exclude)
        );

        $response->assertOk();
        $returned = collect($response->json('data'))->pluck('id')->all();

        $this->assertContains($keep, $returned);
        $this->assertCount(1, $returned);
    }

    public function test_tag_filter_narrows_results(): void
    {
        $this->seedKnowledge();

        $response = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&tags=LANGUAGE&limit=10');

        $response->assertOk();
        $this->assertNotEmpty($response->json('data'));
        $this->assertTrue(collect($response->json('data'))->every(
            fn (array $item): bool => collect($item['tags'])->contains('code', 'LANGUAGE')
        ));
    }

    public function test_limit_is_clamped_to_ten_for_random(): void
    {
        $this->seedKnowledge();

        $response = $this->getJson('/api/v1/local-knowledge/random?country_code=UG&limit=100');

        $response->assertOk();
        $this->assertLessThanOrEqual(10, count($response->json('data')));
    }

    public function test_admin_can_create_local_knowledge_item(): void
    {
        $this->seedKnowledge();

        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $typeId = LocalKnowledgeType::query()->where('code', 'FUN_FACT')->value('id');
        $tagId = LocalKnowledgeTag::query()->where('code', 'CULTURE')->value('id');
        $contextId = PageContext::query()->where('code', 'HOME')->value('id');

        $create = $this->withToken($token)->postJson('/api/v1/admin/local-knowledge/items', [
            'local_knowledge_type_id' => $typeId,
            'country_code' => 'ug',
            'title' => 'Admin-created fact',
            'content' => 'Created through the admin API.',
            'tag_ids' => [$tagId],
            'page_context_ids' => [$contextId],
        ]);

        $create->assertCreated()
            ->assertJsonPath('data.country_code', 'UG')
            ->assertJsonPath('data.title', 'Admin-created fact');

        $this->assertTrue(
            collect($create->json('data.tags'))->contains('code', 'CULTURE')
        );
    }

    public function test_admin_local_knowledge_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/admin/local-knowledge/items')->assertUnauthorized();
        $this->postJson('/api/v1/admin/local-knowledge/items', [
            'content' => 'Nope',
        ])->assertUnauthorized();
    }
}
