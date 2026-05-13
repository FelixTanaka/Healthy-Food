<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

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
}
