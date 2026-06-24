<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Seller;

class Seller extends Model
{
    public $timestamps = false;

    protected $table = 'seller';

    protected $fillable = [
        'user_id',
        'nama_toko',
        'alamat',
        'deskripsi',
        'foto_toko',
        'latitude',
        'longitude',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function makanan()
    {
        return $this->hasMany(Makanan::class);
    }
}
