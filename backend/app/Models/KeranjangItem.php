<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KeranjangItem extends Model
{
     public $timestamps = false;

    protected $table = 'keranjang_item';

    protected $fillable = [
        'makanan_id',
        'keranjang_id',
        'jumlah',
    ];

    public function keranjang()
    {
        return $this->belongsTo(Keranjang::class);
    }

    public function makanan()
    {
        return $this->belongsTo(Makanan::class);
    }
}
