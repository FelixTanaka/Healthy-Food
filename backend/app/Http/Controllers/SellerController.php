<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Seller;
use App\Models\User;

class SellerController extends Controller
{
    public function getProfile()
    {
        $seller = Seller::with('user')
            ->where(
                'user_id',
                auth()->id()
            )
            ->first();

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

        $user = auth()->user();

        $request->validate([
            'username' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'no_telp' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:6',
            'nama_toko' => 'nullable|string|max:255',
            'alamat' => 'nullable|string',
            'deskripsi' => 'nullable|string',
            'jam_buka' => 'nullable|string|max:20',
            'jam_tutup' => 'nullable|string|max:20',
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
            $user->password = bcrypt($request->password);
        }

        $user->save();

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
            'user' => $user,
            'seller' => $seller,
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

    public function index()
    {
        $sellers = Seller::with('user')
            ->withCount([
                'makanan as makanan_count' => function ($query) {
                    $query->where('status', 'dikonfirmasi');
                }
            ])
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'message' => 'Daftar seller berhasil diambil',
            'data' => $sellers
        ]);
    }

    public function updateSeller(Request $request, $id)
    {
        $seller = Seller::find($id);

        if (!$seller) {
            return response()->json([
                'message' => 'Seller tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama_toko' => 'nullable|string|max:255',
            'alamat' => 'nullable|string',
            'jam_buka' => 'nullable|string|max:20',
            'jam_tutup' => 'nullable|string|max:20',
            'deskripsi' => 'nullable|string',
        ]);

        if ($request->filled('nama_toko')) {
            $seller->nama_toko = $request->nama_toko;
        }

        if ($request->filled('alamat')) {
            $seller->alamat = $request->alamat;
        }

        if ($request->filled('jam_buka')) {
            $seller->jam_buka = $request->jam_buka;
        }

        if ($request->filled('jam_tutup')) {
            $seller->jam_tutup = $request->jam_tutup;
        }

        if ($request->filled('deskripsi')) {
            $seller->deskripsi = $request->deskripsi;
        }

        $seller->save();

        return response()->json([
            'message' => 'Seller berhasil diupdate',
            'data' => $seller
        ], 200);
    }

    public function destroy($id)
    {
        $seller = Seller::find($id);

        if (!$seller) {
            return response()->json([
                'message' => 'Seller tidak ditemukan'
            ], 404);
        }

        $seller->delete();

        return response()->json([
            'message' => 'Seller berhasil dihapus'
        ], 200);
    }
}
