<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use Xendit\Configuration;
use Xendit\Invoice\InvoiceApi;
use Xendit\Invoice\CreateInvoiceRequest;

use App\Models\Keranjang;
use App\Models\KeranjangItem;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Seller;

use Barryvdh\DomPDF\Facade\Pdf;

class TransaksiController extends Controller
{
    public function createInvoice(Request $request)
    {
        $userId = auth()->id();

        $keranjang = Keranjang::where('user_id', $userId)
            ->where('status', 'Aktif')
            ->first();

        $items = KeranjangItem::with('makanan')
            ->where('keranjang_id', $keranjang->id)
            ->get();

        $totalHarga = 0;    

        foreach ($items as $item) {

            $totalHarga +=
                $item->jumlah * $item->makanan->harga;
        }

        $biayaAdmin = $totalHarga * 0.10;

        $grandTotal = $totalHarga + $biayaAdmin;

        $externalId = 'INV-' . time();

        $order = Order::create([
            'user_id' => $userId,
            'alamat_pengiriman' => $request->alamat_pengiriman,
            'total_harga' => $grandTotal,
            'biaya_admin' => $biayaAdmin,
            'status_transaksi' => 'belumBayar',
            'status_order' => 'menunggu_pembayaran',
            'external_id' => $externalId,
        ]);

        foreach ($items as $item) {

            OrderItem::create([
                'order_id' => $order->id,
                'makanan_id' => $item->makanan_id,
                'jumlah' => $item->jumlah,
            ]);
        }

        Configuration::setXenditKey(
            config('services.xendit.secret_key')
        );

        $apiInstance = new InvoiceApi();

        $InvoiceRequest = new CreateInvoiceRequest([
            'external_id' => $externalId,
            'amount' => $grandTotal,
            'description' => 'Pembayaran Order #' . $order->id,
            'invoice_duration' => 900
        ]);

        try {

            $result = $apiInstance->createInvoice($InvoiceRequest);

            return response()->json([
                'invoice_url' => $result['invoice_url'],
                'order_id' => $order->id,
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function xenditCallback(Request $request)
    {
        $externalId = $request->external_id;

        $status = $request->status;

        $order = Order::where(
            'external_id',
            $externalId
        )->first();

        if (!$order) {

            return response()->json([
                'message' => 'Order tidak ditemukan'
            ], 404);
        }

        if ($status == 'PAID') {

            $order->update([
                'status_transaksi' => 'dibayar',
                'tanggal_transaksi' => now(),
                'status_order' => 'diproses',
                'metode_transaksi' => $request->payment_method,
            ]);

            Keranjang::where(
                'user_id',
                $order->user_id
            )->where(
                'status',
                'Aktif'
            )->update([
                'status' => 'Checkout'
            ]);
        }else if($status == 'EXPIRED') {

            $order->update([
                'status_transaksi' => 'gagal',
                'status_order' => 'dibatalkan',
            ]);
        }

        return response()->json([
            'message' => 'Webhook berhasil'
        ]);
    }

    public function cekStatusOrder($id)
    {
        $order = Order::find($id);

        return response()->json([
            'status_transaksi' => $order->status_transaksi
        ]);
    }

    public function riwayatTransaksi()
    {
        $userId = auth()->id();

        $orders = Order::with(['orderItems.makanan.seller', 'user', 'orderItems.rating'])

            ->where(
                'user_id',
                $userId
            )
            ->where(
                'status_transaksi',
                'dibayar'
            )
        ->latest('id')
        ->get();

        $subtotal = 0;

        foreach ($orders as $order) {

            $subtotal = 0;

            foreach (
                $order->orderItems as $item
            ) {

                $subtotal +=
                    $item->jumlah *
                    $item->makanan->harga;
            }

            $order->subtotal = $subtotal;
        }

        return response()->json([
            'data' => $orders,
        ]);
    }

    public function pesananSeller()
    {
       
        $seller = Seller::where(
                    'user_id',
                    auth()->id()
                )->first();

        if (!$seller) {

            return response()->json([
                'message' => 'Seller tidak ditemukan'
            ], 404);
        }

        $orders = Order::with([
            'user',
            'orderItems.makanan',
        ])

        ->whereHas(
            'orderItems.makanan',
            function ($query) use ($seller) {

                $query->where(
                    'seller_id',
                    $seller->id
                );
            }
        )

        ->where(
            'status_transaksi',
            'dibayar'
        )

        ->latest('id')
        ->get();

        foreach ($orders as $order) {

            $subtotal = 0;
            $totalItem = 0;

            foreach (
                $order->orderItems as $item
            ) {

                if (
                    $item->makanan->seller_id
                    == $seller->id
                ) {

                    $subtotal +=
                        $item->jumlah *
                        $item->makanan->harga;

                    $totalItem +=
                        $item->jumlah;
                }
            }
            
            $biayaAdmin =
                $subtotal * 0.10;

            $order->subtotal_seller =
                $subtotal;

            $order->biaya_admin =
                $biayaAdmin;

            $order->total_item =
                $totalItem;
        }

        return response()->json([
            'data' => $orders
        ]);
    }

    public function pesananSelesai($id)
    {
        $seller = Seller::where(
            'user_id',
            auth()->id()
        )->first();

        if (!$seller) {

            return response()->json([
                'message' => 'Seller tidak ditemukan'
            ], 404);
        }

        $order = Order::whereHas(
            'orderItems.makanan',
            function ($query) use ($seller) {

                $query->where(
                    'seller_id',
                    $seller->id
                );
            }
        )

        ->find($id);

        if (!$order) {

            return response()->json([
                'message' => 'Pesanan tidak ditemukan'
            ], 404);
        }

        $order->update([
            'status_order' => 'selesai'
        ]);

        return response()->json([
            'message' => 'Pesanan selesai'
        ]);
    }

    public function transaksiAdmin()
    {
        $orders = Order::with([
            'user',
            'orderItems.makanan.seller'
        ])
        ->latest('id')
        ->get();


        foreach($orders as $order){

            $jumlahItem = 0;


            foreach($order->orderItems as $item){

                $jumlahItem += $item->jumlah;

            }


            $order->jumlah_item = $jumlahItem;

        }


        return response()->json([
            'data'=>$orders
        ]);
    }

    public function hapusTransaksi($id)
    {
        $order = Order::find($id);


        if(!$order){

            return response()->json([
                'message'=>'Transaksi tidak ditemukan'
            ],404);

        }


        OrderItem::where(
            'order_id',
            $order->id
        )->delete();

        $order->delete();

        return response()->json([
            'message'=>'Transaksi berhasil dihapus'
        ]);

    }

    public function laporanTransaksi(Request $request)
    {

        $query = Order::with([
            'user',
            'orderItems.makanan.seller'
        ]);


        if($request->tanggal_mulai){

            $query->whereDate(
                'tanggal_transaksi',
                '>=',
                $request->tanggal_mulai
            );

        }


        if($request->tanggal_selesai){

            $query->whereDate(
                'tanggal_transaksi',
                '<=',
                $request->tanggal_selesai
            );

        }


        if($request->status_transaksi){

            $query->where(
                'status_transaksi',
                $request->status_transaksi
            );

        }

        $orders = $query->latest('id')->get();

        $orders->transform(function ($order) {
            $order->jumlah_item = $order->orderItems->sum('jumlah');
            return $order;
        });


        return response()->json([
            "data"=>$orders
        ]);

    }
}
