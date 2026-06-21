<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Makanan;
use Illuminate\Support\Facades\Auth;
use App\Models\Seller;
use Stichoza\GoogleTranslate\GoogleTranslate;

class MakananController extends Controller
{
    public function store(Request $request)
    {
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

        $translator = new GoogleTranslate('en');

        $bahanInggris = $translator->translate(
            $request->bahan
        );

        $response = Http::asForm()->post(
            'https://api.spoonacular.com/recipes/parseIngredients?includeNutrition=true&apiKey=' . env('SPOONACULAR_API_KEY'),
            [
                'ingredientList' => $bahanInggris,

                'servings' => 1,
            ]
        );

        $nutrition = $response->json();

        $kalori = 0;
        $protein = 0;
        $lemak = 0;
        $karbohidrat = 0;

        foreach ($nutrition as $ingredient) {

            if (isset($ingredient['nutrition']['nutrients'])) {

                foreach ($ingredient['nutrition']['nutrients'] as $nutrient) {

                    if ($nutrient['name'] == 'Calories') {
                        $kalori += $nutrient['amount'];
                    }

                    if ($nutrient['name'] == 'Protein') {
                        $protein += $nutrient['amount'];
                    }

                    if ($nutrient['name'] == 'Fat') {
                        $lemak += $nutrient['amount'];
                    }

                    if ($nutrient['name'] == 'Carbohydrates') {
                        $karbohidrat += $nutrient['amount'];
                    }
                }
            }
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

            'bahan' => $request->bahan,

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

    public function makananSeller()
    {
        $seller = Seller::where('user_id', Auth::id())->first();

        $makanan = Makanan::with(['kategori', 'seller', 'ratings.user'])
           ->withAvg(
                'ratings',
                'nilai'
            )

            ->withCount(
                'ratings'
            )
            ->where('seller_id', $seller->id)
            ->orderByRaw("
                CASE
                    WHEN status = 'dikonfirmasi' THEN 1
                    WHEN status = 'pending' THEN 2
                    WHEN status = 'dibatalkan' THEN 3
                    ELSE 4
                END
            ")
            ->get();

        return response()->json([
            'message' => 'Makanan berhasil diambil',
            'data' => $makanan
        ]);
    }

    public function update(Request $request, $id)
    {
        $seller = Seller::where('user_id', Auth::id())->first();

        $makanan = Makanan::where('seller_id', $seller->id)
            ->where('id', $id)
            ->first();

        if (!$makanan) {
            return response()->json([
                'message' => 'Makanan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'kategori_id' => 'nullable',
            'nama_makanan' => 'nullable',
            'deskripsi' => 'nullable',
            'harga' => 'nullable',
            'bahan' => 'nullable',
            'gambar_makanan' => 'nullable|image|mimes:jpg,jpeg,png',
        ]);

        $kalori = $makanan->kalori;
        $protein = $makanan->protein;
        $lemak = $makanan->lemak;
        $karbohidrat = $makanan->karbohidrat;

        if ($request->filled('bahan')) {
            $translator = new GoogleTranslate('en');

            $bahanInggris = $translator->translate(
                $request->bahan
            );

            $response = Http::asForm()->post(
                'https://api.spoonacular.com/recipes/parseIngredients?includeNutrition=true&apiKey=' . env('SPOONACULAR_API_KEY'),
                [
                    'ingredientList' => $bahanInggris,
                    'servings' => 1,
                ]
            );

            $nutrition = $response->json();

            $kalori = 0;
            $protein = 0;
            $lemak = 0;
            $karbohidrat = 0;

            foreach ($nutrition as $ingredient) {

                if (isset($ingredient['nutrition']['nutrients'])) {

                    foreach ($ingredient['nutrition']['nutrients'] as $nutrient) {

                        if ($nutrient['name'] == 'Calories') {
                            $kalori += $nutrient['amount'];
                        }

                        if ($nutrient['name'] == 'Protein') {
                            $protein += $nutrient['amount'];
                        }

                        if ($nutrient['name'] == 'Fat') {
                            $lemak += $nutrient['amount'];
                        }

                        if ($nutrient['name'] == 'Carbohydrates') {
                            $karbohidrat += $nutrient['amount'];
                        }
                    }
                }
            }
        }

        if ($request->hasFile('gambar_makanan')) {

            $gambar = $request->file('gambar_makanan');

            $namaGambar = time() . '.' . $gambar->getClientOriginalExtension();

            $gambar->storeAs('makanan', $namaGambar, 'public');

            $makanan->gambar_makanan = 'makanan/' . $namaGambar;
        }

        if ($request->filled('kategori_id')) {
            $makanan->kategori_id = $request->kategori_id;
        }

        if ($request->filled('nama_makanan')) {
            $makanan->nama_makanan = $request->nama_makanan;
        }

        if ($request->filled('bahan')) {
            $makanan->bahan = $request->bahan;
        }

        if ($request->filled('deskripsi')) {
            $makanan->deskripsi = $request->deskripsi;
        }

        if ($request->filled('harga')) {
            $makanan->harga = $request->harga;
        }

        $makanan->kalori = $kalori;
        $makanan->protein = $protein;
        $makanan->lemak = $lemak;
        $makanan->karbohidrat = $karbohidrat;

        $makanan->save();

        return response()->json([
            'message' => 'Makanan berhasil diupdate',
            'data' => $makanan
        ], 200);
    }

    public function destroy($id)
    {
        $seller = Seller::where('user_id', Auth::id())->first();

        $makanan = Makanan::where('seller_id', $seller->id)->where('id', $id)->first();

        if (!$makanan) {

            return response()->json([
                'message' => 'Makanan tidak ditemukan'
            ], 404);

        }

        $makanan->delete();

        return response()->json([
            'message' => 'Makanan berhasil dihapus'
        ], 200);
    }

    public function semuaMakanan()
    {
        $makanan = Makanan::with(['kategori', 'seller'])
            ->get();

        return response()->json([
            'message' => 'Semua makanan berhasil diambil',
            'data' => $makanan
        ]);
    }

    public function approve($id)
    {
        $makanan = Makanan::find($id);

        if (!$makanan) {
            return response()->json([
                'message' => 'Makanan tidak ditemukan'
            ], 404);
        }

        $makanan->status = 'dikonfirmasi';

        $makanan->save();

        return response()->json([
            'message' => 'Makanan berhasil dikonfirmasi'
        ]);
    }

    public function reject($id)
    {
        $makanan = Makanan::find($id);

        if (!$makanan) {
            return response()->json([
                'message' => 'Makanan tidak ditemukan'
            ], 404);
        }

        $makanan->status = 'ditolak';

        $makanan->save();

        return response()->json([
            'message' => 'Makanan berhasil ditolak'
        ]);
    }

    public function deleteMakananAdmin($id)
    {
        $makanan = Makanan::find($id);

        if (!$makanan) {
            return response()->json([
                'message' => 'Makanan tidak ditemukan'
            ], 404);
        }

        $makanan->delete();

        return response()->json([
            'message' => 'Makanan berhasil dihapus'
        ], 200);
    }

    public function makananPembeli()
    {
        $makanan = Makanan::with(['kategori', 'seller', 'ratings.user'])
        ->withAvg(
            'ratings',
            'nilai',
        )
        ->withCount('ratings')
            ->where('status', 'dikonfirmasi')
            ->orderByDesc('ratings_avg_nilai')

            ->orderByDesc(
                'ratings_count'
            )
            ->get();

        return response()->json([
            'message' => 'Semua makanan berhasil diambil',
            'data' => $makanan
        ]);
    }

    public function menuPopuler()
    {
        $makanan = Makanan::with([
                'kategori',
                'seller.user',
                'ratings.user'
            ])
            ->withAvg(
                'ratings',
                'nilai'
            )
            ->withCount(
                'ratings'
            )
            ->where(
                'status',
                'dikonfirmasi'
            )
            ->orderByDesc(
                'ratings_avg_nilai'
            )
            ->orderByDesc(
                'ratings_count'
            )
            ->take(5)
            ->get();

        return response()->json([
            'message' => 'Makanan populer berhasil diambil',
            'data' => $makanan,
        ]);
    }

    public function rekomendasi(Request $request)
    {
        $user = auth()->user();

        $goal = $user->healthProfile->goal;

        $query = Makanan::with(['kategori', 'seller', 'ratings.user'])
            ->withAvg('ratings', 'nilai')
            ->withCount('ratings');

        if ($goal === 'vegetarian') {
            $query->whereHas('kategori', function ($q) {
                $q->where('nama_kategori', 'vegetarian');
            });
        }

        elseif ($goal === 'lose_weight') {
            $query->where('kalori', '<=', 500)
            ->where('protein', '>=', 15);
        }

        elseif ($goal === 'gain_weight') {
            $query->where('kalori', '>=', 600)
                ->where('protein', '>=', 20);
        }

        if ($goal === 'normal') {
            $query->orderByDesc('ratings_avg_nilai');
        }

        $data = $query->inRandomOrder()->limit(5)->get();

        return response()->json([
            'message' => 'Rekomendasi berhasil diambil',
            'goal' => $goal,
            'data' => $data
        ]);
    }
}
