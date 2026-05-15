import 'package:flutter/material.dart';
import 'package:mobile/Pages/seller/detailmenupage.dart';
import 'package:mobile/Pages/seller/addmenupage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/Pages/seller/editmenupage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> menuList = [];

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  Future<void> getMenu() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/makanan"),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
         debugPrint(response.body);

        final data = jsonDecode(response.body);

        setState(() {

          menuList = List<Map<String, dynamic>>.from(data["data"]);

        });

      } else {

        debugPrint(response.body);

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> deleteMenu(int id) async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString("token");

      final response = await http.delete(

        Uri.parse(
          "${ApiService.baseUrl}/api/makanan/$id",
        ),

        headers: {

          "Accept": "application/json",

          "Authorization": "Bearer $token",

        },
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(

          msg: data["message"],

        );

        getMenu();

      } else {

        Fluttertoast.showToast(

          msg: "Gagal hapus menu",

        );

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari menu...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMenuPage(),
                      ),
                    );
                    if (result == true) {
                      getMenu();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                final item = menuList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailMenuPage(item: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            "${ApiService.baseUrl}/storage/${item["gambar_makanan"]}",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nama_makanan"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Rp ${item["harga"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 3),

                                  Text(
                                    "4.5",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    item["status"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result =  await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMenuPage(item: item),
                              ),
                            );

                            if (result == true) {
                              getMenu();
                            }
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteMenu(item["id"]);
                          },
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