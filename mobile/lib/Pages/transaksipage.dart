import 'package:flutter/material.dart';
import 'package:mobile/Pages/confirmtransaksipage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/Pages/alamatpage.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? selectedAddress;
  List<Map<String, dynamic>> keranjang = [];
  Map<String, dynamic>? user;
  int biayaAdmin = 0;
  int subtotal = 0;

  @override
  void initState() {
    super.initState();
    getAlamat();
    getKeranjang();
  }

  Future<void> getAlamat() async {
    try {
      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/alamat'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          addresses =  List<Map<String, dynamic>>.from(data['data']);

          if (addresses.isNotEmpty) {
            selectedAddress = addresses[0];
          }
        });
      } else {
        debugPrint(data.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getKeranjang() async {
    try {
      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/keranjang'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final items =
            List<Map<String, dynamic>>.from(
                data['data']);

        int total = data['total_harga'];

        int admin = (total * 0.10).toInt();

        setState(() {
          keranjang = items;
          subtotal = total;
          biayaAdmin = admin;
          user = data['user'];
        });

      } else {
        debugPrint(data.toString());
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
        title: const Text("Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          "Pilih Alamat",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        ...addresses.map((addr) {
                          final isSelected =
                            selectedAddress != null &&
                            addr['id'] == selectedAddress!['id'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: ListTile(
                              title: Text(addr['alamat']),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.orange)
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedAddress = addr;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.orange),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Alamat Pengiriman",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addresses.isEmpty
                              ? "Belum ada alamat"
                              : selectedAddress?['alamat'] ?? "",
                        )
                      ],
                    ),
                  ),

                  const Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [

                ...keranjang.map((item) {

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [

                        Image.network(
                          "${ApiService.baseUrl}/storage/${item["makanan"]["gambar_makanan"]}",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                item['makanan']['seller']['nama_toko'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Text(
                                item['makanan']['nama_makanan'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${item['jumlah']} x Rp ${item['makanan']['harga']}',
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'Rp ${item['jumlah'] * item['makanan']['harga']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text("Rp $subtotal"),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Biaya Admin"),
                    Text("Rp $biayaAdmin"),
                  ],
                ),

                const Divider(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Rp ${subtotal + biayaAdmin}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        child: ElevatedButton(
          onPressed: () {

            if (addresses.isEmpty) {

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,

                    title: const Text(
                      "Alamat Belum Ada",
                    ),

                    content: const Text(
                      "Silakan tambahkan alamat terlebih dahulu sebelum melakukan checkout.",
                    ),

                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Batal",
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {

                          Navigator.pop(context);

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlamatPage(),
                            ),
                          );

                          if (result == true) {
                            getAlamat(); 
                          }
                        },
                        child: const Text(
                          "Tambah Alamat",
                        ),
                      ),
                    ],
                  );
                },
              );

              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmTransaksiPage(
                  selectedAddress: selectedAddress!,
                  keranjang: keranjang,
                  subtotal: subtotal,
                  biayaAdmin: biayaAdmin,
                  user: user!,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Lanjut ke Pembayaran",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

