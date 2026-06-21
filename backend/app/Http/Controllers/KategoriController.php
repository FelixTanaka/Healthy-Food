<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Kategori;
use App\Models\Seller;
use Carbon\Carbon;

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

    public function store(Request $request)
    {
        $request->validate([
            'nama_kategori' => 'required|string|max:255',
        ]);

        $kategori = Kategori::create([
            'nama_kategori' => $request->nama_kategori,
        ]);

        return response()->json([
            'message' => 'Kategori berhasil ditambahkan',
            'data' => $kategori
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_kategori' => 'required|string|max:255',
        ]);

        $kategori = Kategori::find($id);

        if (!$kategori) {
            return response()->json([
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        $kategori->update([
            'nama_kategori' => $request->nama_kategori,
        ]);

        return response()->json([
            'message' => 'Kategori berhasil diupdate',
            'data' => $kategori
        ], 200);
    }

    public function destroy($id)
    {
        $kategori = Kategori::find($id);

        if (!$kategori) {
            return response()->json([
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        $kategori->delete();

        return response()->json([
            'message' => 'Kategori berhasil dihapus'
        ], 200);
    }

    public function laporanKategori(Request $request)
    {
        $seller = Seller::where('user_id', auth()->id())->first();

        if (!$seller) {
            return response()->json([
                'message' => 'Seller tidak ditemukan'
            ], 403);
        }

        $kategoriList = Kategori::with([
            'makanan' => function ($q) use ($seller) {
                $q->where('seller_id', $seller->id)
                ->where('status', 'dikonfirmasi');
            }
        ])->get();

        $laporan = $kategoriList->map(function ($kategori) use ($request) {

            $jumlahTerjual = 0;
            $totalPendapatan = 0;

            foreach ($kategori->makanan as $makanan) {

                $orderItems = $makanan->orderItems()
                    ->whereHas('order', function ($q) use ($request) {

                        $q->where('status_transaksi', 'dibayar');

                        if ($request->tanggal_mulai) {
                            $q->where('tanggal_transaksi', '>=',
                                Carbon::parse($request->tanggal_mulai)->startOfDay()
                            );
                        }

                        if ($request->tanggal_selesai) {
                            $q->where('tanggal_transaksi', '<=',
                                Carbon::parse($request->tanggal_selesai)->endOfDay()
                            );
                        }
                    })
                    ->get();

                foreach ($orderItems as $item) {
                    $jumlahTerjual += $item->jumlah;
                    $totalPendapatan += $item->jumlah * $item->makanan->harga;
                }
            }

            return [
                "kategori" => $kategori->nama_kategori,
                "jumlah_menu" => $kategori->makanan->count(),
                "jumlah_terjual" => $jumlahTerjual,
                "total_pendapatan" => $totalPendapatan,
            ];
        });

        return response()->json([
            "message" => "Laporan kategori berhasil",
            "data" => $laporan
        ]);
    }
}
