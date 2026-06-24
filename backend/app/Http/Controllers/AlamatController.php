<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Alamat;

class AlamatController extends Controller
{
    public function index()
    {
        $alamat = Alamat::where('user_id', auth()->id())->get();

        return response()->json([
            'message' => 'Data alamat berhasil diambil',
            'data' => $alamat
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'alamat' => 'required|string',
            'latitude' => 'nullable',
            'longitude' => 'nullable',
        ]);

        $alamat = Alamat::create([
            'user_id' => auth()->id(),
            'alamat' => $request->alamat,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return response()->json([
            'message' => 'Alamat berhasil ditambahkan',
            'data' => $alamat
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $alamat = Alamat::where('user_id', auth()->id())->findOrFail($id);

        $request->validate([
            'alamat' => 'required|string',
            'latitude' => 'nullable',
            'longitude' => 'nullable',
        ]);

        $alamat->alamat = $request->alamat;
        $alamat->latitude = $request->latitude;
        $alamat->longitude = $request->longitude;

        $alamat->save();

        return response()->json([
            'message' => 'Alamat berhasil diupdate',
            'data' => $alamat
        ]);
    }

    public function destroy($id)
    {
        $alamat = Alamat::where('user_id', auth()->id())->findOrFail($id);

        $alamat->delete();

        return response()->json([
            'message' => 'Alamat berhasil dihapus'
        ]);
    }
}
