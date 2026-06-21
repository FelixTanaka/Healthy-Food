<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HealthProfile extends Model
{
    public $timestamps = false;

    protected $table = 'health_profile';

    protected $fillable = [
        'user_id',
        'berat',
        'tinggi',
        'umur',
        'jenis_kelamin',
        'kalori',
        'protein',
        'lemak',
        'karbo',
        'goal',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}