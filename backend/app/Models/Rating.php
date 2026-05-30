<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    protected $table = 'rating';

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'makanan_id',
        'order_item_id',
        'nilai',
        'komentar',
        'tanggal_rating',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function makanan()
    {
        return $this->belongsTo(Makanan::class);
    }

    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class);
    }
}
