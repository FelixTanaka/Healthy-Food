import 'package:flutter/material.dart';
import 'package:mobile/Pages/transaksipage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  List<dynamic> keranjang = [];

  int totalHarga = 0;

  @override
  void initState() {
    super.initState();

    getKeranjang();
  }

  Future<void> getKeranjang() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/keranjang"),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        setState(() {

          keranjang = data["data"];

          totalHarga = data["total_harga"];
        });
      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> tambahJumlah(int id) async {

    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    await http.post(
      Uri.parse("${ApiService.baseUrl}/api/keranjang/tambah-jumlah/$id"),

      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    getKeranjang();
  }

  Future<void> kurangJumlah(int id) async {

    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    await http.post(
      Uri.parse("${ApiService.baseUrl}/api/keranjang/kurang-jumlah/$id"),

      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    getKeranjang();
  }

  Future<void> hapusKeranjang() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse("${ApiService.baseUrl}/api/keranjang/hapus"),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: data["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        getKeranjang();
      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              hapusKeranjang();
            },
          ),
        ],
      ),
      body: keranjang.isEmpty
      ? const Center(
          child: Text("Keranjang kosong"),
        )
      : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: keranjang.length,
        itemBuilder: (context, index) {

          final item = keranjang[index];

          return Container(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(bottom: 12),
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
                    "${ApiService.baseUrl}/storage/${item["makanan"]["gambar_makanan"]}",
                    width: 70,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                item["makanan"]["nama_makanan"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                 NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(item["makanan"]["harga"]),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: InkWell(
                                onTap: () {
                                  kurangJumlah(item["id"]);
                                },
                                child: const Icon(
                                  Icons.remove,
                                  size: 16,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "${item["jumlah"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: InkWell(
                                onTap: () {
                                  tambahJumlah(item["id"]);
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalHarga),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: keranjang.isEmpty ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransaksiPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}