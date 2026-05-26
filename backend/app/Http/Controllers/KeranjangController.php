<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Keranjang;
use App\Models\KeranjangItem;

class KeranjangController extends Controller
{
    public function tambahKeranjang(Request $request)
    {
        $request->validate([
            'makanan_id' => 'required',
            'jumlah' => 'required|integer|min:1',
        ]);

        $userId = auth()->id();

        $keranjang = Keranjang::where('user_id', $userId)
            ->where('status', 'Aktif')
            ->first();

        if (!$keranjang) {

            $keranjang = Keranjang::create([
                'user_id' => $userId,
                'status' => 'Aktif',
            ]);
        }

        $item = KeranjangItem::where('keranjang_id', $keranjang->id)
            ->where('makanan_id', $request->makanan_id)
            ->first();

        if ($item) {

            $item->jumlah += $request->jumlah;
            $item->save();

        } else {

            KeranjangItem::create([
                'keranjang_id' => $keranjang->id,
                'makanan_id' => $request->makanan_id,
                'jumlah' => $request->jumlah,
            ]);
        }

        return response()->json([
            'message' => 'Berhasil tambah ke keranjang'
        ]);
    }

    public function tampilKeranjang()
    {
        $userId = auth()->id();

        $keranjang = Keranjang::where('user_id', $userId)
            ->where('status', 'Aktif')
            ->first();

        if (!$keranjang) {

            return response()->json([
                'data' => [],
                'total_harga' => 0
            ]);
        }

        $items = KeranjangItem::with('makanan', 'makanan.seller')
            ->where('keranjang_id', $keranjang->id)
            ->get();

        $totalHarga = 0;

        foreach ($items as $item) {

            $totalHarga += $item->jumlah * $item->makanan->harga;
        }

        return response()->json([
            'data' => $items,
            'total_harga' => $totalHarga,
            'user' => auth()->user()
        ]);
    }

    public function tambahJumlah($id)
    {
        $item = KeranjangItem::find($id);

        if (!$item) {

            return response()->json([
                'message' => 'Item tidak ditemukan'
            ], 404);
        }

        $item->jumlah += 1;

        $item->save();

        return response()->json([
            'message' => 'Jumlah berhasil ditambah'
        ]);
    }

    public function kurangJumlah($id)
    {
        $item = KeranjangItem::find($id);

        if (!$item) {

            return response()->json([
                'message' => 'Item tidak ditemukan'
            ], 404);
        }

        if ($item->jumlah <= 1) {

            $item->delete();

            return response()->json([
                'message' => 'Item dihapus dari keranjang'
            ]);
        }

        $item->jumlah -= 1;

        $item->save();

        return response()->json([
            'message' => 'Jumlah berhasil dikurangi'
        ]);
    }

    public function hapusKeranjang()
    {
        $userId = auth()->id();

        $keranjang = Keranjang::where('user_id', $userId)
            ->where('status', 'Aktif')
            ->first();

        if (!$keranjang) {

            return response()->json([
                'message' => 'Keranjang kosong'
            ]);
        }

        KeranjangItem::where('keranjang_id', $keranjang->id)
            ->delete();

        $keranjang->delete();

        return response()->json([
            'message' => 'Keranjang berhasil dikosongkan'
        ]);
    }
}
