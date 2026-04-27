import 'package:flutter/material.dart';
import 'package:mobile/Pages/detailriwayatpage.dart';

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
    loadDummyData();
  }

  void loadDummyData() {
    transaksi = [
      {
        "nama": "Nasi Ayam Bakar",
        "tanggal": "16 April 2026",
        "total": "Rp 25.000",
        "status": "Berhasil",
        "image": "assets/images/ayam.jpg",

        "order_id": "INV-001",
        "penerima": "Felix",
        "phone": "08123456789",
        "alamat": "Jl. Contoh No.123",
        "harga": "Rp 20.000",
        "ongkir": "Rp 5.000",

        "qty": 1,
        "metode": "DANA",
        "metode_image": "assets/images/dana.png",
      },
    ];
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
    Color statusColor;
    IconData statusIcon;

    switch (item["status"]) {
      case "Berhasil":
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item["image"],
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
                    item["nama"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["tanggal"],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        item["status"],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Text(
              item["total"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}