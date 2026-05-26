import 'package:flutter/material.dart';
import 'package:mobile/Pages/detailriwayatpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => RiwayatPageState();
}

class RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> transaksi = [];

  @override
  void initState() {
    super.initState();
    getRiwayatTransaksi();
  }

  Future<void> getRiwayatTransaksi() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.get(

        Uri.parse(
          '${ApiService.baseUrl}/api/riwayat-transaksi',
        ),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final List riwayat =
            data['data'];

        setState(() {

          transaksi =
              riwayat.map<Map<String, dynamic>>((item) {

            return {

               "external_id":
                  item['external_id'],

              "tanggal_transaksi":
                  item['tanggal_transaksi'],

              "status_transaksi":
                  item['status_transaksi'],

              "total_harga":
                  "Rp ${item['total_harga']}",

              "penerima":
                  item['user']['username'],

              "phone":
                  item['user']['no_telp'],

              "alamat":
                  item['alamat_pengiriman'],

              "order_items":
                  item['order_items'],

              "biaya_admin":
                "Rp ${(item['subtotal'] * 0.10).toInt()}",

              "subtotal":
                "Rp ${item['subtotal']}",       
            };

          }).toList();
        });
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: transaksi.isEmpty
          ? const Center(child: Text("Belum ada transaksi"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transaksi.length,
              itemBuilder: (context, index) {
                final item = transaksi[index];
                return buildCard(item);
              },
            ),
    );
  }

  Widget buildCard(Map<String, dynamic> item) {
    int totalItem = 0;

    for (var orderItem
        in item["order_items"]) {

      totalItem +=
          orderItem["jumlah"] as int;
    }
    Color statusColor;
    IconData statusIcon;

    switch (item["status_transaksi"]) {
      case "dibayar":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;

      case "Pending":
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;

      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRiwayatPage(data: item),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      item["external_id"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item["tanggal_transaksi"],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        item["status_transaksi"],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 10),

            Row(
              children: [

                Icon(
                  Icons.fastfood,
                  size: 18,
                  color: Colors.orange,
                ),

                const SizedBox(width: 8),
                
                Text(
                  "$totalItem item",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  "Total Pembayaran",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  item["total_harga"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}