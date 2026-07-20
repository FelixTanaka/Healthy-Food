import 'package:flutter/material.dart';
import 'package:mobile/Pages/detailmenupage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> foods = [];
  List<dynamic> filteredFoods = [];

  @override
  void initState() {
    super.initState();
    getFoods();
  }

  Future<void> getFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/makanan-pembeli"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        setState(() {
          foods = data["data"];
          filteredFoods = data["data"];
        });

      } else {
        debugPrint("Gagal ambil makanan");
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void cariMakanan(String keyword) {

    setState(() {

      filteredFoods = foods.where((food) {

        final namaMakanan =
            food["nama_makanan"]
                .toString()
                .toLowerCase();

        final kategori =
            food["kategori"]["nama_kategori"]
                .toString()
                .toLowerCase();

        final namaToko =
            food["seller"]["nama_toko"]
                .toString()
                .toLowerCase();

        final harga =
            food["harga"]
                .toString();

        final rating =
            (food["ratings_avg_nilai"] ?? 0)
                .toString();

        final search =
            keyword.toLowerCase();

        return

            namaMakanan.contains(search)

            ||

            kategori.contains(search)

            ||

            namaToko.contains(search)

            ||

            harga.contains(search)

            ||

            rating.contains(search);
      }).toList();
    });
  }

  Future<void> tambahKeranjang(
    int makananId, {
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
          "Authorization":
              "Bearer $token",
        },
        body: {
          "makanan_id":
              makananId.toString(),
          "jumlah": "1",
          "force_replace":
              forceReplace
                  ? "1"
                  : "0",
        },
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
              backgroundColor: Colors.white,
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
                      makananId,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: cariMakanan,
              decoration: InputDecoration(
                hintText: "Cari makanan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: filteredFoods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, 
              ),
              itemBuilder: (context, index) {
                final food = filteredFoods[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailMenuPage(food: food),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                             "${ApiService.baseUrl}/storage/${food["gambar_makanan"]}",
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food["nama_makanan"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  food["kategori"]["nama_kategori"],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [

                                  CircleAvatar(
                                    radius: 12,

                                    backgroundImage: NetworkImage(
                                      "${ApiService.baseUrl}/storage/${food["seller"]["foto_toko"]}",
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      food["seller"]["nama_toko"],

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [

                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(

                                    food["ratings_count"] == 0

                                        ? "Belum ada ulasan"

                                        : "${double.parse(food["ratings_avg_nilai"].toString()).toStringAsFixed(1)} (${food["ratings_count"] ?? 0})",

                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10),

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              Text(
                                "Rp ${NumberFormat('#,##0', 'id_ID').format(food["harga"])}",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  tambahKeranjang(food["id"]);
                                },

                                child: const Icon(
                                  Icons.add_circle,
                                  color: Colors.orange,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}