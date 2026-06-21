<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\User;
use App\Models\Makanan;

class DashboardController extends Controller
{
    public function statistik()
    {

        $totalSeller = User::whereHas('role', function ($q) {
            $q->where('nama_role', 'seller');
        })->count();

        $totalPembeli = User::whereHas('role', function ($q) {
            $q->where('nama_role', 'pembeli');
        })->count();


        $totalMakanan = Makanan::count();


        $pendapatanAdmin = Order::sum(
            'biaya_admin'
        );


        return response()->json([

            "data"=>[

                "total_seller"=>$totalSeller,

                "total_pembeli"=>$totalPembeli,

                "total_makanan"=>$totalMakanan,

                "pendapatan_admin"=>$pendapatanAdmin

            ]

        ]);

    }

    public function transaksiBulanan()
    {
        $data = Order::selectRaw(
            'MONTH(tanggal_transaksi) as bulan,
            COUNT(*) as jumlah'
        )
        ->whereYear(
            'tanggal_transaksi',
            now()->year
        )
        ->groupBy('bulan')
        ->orderBy('bulan')
        ->get();


        $namaBulan = [
            1 => "Januari",
            2 => "Februari",
            3 => "Maret",
            4 => "April",
            5 => "Mei",
            6 => "Juni",
            7 => "Juli",
            8 => "Agustus",
            9 => "September",
            10 => "Oktober",
            11 => "November",
            12 => "Desember"
        ];


        $hasil = [];


        for($i = 1; $i <= 12; $i++){

            $transaksi = $data->firstWhere(
                'bulan',
                $i
            );


            $hasil[] = [
                "nama_bulan" => $namaBulan[$i],
                "jumlah" => $transaksi 
                    ? $transaksi->jumlah 
                    : 0
            ];

        }


        return response()->json([
            "data"=>$hasil
        ]);
    }

    public function statusTransaksi()
    {

        $status = [
            "dibayar",
            "belumBayar",
            "gagal"
        ];


        $data = [];


        foreach($status as $item){

            $jumlah = Order::where(
                "status_transaksi",
                $item
            )->count();


            $data[] = [
                "status_transaksi"=>$item,
                "jumlah"=>$jumlah
            ];

        }


        return response()->json([
            "data"=>$data
        ]);

    }

    public function pendapatanAdmin()
    {

        $data = Order::selectRaw(
            'MONTH(tanggal_transaksi) as bulan,
            SUM(biaya_admin) as total'
        )
        ->whereYear(
            'tanggal_transaksi',
            now()->year
        )
        ->groupBy('bulan')
        ->pluck('total','bulan');


        $hasil=[];


        for($i=1;$i<=12;$i++){

            $hasil[]=[
                "bulan"=>$i,
                "total"=>$data[$i] ?? 0
            ];

        }


        return response()->json([
            "data"=>$hasil
        ]);

    }
}
