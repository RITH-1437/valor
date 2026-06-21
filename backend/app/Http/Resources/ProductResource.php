<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'category_id' => $this->category_id,
            'category' => new CategoryResource($this->whenLoaded('category')),
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'short_description' => $this->short_description,
            'price' => (float) $this->price,
            'discount_price' => $this->discount_price ? (float) $this->discount_price : null,
            'effective_price' => (float) $this->effective_price,
            'has_discount' => $this->has_discount,
            'discount_percent' => $this->discount_percent,
            'stock' => $this->stock,
            'sku' => $this->sku,
            'image' => $this->image,
            'is_featured' => $this->is_featured,
            'is_trending' => $this->is_trending,
            'is_active' => $this->is_active,
            'images' => ProductImageResource::collection($this->whenLoaded('images')),
            'sizes' => ProductSizeResource::collection($this->whenLoaded('sizes')),
            'colors' => ProductColorResource::collection($this->whenLoaded('colors')),
            'created_at' => $this->created_at,
        ];
    }
}
