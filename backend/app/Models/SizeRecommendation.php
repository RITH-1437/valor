<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SizeRecommendation extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'height_cm', 'weight_kg', 'body_type', 'recommended_size'];

    protected $casts = [
        'height_cm' => 'integer',
        'weight_kg' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
