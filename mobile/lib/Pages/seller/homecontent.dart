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

  List<Map<String, dynamic>> filteredMenu = [];

  TextEditingController searchController = TextEditingController();

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


          filteredMenu =
              List<Map<String, dynamic>>.from(
                  data["data"]);

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

  void searchMenu(String value) {

    setState(() {

      filteredMenu =
          menuList.where((item) {

        final nama =
            item["nama_makanan"]
                .toString()
                .toLowerCase();

        final harga =
            item["harga"]
                .toString()
                .toLowerCase();

        final status =
            item["status"]
                .toString()
                .toLowerCase();

        final rating =

            item["ratings_avg_nilai"] == null

                ? "0"

                : double.parse(
                    item[
                      "ratings_avg_nilai"]
                      .toString(),
                  ).toStringAsFixed(1);

        final query =
            value.toLowerCase();

        return

            nama.contains(query) ||

            harga.contains(query) ||

            status.contains(query) ||

            rating.contains(query);
      }).toList();
    });
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
                    controller: searchController,
                     onChanged: searchMenu,
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
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final item = filteredMenu[index];

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
                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12),

                            child: Image.network(

                              "${ApiService.baseUrl}/storage/${item["gambar_makanan"]}",

                              width: 90,
                              height: 90,

                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  item["nama_makanan"],

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Rp ${item["harga"]}",

                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,

                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                buildStatusMenu(
                                  item["status"],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(

                                      item["ratings_avg_nilai"]
                                              == null

                                          ? "0.0"

                                          : double.parse(
                                              item[
                                                  "ratings_avg_nilai"]
                                                  .toString(),
                                            ).toStringAsFixed(1),

                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      "(${item["ratings_count"]})",

                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [

                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                ),

                                onPressed: () async {

                                  final result =
                                      await Navigator.push(

                                    context,

                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditMenuPage(
                                        item: item,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    getMenu();
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () {
                                  deleteMenu(item["id"]);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget buildStatusMenu(
    String status,
  ) {

    Color color;

    switch (status) {

      case "dikonfirmasi":
        color = Colors.green;
        break;

      case "pending":
        color = Colors.orange;
        break;

      case "ditolak":
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.1),

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}