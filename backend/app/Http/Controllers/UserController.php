<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Role;
use App\Models\HealthProfile;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function registerPembeli(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'no_telp' => 'required',
        ]);

        $role = Role::where('nama_role', 'pembeli')->first();

        if (!$role) {
            return response()->json([
                'message' => 'Role pembeli tidak ditemukan'
            ], 500);
        }

        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'no_telp' => $request->no_telp,
            'password' => Hash::make($request->password),
            'role_id' => $role->id
        ]);

        HealthProfile::create([
            'user_id' => $user->id,
            'berat' => 0,
            'tinggi' => 0,
            'umur' => 0,
            'jenis_kelamin' => '',
            'kalori' => 0,
            'protein' => 0,
            'lemak' => 0,
            'karbo' => 0,
        ]);

        return response()->json([
            'message' => 'Register berhasil',
            'data' => $user
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::with('role')->where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => $user
        ]);
    }

    public function uploadProfileImage(Request $request)
    {
        $request->validate([
            'profile' => 'required|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        $user = auth()->user();

        $image = $request->file('profile');

        $imageName = time() . '.' . $image->getClientOriginalExtension();

        $image->storeAs('profile', $imageName, 'public');

        $user->profile = "profile/" . $imageName;

        $user->save();

        return response()->json([
            'message' => 'Foto profile berhasil diupload',
            'data' => $user
        ]);
    }

    public function registerSeller(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'no_telp' => 'required',
        ]);

        $role = Role::where('nama_role', 'seller')->first();

        if (!$role) {
            return response()->json([
                'message' => 'Role seller tidak ditemukan'
            ], 500);
        }

        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'no_telp' => $request->no_telp,
            'password' => Hash::make($request->password),
            'role_id' => $role->id
        ]);

        return response()->json([
            'message' => 'Akun seller berhasil dibuat',
            'data' => $user
        ], 201);
    }

    public function registerAdmin(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'no_telp' => 'required',
        ]);

        $role = Role::where('nama_role', 'admin')->first();

        if (!$role) {
            return response()->json([
                'message' => 'Role admin tidak ditemukan'
            ], 500);
        }

        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'no_telp' => $request->no_telp,
            'password' => Hash::make($request->password),
            'role_id' => $role->id
        ]);

        return response()->json([
            'message' => 'Akun admin berhasil dibuat',
            'data' => $user
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }
}
