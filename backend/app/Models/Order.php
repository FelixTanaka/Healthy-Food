<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    public $timestamps = false;

    protected $table = 'orders';

    protected $fillable = [
        'user_id',
        'total_harga',
        'biaya_admin',
        'status_order',
        'metode_transaksi',
        'status_transaksi',
        'tanggal_transaksi',
        'alamat_pengiriman',
        'external_id',
        'ongkir',
        'longitude',
        'latitude',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class, 'order_id', 'id');
    }
}
