<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatbotController extends Controller
{
    public function chat(Request $request)
    {
        $message = $request->message;

        $response = Http::post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" . env('GEMINI_API_KEY'),
            [
                "contents" => [
                    [
                        "parts" => [
                            [
                                "text" => "
                                    Kamu adalah AI assistant ahli healthy food dan nutrisi.

                                    Tugas kamu:
                                    - Menjawab pertanyaan tentang makanan sehat
                                    - Memberikan saran diet sehat
                                    - Memberikan tips nutrisi
                                    - Menjelaskan kalori makanan
                                    - Memberikan rekomendasi pola hidup sehat

                                    Aturan:
                                    - Jawab dengan bahasa Indonesia
                                    - Jawab dengan singkat, jelas, dan ramah
                                    - Fokus pada topik kesehatan dan nutrisi
                                    - Jika pertanyaan tidak berhubungan dengan kesehatan, arahkan kembali ke healthy food

                                    User: $message
                                "
                            ]
                        ]
                    ]
                ]
            ]
        );

        $reply = $response['candidates'][0]['content']['parts'][0]['text'];

        return response()->json([
            "reply" => $reply
        ]);
    }
}
