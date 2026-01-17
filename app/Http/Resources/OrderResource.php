<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'car_number' => $this->car_number,
            'order_date' => $this->order_date ? $this->order_date->toISOString() : null,
            'status' => $this->status,
            'notes' => $this->notes,
            'is_pair_crew' => $this->is_pair_crew,
            'items' => OrderItemResource::collection($this->whenLoaded('orderItems')),
            'created_at' => $this->created_at ? $this->created_at->toISOString() : null,
            'updated_at' => $this->updated_at ? $this->updated_at->toISOString() : null,
        ];
    }
}
