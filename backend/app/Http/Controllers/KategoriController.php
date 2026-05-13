<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Kategori;

class KategoriController extends Controller
{
    public function index()
    {
        $kategori = Kategori::all();

        return response()->json([
            'message' => 'Data kategori berhasil diambil',
            'data' => $kategori
        ], 200);
    }
}
