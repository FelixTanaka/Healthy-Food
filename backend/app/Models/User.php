<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'users';

    public $timestamps = false;

    protected $fillable = [
        'username',
        'email',
        'password',
        'role_id',
        'no_telp',
        'image',
    ];

    public function role()
    {
        return $this->belongsTo(Role::class);
    }
}
