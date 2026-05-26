<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    public $timestamps = false;

    protected $table = 'order_item';

    protected $fillable = [
        'order_id',
        'makanan_id',
        'jumlah',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function makanan()
    {
        return $this->belongsTo(Makanan::class);
    }
}
