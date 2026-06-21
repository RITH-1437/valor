<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'full_name' => $this->full_name,
            'phone' => $this->phone,
            'country' => $this->country,
            'city' => $this->city,
            'district' => $this->district,
            'street' => $this->street,
            'postal_code' => $this->postal_code,
            'is_default' => $this->is_default,
            'full_address' => $this->full_address,
            'created_at' => $this->created_at,
        ];
    }
}
