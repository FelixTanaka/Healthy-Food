<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\OrderItem;

class PembeliController extends Controller
{
    public function getProfile()
    {
        $user = auth()->user();

        return response()->json([
            'message' => 'Data profile berhasil diambil',
            'data' => $user
        ]);
    }
    
    public function updateProfile(Request $request)
    {
        $user = auth()->user();

        $request->validate([
            'username' => 'nullable|string|max:255',
            'email' => 'nullable|email',
            'no_telp' => 'nullable|string|max:20',
            'password' => 'nullable|min:6',
        ]);

        if ($request->filled('username')) {
            $user->username = $request->username;
        }

        if ($request->filled('email')) {
            $user->email = $request->email;
        }

        if ($request->filled('no_telp')) {
            $user->no_telp = $request->no_telp;
        }

        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json([
            'message' => 'Profile berhasil diupdate',
            'data' => $user
        ]);
    }

    public function nutrisiHarian()
    {
        $userId = auth()->id();

        $items = OrderItem::with(
            'makanan',
            'order'
        )
        ->whereHas('order', function ($query) use ($userId) {

            $query->where(
                'user_id',
                $userId
            )
            ->where(
                'status_transaksi',
                'dibayar'
            )
            ->where(
                'status_order',
                'selesai'
            )
            ->whereDate(
                'tanggal_transaksi',
                today()
            );
        })
        ->get();

        $kalori = 0;
        $protein = 0;
        $karbo = 0;
        $lemak = 0;

        foreach ($items as $item) {

            $kalori +=
                $item->makanan->kalori
                * $item->jumlah;

            $protein +=
                $item->makanan->protein
                * $item->jumlah;

            $karbo +=
                $item->makanan->karbohidrat
                * $item->jumlah;

            $lemak +=
                $item->makanan->lemak
                * $item->jumlah;
        }

        return response()->json([
            'kalori' => round($kalori, 2),
            'protein' => round($protein, 2),
            'karbo' => round($karbo, 2),
            'lemak' => round($lemak, 2),
        ]);
    }
}
