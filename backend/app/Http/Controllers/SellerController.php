<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Seller;

class SellerController extends Controller
{
    public function getProfile()
    {
        $seller = Seller::where('user_id', Auth::id())->first();

        return response()->json([
            'message' => "Profile toko berhasil diambil",
            'data' => $seller
        ]);
    }

    public function saveProfile(Request $request)
    {
        $seller = Seller::firstOrCreate([
            'user_id' => auth()->id()
        ]);

        $request->validate([
            'nama_toko' => 'nullable|string|max:255',
            'alamat' => 'nullable|string',
            'deskripsi' => 'nullable|string',
            'jam_buka' => 'nullable|string|max:20',
            'jam_tutup' => 'nullable|string|max:20',
        ]);

        if ($request->filled('nama_toko')) {
            $seller->nama_toko = $request->nama_toko;
        }

        if ($request->filled('alamat')) {
            $seller->alamat = $request->alamat;
        }

        if ($request->filled('deskripsi')) {
            $seller->deskripsi = $request->deskripsi;
        }

        if ($request->filled('jam_buka')) {
            $seller->jam_buka = $request->jam_buka;
        }

        if ($request->filled('jam_tutup')) {
            $seller->jam_tutup = $request->jam_tutup;
        }

        $seller->save();

        return response()->json([
            'message' => 'Profile seller berhasil diupdate',
            'data' => $seller
        ]);
    }

    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'foto_toko' => 'required|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        $seller = Seller::where('user_id', auth()->id())->first();

        $image = $request->file('foto_toko');

        $imageName = time() . '.' . $image->getClientOriginalExtension();

        $image->storeAs('profile', $imageName, 'public');

        $seller->foto_toko = "profile/" . $imageName;

        $seller->save();

        return response()->json([
            'message' => 'Foto profile berhasil diupload',
            'data' => $seller
        ]);
    }
}
