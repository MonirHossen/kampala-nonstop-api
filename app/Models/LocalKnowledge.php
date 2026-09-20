<?php

namespace App\Models;

use App\Models\Concerns\HasUuidPrimaryKey;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class LocalKnowledge extends Model
{
    use HasUuidPrimaryKey;

    protected $table = 'local_knowledge';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'local_knowledge_type_id',
        'country_code',
        'geographic_area_id',
        'local_language_code',
        'title',
        'content',
        'explanation',
        'image_link',
        'source_url',
        'is_live',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_live' => 'boolean',
        ];
    }

    /**
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeLive(Builder $query): Builder
    {
        return $query->where('is_live', true);
    }

    /**
     * @return BelongsTo<LocalKnowledgeType, $this>
     */
    public function type(): BelongsTo
    {
        return $this->belongsTo(LocalKnowledgeType::class, 'local_knowledge_type_id');
    }

    /**
     * @return BelongsTo<GeographicArea, $this>
     */
    public function geographicArea(): BelongsTo
    {
        return $this->belongsTo(GeographicArea::class, 'geographic_area_id');
    }

    /**
     * @return BelongsTo<LocalLanguage, $this>
     */
    public function language(): BelongsTo
    {
        return $this->belongsTo(LocalLanguage::class, 'local_language_code', 'code');
    }

    /**
     * @return BelongsToMany<LocalKnowledgeTag, $this>
     */
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(
            LocalKnowledgeTag::class,
            'local_knowledge_tag_links',
            'local_knowledge_id',
            'tag_id'
        );
    }

    /**
     * @return BelongsToMany<PageContext, $this>
     */
    public function pageContexts(): BelongsToMany
    {
        return $this->belongsToMany(
            PageContext::class,
            'local_knowledge_page_contexts',
            'local_knowledge_id',
            'page_context_id'
        );
    }
}
