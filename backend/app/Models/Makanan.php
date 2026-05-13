<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Makanan extends Model
{
    public $timestamps = false;

    protected $table = 'makanan';

    protected $fillable = [
        'kategori_id',
        'seller_id',
        'nama_makanan',
        'gambar_makanan',
        'status',
        'deskripsi',
        'harga',
        'kalori',
        'protein',
        'lemak',
        'karbohidrat',
    ];

    public function seller()
    {
        return $this->belongsTo(Seller::class);
    }

    public function kategori()
    {
        return $this->belongsTo(Kategori::class);
    }
}
