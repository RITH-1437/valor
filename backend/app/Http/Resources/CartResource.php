<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product' => new ProductResource($this->whenLoaded('product')),
            'quantity' => $this->quantity,
            'selected_size' => $this->selected_size,
            'selected_color' => $this->selected_color,
            'total_price' => (float) $this->total_price,
            'created_at' => $this->created_at,
        ];
    }
}
