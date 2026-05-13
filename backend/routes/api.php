<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PembeliController;
use App\Http\Controllers\AlamatController;
use App\Http\Controllers\HealthProfileController;
use App\Http\Controllers\ChatbotController;
use App\Http\Controllers\SellerController;
use App\Http\Controllers\KategoriController;
use App\Http\Controllers\MakananController;


Route::post('/register-pembeli', [UserController::class, 'registerPembeli']);
Route::post('/login', [UserController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [PembeliController::class, 'getProfile']);

    Route::put('/profile', [PembeliController::class, 'updateProfile']);

    Route::get('/alamat', [AlamatController::class, 'index']);

    Route::post('/alamat', [AlamatController::class, 'store']);

    Route::put('/alamat/{id}', [AlamatController::class, 'update']);

    Route::delete('/alamat/{id}', [AlamatController::class, 'destroy']);

    Route::get('/health-profile', [HealthProfileController::class, 'getProfile']);
    
    Route::put('/health-profile', [HealthProfileController::class, 'update']);

    Route::post('/upload-profile-image', [UserController::class, 'uploadProfileImage']);

    Route::post('/chatbot', [ChatbotController::class, 'chat']);
});

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/seller/profile', [SellerController::class, 'getProfile']);

    Route::post('/seller/profile', [SellerController::class, 'saveProfile']);

    Route::post('/seller/upload-photo', [SellerController::class, 'uploadPhoto']);

    Route::post('/makanan', [MakananController::class, 'store']);

});

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/register-seller', [UserController::class, 'registerSeller']);

    Route::get('/kategori', [KategoriController::class, 'index']);

});

