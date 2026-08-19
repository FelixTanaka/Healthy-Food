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

        $bahan = json_decode(
            $request->bahan,
            true
        );

        $ingredientList = [];

        foreach ($bahan as $item) {

            if (
                empty($item['nama_inggris'])||
                empty($item['unit']) ||
                empty($item['amount'])
            ) {

                return response()->json([
                    'message' => 'Semua bahan harus diisi',
                ], 422);

            }

            if ($item['amount'] <= 0) {

                return response()->json([
                    'message' => 'Jumlah bahan harus lebih dari 0',
                ], 422);

            }

            $ingredientList[] =
                $item['amount'] . ' ' .
                $item['unit'] . ' ' .
                $item['nama_inggris'];
        }

        $ingredientText = implode(
            "\n",
            $ingredientList
        );

        $response = Http::asForm()->post(
            'https://api.spoonacular.com/recipes/parseIngredients?includeNutrition=true&apiKey=' . env('SPOONACULAR_API_KEY'),
            [
                'ingredientList' => $ingredientText,

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

            $bahan = json_decode(
                $request->bahan,
                true
            );

            $ingredientList = [];

            foreach ($bahan as $item) {

                if (
                    empty($item['nama_inggris']) ||
                    empty($item['unit']) ||
                    empty($item['amount'])
                ) {

                    return response()->json([
                        'message' => 'Semua bahan harus diisi'
                    ], 422);

                }

                if ($item['amount'] <= 0) {

                    return response()->json([
                        'message' => 'Jumlah bahan harus lebih dari 0'
                    ], 422);

                }

                $ingredientList[] =
                    $item['amount'] . ' ' .
                    $item['unit'] . ' ' .
                    $item['nama_inggris'];
            }

            $ingredientText = implode(
                "\n",
                $ingredientList
            );

            $response = Http::asForm()->post(
                'https://api.spoonacular.com/recipes/parseIngredients?includeNutrition=true&apiKey=' . env('SPOONACULAR_API_KEY'),
                [
                    'ingredientList' => $ingredientText,
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

            $bahanSimpan = [];

            foreach ($bahan as $item) {

                $bahanSimpan[] = [
                    'nama_indonesia' =>
                        $item['nama_indonesia'],

                    'nama_inggris' =>
                        $item['nama_inggris'],

                    'spoonacular_id' =>
                        $item['spoonacular_id'],

                    'amount' =>
                        $item['amount'],

                    'unit' =>
                        $item['unit'],
                ];
            }

            $makanan->bahan =
                json_encode($bahanSimpan);
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

        $profile = $user->healthProfile;

        $foods = Makanan::with(['kategori', 'seller', 'ratings.user'])
            ->withAvg('ratings', 'nilai')
            ->withCount('ratings')
            ->get();    

        $foodList = $foods->map(function ($food) {
            return [
                'id' => $food->id,
                'nama' => $food->nama_makanan,
                'deskripsi' => $food->deskripsi,
                'harga' => $food->harga,
                'kalori' => $food->kalori,
                'protein' => $food->protein,
                'lemak' => $food->lemak,
                'karbohidrat' => $food->karbohidrat,
            ];
        });

        $prompt = "
            Kamu adalah ahli nutrisi.

            Profil pengguna:

            Umur: {$profile->umur}
            Jenis Kelamin: {$profile->jenis_kelamin}
            Berat: {$profile->berat}
            Tinggi: {$profile->tinggi}
            Aktivitas Fisik: {$profile->activity_level}

            Target Kalori: {$profile->kalori}
            Target Protein: {$profile->protein}
            Target Lemak: {$profile->lemak}
            Target Karbohidrat: {$profile->karbo}

            Daftar makanan:

            " . json_encode($foodList, JSON_PRETTY_PRINT) . "

            Pilih 5 makanan terbaik.

            Pertimbangkan:
            - Kedekatan kandungan kalori dengan target kalori pengguna.
            - Kedekatan kandungan protein dengan target protein pengguna.
            - Kedekatan kandungan lemak dengan target lemak pengguna.
            - Kedekatan kandungan karbohidrat dengan target karbohidrat pengguna.
            - Rating makanan.

            Aturan:

            1. Pilih tepat 5 makanan terbaik.
            2. Prioritaskan makanan yang paling mendekati target kalori, protein, lemak, dan karbohidrat pengguna.
            3. Pertimbangkan target kalori, protein, lemak, dan karbohidrat.
            4. Jangan memilih makanan yang sama dua kali.
            5. Jangan membuat ID baru.
            6. Gunakan hanya ID yang ada pada daftar makanan.
            7. Kembalikan HANYA JSON tanpa markdown.
            8. Reason maksimal 25 kata.
            9. Setiap reason HARUS berbeda untuk setiap makanan.
            10. Jelaskan alasan berdasarkan keunggulan masing-masing makanan, misalnya kandungan protein, kalori, lemak sehat, karbohidrat, atau harga.
            11. Jangan mengulang kalimat atau alasan yang sama pada lebih dari satu makanan.
            12. Jangan tambahkan penjelasan lain selain JSON.

            Jawab HANYA dalam format JSON seperti berikut:

            [
            {
            \"id\":1,
            \"reason\":\"...\"
            }
            ]
        ";

        $response = Http::post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=" . env('GEMINI_API_KEY'),
            [
                "contents" => [
                    [
                        "parts" => [
                            [
                                "text" => $prompt
                            ]
                        ]
                    ]
                ]
            ]
        );

        if (!$response->successful()) {

            return response()->json([
                "message"=>"Gemini gagal."
            ],500);

        }

        $reply = $response['candidates'][0]['content']['parts'][0]['text'];

        $reply = str_replace("```json", "", $reply);
        $reply = str_replace("```", "", $reply);
        $reply = trim($reply);

        $result = json_decode($reply, true);

        if (!$result || !is_array($result)) {

            return response()->json([
                "message" => "Format jawaban Gemini tidak valid.",
                "reply" => $reply
            ], 500);
        }
        
        $result = collect($result)
            ->unique('id')
            ->values()
            ->toArray();

        $ids = collect($result)->pluck('id')->toArray();

        $foods = Makanan::with(['kategori', 'seller', 'ratings.user'])
            ->withAvg('ratings', 'nilai')
            ->withCount('ratings')
            ->whereIn('id', $ids)
            ->get()
            ->keyBy('id');

        $data = [];

        foreach ($result as $item) {

            if (!isset($foods[$item['id']])) {
                continue;
            }

            $food = $foods[$item['id']];

            $food->ai_reason = $item['reason'];

            $data[] = $food;
        }    

        return response()->json([
            'message' => 'Rekomendasi berhasil diambil',
            "generated_by" => "Gemini 2.5 Flash",
            'data' => $data
        ]);
    }

    public function cariBahan(Request $request)
    {
        $request->validate([
            'query' => 'required'
        ]);

        $translator = new GoogleTranslate('en');

        $keywordInggris = $translator->translate(
            $request->query
        );

        $response = Http::get(
            'https://api.spoonacular.com/food/ingredients/search',
            [
                'query' => $keywordInggris,
                'number' => 10,
                'apiKey' => env('SPOONACULAR_API_KEY')
            ]
        );

        return response()->json(
            $response->json()
        );
    }

    public function searchIngredients(Request $request)
    {
        $keyword = strtolower($request->q);

        $ingredients = json_decode(
            file_get_contents(
                storage_path('app/public/ingredients_id.json')
            ),
            true
        );

        $result = collect($ingredients)
            ->filter(function ($item) use ($keyword) {

                return str_contains(
                    strtolower($item['nama_indonesia']),
                    $keyword
                );

            })
            ->take(20)
            ->values();

        return response()->json([
            'data' => $result
        ]);
    }

    public function units($id)
    {
        $response = Http::get(
            "https://api.spoonacular.com/food/ingredients/$id/information",
            [
                'apiKey' => env('SPOONACULAR_API_KEY'),
                'amount' => 1,
            ]
        );

        return response()->json([
            'data' =>
                $response->json()['possibleUnits']
        ]);
    }
}
