<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Rating;
use App\Models\OrderItem;

class RatingController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([

            'order_item_id' => 'required|exists:order_item,id',

            'nilai' => 'required|integer|min:1|max:5',

            'komentar' => 'required',
        ]);

        $userId = auth()->id();

        $orderItem = OrderItem::with('makanan')
            ->find($request->order_item_id);

        $sudahReview = Rating::where(
            'order_item_id',
            $request->order_item_id
        )->exists();

        if ($sudahReview) {

            return response()->json([

                'message' =>
                    'Makanan sudah diulas',
            ], 400);
        }

        $rating = Rating::create([

            'user_id' => $userId,

            'makanan_id' =>
                $orderItem->makanan_id,

            'order_item_id' =>
                $request->order_item_id,

            'nilai' =>
                $request->nilai,

            'komentar' =>
                $request->komentar,
        ]);

        return response()->json([
            'message' => 'Ulasan berhasil dikirim',
            'data' => $rating,
        ]);
    }
}
