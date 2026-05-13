<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HealthProfile;

class HealthProfileController extends Controller
{
    public function getProfile()
    {
        $health = HealthProfile::where('user_id', auth()->id())->first();

        if (!$health) {
            return response()->json([
                'message' => 'Health profile tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'message' => 'Berhasil mengambil health profile',
            'data' => $health
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'berat' => 'nullable|numeric',
            'tinggi' => 'nullable|numeric',
            'umur' => 'nullable|numeric',
            'jenis_kelamin' => 'nullable|in:male,female',
        ]);

        $health = HealthProfile::where('user_id', auth()->id())->first();

        if ($request->filled('berat')) {
            $health->berat = $request->berat;
        }

        if ($request->filled('tinggi')) {
            $health->tinggi = $request->tinggi;
        }

        if ($request->filled('umur')) {
            $health->umur = $request->umur;
        }

        if ($request->filled('jenis_kelamin')) {
            $health->jenis_kelamin = $request->jenis_kelamin;
        }

        $berat = $health->berat;
        $tinggi = $health->tinggi;
        $umur = $health->umur;
        $gender = $health->jenis_kelamin;

        if($berat > 0 && $tinggi > 0 && $umur > 0 && $gender) {
           if ($gender == 'male') {
                $bmr = (10 * $berat) + (6.25 * $tinggi) - (5 * $umur) + 5;
            } else {
                $bmr = (10 * $berat) + (6.25 * $tinggi) - (5 * $umur) - 161;
            }

            $kalori = $bmr * 1.2;

            $protein = ($kalori * 0.30) / 4;
            $lemak = ($kalori * 0.25) / 9;
            $karbo = ($kalori * 0.45) / 4;
        }

        $health->update([
            'berat' => $berat,
            'tinggi' => $tinggi,
            'umur' => $umur,
            'jenis_kelamin' => $gender,

            'kalori' => round($kalori),
            'protein' => round($protein, 2),
            'lemak' => round($lemak, 2),
            'karbo' => round($karbo, 2),
        ]);

        return response()->json([
            'message' => 'Health profile berhasil diupdate',
            'data' => $health
        ]);
    }
}
