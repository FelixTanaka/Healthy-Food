import 'package:flutter/material.dart';
import 'package:mobile/Pages/allreviewpage.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailMenuPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const DetailMenuPage({
    super.key,
    required this.food,
  });

  @override
  State<DetailMenuPage> createState() =>
      _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  Future<void> tambahKeranjang({
    bool forceReplace = false,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/api/keranjang/tambah",
        ),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $token",
        },
        body: jsonEncode({
          "makanan_id":
              widget.food["id"],
          "jumlah": 1,
          "force_replace":
              forceReplace,
        }),
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: data["message"],
        );
      }

      else if (
          response.statusCode == 409 &&
          data["seller_berbeda"] ==
              true) {

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor:
                  Colors.white,

              title: const Text(
                "Seller Berbeda",
              ),

              content: const Text(
                "Keranjang Anda berisi produk dari toko lain.\n\nHapus keranjang lama dan ganti dengan produk baru?",
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Batal",
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.orange,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () async {

                    Navigator.pop(
                      context,
                    );

                    await tambahKeranjang(
                      forceReplace:
                          true,
                    );
                  },
                  child: const Text(
                    "Hapus & Ganti",
                  ),
                ),
              ],
            );
          },
        );
      }

      else {

        Fluttertoast.showToast(
          msg:
              data["message"] ??
              "Gagal tambah keranjang",
        );
      }

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rating =
    double.parse(
      (widget.food["ratings_avg_nilai"] ?? 0)
          .toString(),
    );

    final totalRating =
    widget.food["ratings_count"] ?? 0;
    final reviews =
    List<Map<String, dynamic>>.from(
      widget.food["ratings"] ?? [],
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    "${ApiService.baseUrl}/storage/${widget.food["gambar_makanan"]}",
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.food["nama_makanan"],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                     "Rp ${widget.food["harga"]}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [

                                  ...List.generate(5, (index) {

                                     if (index < rating.floor()) {

                                        return const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        );

                                      } else if (

                                        index < rating &&
                                        rating % 1 >= 0.5

                                      ) {

                                        return const Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }

                                      return const Icon(
                                        Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                  }),

                                  const SizedBox(width: 6),

                                  Text(

                                    totalRating == 0

                                        ? "Belum ada ulasan"

                                        : rating.toStringAsFixed(1),

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (totalRating != 0) ...[

                                    const SizedBox(width: 4),

                                    Text(
                                      "($totalRating)",

                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.1,
                                      ),

                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),

                                    child: Text(
                                      widget.food["kategori"]["nama_kategori"],

                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  CircleAvatar(
                                    radius: 12,

                                    backgroundImage: NetworkImage(
                                      "${ApiService.baseUrl}/storage/${widget.food["seller"]["foto_toko"]}",
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      widget.food["seller"]["nama_toko"],

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Informasi Nutrisi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildInfo(Icons.local_fire_department, "Kalori", "${widget.food["kalori"]} kcal", Colors.orange),
                                  buildInfo(Icons.set_meal, "Protein", "${widget.food["protein"]} g", Colors.blue),
                                  buildInfo(Icons.water_drop, "Lemak", "${widget.food["lemak"]} g", Colors.red),
                                  buildInfo(Icons.grain, "Karbo", "${widget.food["karbohidrat"]} g", Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Deskripsi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                widget.food["deskripsi"],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Ulasan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AllReviewsPage(reviews: List<Map<String, dynamic>>.from(widget.food["ratings"] ?? [],),),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Lihat semua",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Column(
                                children:  reviews.take(3).map((review) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,

                                          backgroundImage: NetworkImage(

                                            "${ApiService.baseUrl}/storage/${review["user"]["profile"]}",
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [

                                                  Row(
                                                    children: [

                                                      Text(
                                                        review['user']["username"],

                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      ...List.generate(5, (index) {

                                                        return Icon(
                                                          index < review["nilai"]

                                                              ? Icons.star

                                                              : Icons.star_border,

                                                          size: 14,
                                                          color: Colors.amber,
                                                        );
                                                      }),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 2),

                                                  Text(

                                                    review["tanggal_rating"] == null

                                                        ? "-"

                                                        : review["tanggal_rating"]
                                                            .toString(),

                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              const SizedBox(height: 4),
                                  
                                              Text(
                                                review["komentar"],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.4, 
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              tambahKeranjang();
                            },
                            child: const Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfo(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}