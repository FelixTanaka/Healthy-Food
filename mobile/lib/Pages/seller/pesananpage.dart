import 'package:flutter/material.dart';
import 'package:mobile/Pages/seller/detailpesananpage.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => PesananPageState();
}

class PesananPageState extends State<PesananPage> {

  final List<Map<String, dynamic>> orders = [
    {
      "kode": "ORD-001",
      "tanggal": "23 Apr 2026",
      "status": "Diproses",
      "customer": "Budi",
      "phone": "08123456789",
      "alamat": "Jl. Malioboro No.1",
      "metode": "DANA",
      "metode_image": "assets/images/dana.png",

      "subtotal": 30000,
      "ongkir": 5000,
      "total": 35000,
      "total_item": 2,

      "items": [
        {
          "nama": "Nasi Goreng",
          "qty": 1,
          "harga": 15000,
          "subtotal": 15000,
          "image": "assets/images/ayam.jpg"
        },
        {
          "nama": "Mie Ayam",
          "qty": 1,
          "harga": 15000,
          "subtotal": 15000,
          "image": "assets/images/ayam.jpg"
        },
      ]
    },

    {
      "kode": "ORD-002",
      "tanggal": "22 Apr 2026",
      "status": "Dikirim",
      "customer": "Andi",
      "phone": "082233445566",
      "alamat": "Jl. Kaliurang Km 5",
      "metode": "OVO",
      "metode_image": "assets/images/ovo.png",

      "subtotal": 30000,
      "ongkir": 7000,
      "total": 37000,
      "total_item": 2,

      "items": [
        {
          "nama": "Bakso",
          "qty": 2,
          "harga": 15000,
          "subtotal": 30000,
          "image": "assets/images/ayam.jpg"
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPesananPage(data: item),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["kode"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      buildStatus(item["status"]),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item["tanggal"],
                    style: const TextStyle(color: Colors.blueGrey),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(
                        item["customer"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Divider(),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item["total_item"]} item",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        "Rp ${item["total"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildStatus(String status) {
    Color color;

    switch (status) {
      case "Diproses":
        color = Colors.orange;
        break;
      case "Dikirim":
        color = Colors.blue;
        break;
      case "Selesai":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}