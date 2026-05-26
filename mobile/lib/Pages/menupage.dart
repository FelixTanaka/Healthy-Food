import 'package:flutter/material.dart';
import 'package:mobile/Pages/detailmenupage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> foods = [];

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
        });

      } else {
        debugPrint("Gagal ambil makanan");
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> tambahKeranjang(int makananId) async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/keranjang/tambah"),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },

        body: {
          "makanan_id": makananId.toString(),
          "jumlah": "1",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: data["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

      } else {

        Fluttertoast.showToast(
          msg: "Gagal tambah keranjang",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

      }

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
              itemCount: foods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, 
              ),
              itemBuilder: (context, index) {
                final food = foods[index];

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
                                    "5",
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
                                "Rp ${food["harga"]}",
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