import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/Pages/pembayaranberhasil.dart';
import 'package:mobile/Pages/pembayarangagal.dart';

class ConfirmTransaksiPage extends StatefulWidget {
  final Map<String, dynamic> selectedAddress;
  final List<Map<String, dynamic>> keranjang;
  final Map<String, dynamic> user;
  final int subtotal;
  final int biayaAdmin;

  const ConfirmTransaksiPage({
    super.key,
    required this.selectedAddress,
    required this.keranjang,
    required this.subtotal,
    required this.biayaAdmin,
    required this.user,
  });

  @override
  State<ConfirmTransaksiPage> createState() => ConfirmTransaksiPageState();
}

class ConfirmTransaksiPageState extends State<ConfirmTransaksiPage> {
  bool isLoading = false;
  int ongkir = 0;


  @override
  void initState() {
    super.initState();

    hitungOngkir();
  }

  Future<void> hitungOngkir() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/api/hitung-ongkir",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "latitude": widget.selectedAddress['latitude']
              .toString(),

          "longitude": widget.selectedAddress['longitude']
              .toString(),
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {
          ongkir = data['ongkir'] ?? 0;
        });

      } else {

        debugPrint(
          "Gagal hitung ongkir: ${response.body}",
        );

      }

    } catch (e) {

      debugPrint(
        "Error ongkir: $e",
      );

    }
  }

  Future<void> createInvoice() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    try {

      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          '${ApiService.baseUrl}/api/create-invoice',
        ),

        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'alamat_pengiriman': widget.selectedAddress['alamat'],
          "latitude":
              widget.selectedAddress["latitude"],

          "longitude":
              widget.selectedAddress["longitude"],

          "ongkir":
              ongkir,

        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final invoiceUrl = data['invoice_url'];
        final orderId = data['order_id'];

        await launchUrl(
          Uri.parse(invoiceUrl),
          mode: LaunchMode.externalApplication,
          
        );
      
        for (int i = 0; i < 20; i++) {

          await Future.delayed(
            const Duration(seconds: 3),
          );

          final status =
              await cekStatusPembayaran(orderId);

          if (status == 'dibayar') {

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const PembayaranBerhasilPage(),
              ),
            );

            break;
          }else if (status == 'gagal') {

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const PembayaranGagalPage(),
              ),
            );

            break;
          }
        }
      } else {

        debugPrint(data.toString());
      }

    } catch (e) {

      debugPrint(e.toString());
    }finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String> cekStatusPembayaran(
    int orderId,
  ) async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/api/cek-order/$orderId',
      ),

      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    return data['status_transaksi'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            buildSection(
              icon: Icons.person,
              title: "Penerima",
              content: "${widget.user['username']} - ${widget.user['no_telp']}",
            ),

            const SizedBox(height: 12),

            buildSection(
              icon: Icons.location_on,
              title: "Alamat Pengiriman",
              content: widget.selectedAddress['alamat'],
            ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.keranjang.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "${ApiService.baseUrl}/storage/${item['makanan']['gambar_makanan']}",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                "${item['jumlah']} x Rp ${item['makanan']['harga']}",
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Rp ${item['jumlah'] * item['makanan']['harga']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Subtotal"),
                    Text("Rp ${widget.subtotal}"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Biaya Admin"),
                    Text("Rp ${widget.biayaAdmin}"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ongkir"),
                    Text("Rp $ongkir"),
                  ],
                ),
                Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp ${widget.subtotal + widget.biayaAdmin + ongkir}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Pastikan data sudah benar sebelum melakukan pembayaran.",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
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
          onPressed: isLoading
              ? null
              : () {
                  createInvoice();
                },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),

          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  "Bayar Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}