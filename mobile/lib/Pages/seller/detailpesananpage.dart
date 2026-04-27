import 'package:flutter/material.dart';

class DetailPesananPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPesananPage({super.key, required this.data});

  @override
  State<DetailPesananPage> createState() => DetailPesananPageState();
}

class DetailPesananPageState extends State<DetailPesananPage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    Color statusColor;

    switch (data["status"]) {
      case "Diproses":
        statusColor = Colors.orange;
        break;
      case "Dikirim":
        statusColor = Colors.blue;
        break;
      case "Selesai":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("No Pesanan", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    Text(data["kode"], style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    const Text("Tanggal", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    Text(data["tanggal"]),
                  ],
                ),
                Text(
                  data["status"],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          buildCard(
            child: Column(
              children: data["items"].map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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

                      const SizedBox(width: 10),

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
                              "${item["qty"]} x Rp ${item["harga"]}",
                              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "Rp ${item["subtotal"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          buildCard(
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Penerima", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text("${data["customer"]} • ${data["phone"]}"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          buildCard(
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Alamat", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text(data["alamat"]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          buildCard(
            child: Row(
              children: [
                Image.asset(
                  data["metode_image"],
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 10),
                Text(data["metode"]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          buildCard(
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text("Rp ${data["subtotal"]}"),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ongkir"),
                    Text("Rp ${data["ongkir"]}"),
                  ],
                ),

                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "Rp ${data["total"]}",
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

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Pesanan Selesai",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}