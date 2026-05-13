<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Makanan;
use Illuminate\Support\Facades\Auth;
use App\Models\Seller;

class MakananController extends Controller
{
    public function store(Request $request)
    {
        dd($request->all());
        $request->validate([
            'kategori_id' => 'required',
            'nama_makanan' => 'required',
            'deskripsi' => 'required',
            'harga' => 'required',
            'bahan' => 'required',
            'gambar_makanan' => 'required|image|mimes:jpg,jpeg,png',
        ]);

        $gambar = $request->file('gambar_makanan');
        $namaGambar = time() . '.' . $gambar->getClientOriginalExtension();

        $gambar->storeAs('makanan', $namaGambar, 'public');

        $response = Http::asForm()->post(
            'https://api.spoonacular.com/recipes/analyzeNutrition',
            [
                'apiKey' => env('SPOONACULAR_API_KEY'),

                'ingredients' => $request->bahan,
            ]
        );

        $nutrition = $response->json();

        $kalori = 0;
        $protein = 0;
        $lemak = 0;
        $karbohidrat = 0;

        if (isset($nutrition['calories'])) {
            $kalori = (float) filter_var(
                $nutrition['calories'],
                FILTER_SANITIZE_NUMBER_FLOAT,
                FILTER_FLAG_ALLOW_FRACTION
            );
        }

        if (isset($nutrition['protein'])) {
            $protein = (float) filter_var(
                $nutrition['protein'],
                FILTER_SANITIZE_NUMBER_FLOAT,
                FILTER_FLAG_ALLOW_FRACTION
            );
        }

        if (isset($nutrition['fat'])) {
            $lemak = (float) filter_var(
                $nutrition['fat'],
                FILTER_SANITIZE_NUMBER_FLOAT,
                FILTER_FLAG_ALLOW_FRACTION
            );
        }

        if (isset($nutrition['carbs'])) {
            $karbohidrat = (float) filter_var(
                $nutrition['carbs'],
                FILTER_SANITIZE_NUMBER_FLOAT,
                FILTER_FLAG_ALLOW_FRACTION
            );
        }

        $seller = Seller::where('user_id', Auth::id())->first();

        $makanan = Makanan::create([
            'kategori_id' => $request->kategori_id,

            'seller_id' => $seller->id,

            'nama_makanan' => $request->nama_makanan,

            'gambar_makanan' => 'makanan/' . $namaGambar,

            'status' => 'pending',

            'deskripsi' => $request->deskripsi,

            'harga' => $request->harga,

            'kalori' => $kalori,

            'protein' => $protein,

            'lemak' => $lemak,

            'karbohidrat' => $karbohidrat,
        ]);

        return response()->json([
            'message' => 'Makanan berhasil ditambahkan',
            'data' => $makanan,
            'nutrition' => $nutrition,
        ], 200);
    }
}
