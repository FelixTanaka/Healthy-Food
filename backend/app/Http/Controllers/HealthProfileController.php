<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HealthProfile;
use Illuminate\Support\Facades\Auth;

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
            'activity_level' => 'nullable|in:sangat_ringan,ringan,sedang,berat,sangat_berat',
        ]);

        $health = HealthProfile::where('user_id', auth()->id())->first();

        if ($request->filled('berat') && $request->berat <= 0) {
            return response()->json([
                'message' => 'Berat badan tidak boleh kurang dari atau sama dengan 0'
            ], 422);
        }

        if ($request->filled('tinggi') && $request->tinggi <= 0) {
            return response()->json([
                'message' => 'Tinggi badan tidak boleh kurang dari atau sama dengan 0'
            ], 422);
        }

        if ($request->filled('umur') && $request->umur <= 0) {
            return response()->json([
                'message' => 'Umur tidak boleh kurang dari atau sama dengan 0'
            ], 422);
        }

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

        if ($request->filled('activity_level')) {
            $health->activity_level = $request->activity_level;
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

            if ($health->activity_level == 'sangat_ringan') {
                $kalori = $bmr * 1.2;
            } elseif ($health->activity_level == 'ringan') {
                $kalori = $bmr * 1.375;
            } elseif ($health->activity_level == 'sedang') {
                $kalori = $bmr * 1.55;
            } elseif ($health->activity_level == 'berat') {
                $kalori = $bmr * 1.725;
            } elseif ($health->activity_level == 'sangat_berat') {
                $kalori = $bmr * 1.9;
            } else {
                $kalori = $bmr * 1.2;
            }

            $protein = ($kalori * 0.30) / 4;
            $lemak = ($kalori * 0.25) / 9;
            $karbo = ($kalori * 0.45) / 4;
        }

        $health->update([
            'berat' => $berat,
            'tinggi' => $tinggi,
            'umur' => $umur,
            'jenis_kelamin' => $gender,
            'activity_level' => $health->activity_level,

            'kalori' => round($kalori),
            'protein' => round($protein, 2),
            'lemak' => round($lemak, 2),
            'karbo' => round($karbo, 2),
        ]);

        return response()->json([
            'message' => 'Health profile berhasil disimpan',
            'data' => $health
        ]);
    }

    public function getBeratUser(Request $request)
    {
        $user = Auth::user();

        $health = HealthProfile::where('user_id', $user->id)->first();

        if (!$health) {
            return response()->json([
                'message' => 'Data health profile tidak ditemukan',
                'berat' => null
            ], 404);
        }

        return response()->json([
            'message' => 'Berat user berhasil diambil',
            'berat' => $health->berat
        ]);
    }
}
