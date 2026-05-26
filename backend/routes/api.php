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
use App\Http\Controllers\KeranjangController;
use App\Http\Controllers\TransaksiController;
use App\Http\Controllers\RatingController;


Route::post('/register-pembeli', [UserController::class, 'registerPembeli']);
Route::post('/login', [UserController::class, 'login']);

Route::post('/register-admin', [UserController::class, 'registerAdmin']);

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

    Route::get('/makanan-pembeli', [MakananController::class, 'makananPembeli']);

    Route::post('/keranjang/tambah', [KeranjangController::class, 'tambahKeranjang']);

    Route::get('/keranjang', [KeranjangController::class, 'tampilKeranjang']);

    Route::post('/keranjang/tambah-jumlah/{id}', [KeranjangController::class, 'tambahJumlah']);

    Route::post('/keranjang/kurang-jumlah/{id}', [KeranjangController::class, 'kurangJumlah']);

    Route::delete('/keranjang/hapus', [KeranjangController::class, 'hapusKeranjang']);

    Route::post('/create-invoice', [TransaksiController::class, 'createInvoice']);

    Route::get('/cek-order/{id}', [TransaksiController::class, 'cekStatusOrder']);

    Route::get('/nutrisi-harian', [PembeliController::class, 'nutrisiHarian']);

    Route::get('/riwayat-transaksi', [TransaksiController::class, 'riwayatTransaksi']);

    Route::post('/rating', [RatingController::class, 'store']);
});

Route::post('/xendit-callback', [TransaksiController::class, 'xenditCallback']);

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/seller/profile', [SellerController::class, 'getProfile']);

    Route::post('/seller/profile', [SellerController::class, 'saveProfile']);

    Route::post('/seller/upload-photo', [SellerController::class, 'uploadPhoto']);

    Route::post('/makanan', [MakananController::class, 'store']);

    Route::get('/makanan', [MakananController::class, 'makananSeller']);

    Route::post('/makanan/{id}', [MakananController::class, 'update']);

    Route::delete('/makanan/{id}', [MakananController::class, 'destroy']);

});

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/register-seller', [UserController::class, 'registerSeller']);

    Route::get('/kategori', [KategoriController::class, 'index']);

    Route::get('/semua-makanan', [MakananController::class, 'semuaMakanan']);

    Route::put('/makanan/{id}/approve', [MakananController::class, 'approve']);

    Route::put('/makanan/{id}/reject', [MakananController::class, 'reject']);

    Route::delete('/admin/makanan/{id}', [MakananController::class, 'deleteMakananAdmin']);

});

