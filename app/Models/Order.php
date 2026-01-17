<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'car_number',
        'order_date',
        'status',
        'notes',
        'is_pair_crew',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'order_date' => 'datetime',
        'is_pair_crew' => 'boolean',
    ];

    /**
     * Get the order items for the order.
     */
    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Get the equipment items through order items.
     */
    public function equipment()
    {
        return $this->hasManyThrough(Equipment::class, OrderItem::class, 'order_id', 'id', 'id', 'equipment_id');
    }
}
