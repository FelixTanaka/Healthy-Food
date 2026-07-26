import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CatatKonsumsiDetailPage extends StatefulWidget {
  final Map item;
  final int orderId;

  const CatatKonsumsiDetailPage({
    super.key,
    required this.item,
    required this.orderId,
  });

  @override
  State<CatatKonsumsiDetailPage> createState() =>
      _CatatKonsumsiDetailPageState();
}

class _CatatKonsumsiDetailPageState
    extends State<CatatKonsumsiDetailPage> {
  int jumlahKonsumsi = 1;
    int sudahDicatat = 0;
  int sisaPorsi = 0;

  Future<void> loadKonsumsi() async {

    final prefs = await SharedPreferences.getInstance();

    final int orderItemId = widget.item["id"];
    final int jumlahDibeli = widget.item["jumlah"];

    sudahDicatat =
        prefs.getInt("konsumsi_$orderItemId") ?? 0;

    sisaPorsi = jumlahDibeli - sudahDicatat;

    if (sisaPorsi < 0) {
      sisaPorsi = 0;
    }

    jumlahKonsumsi = sisaPorsi > 0 ? 1 : 0;

    setState(() {});
  }

    @override
  void initState() {
    super.initState();

    loadKonsumsi();
  }

  Future<void> catatKonsumsi() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final makanan = widget.item["makanan"];

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/api/transaksi/catat-konsumsi"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "order_id": widget.orderId.toString(),
        "makanan_id": makanan["id"].toString(),
        "jumlah_konsumsi": jumlahKonsumsi.toString(),
      },
    );

    final data = jsonDecode(response.body);

    if (!mounted) return;

    if (response.statusCode == 200) {

      final prefs = await SharedPreferences.getInstance();

      final today =
          DateTime.now().toIso8601String().substring(0, 10);

      final lastDate =
          prefs.getString("tanggal_nutrisi");

      if (lastDate != today) {

        await prefs.setInt("kalori_harian", 0);
        await prefs.setDouble("protein_harian", 0);
        await prefs.setDouble("karbo_harian", 0);
        await prefs.setDouble("lemak_harian", 0);

        await prefs.setString(
          "tanggal_nutrisi",
          today,
        );
      }

      final int kaloriBaru =
          (prefs.getInt("kalori_harian") ?? 0) +
          (data["kalori"] as int);

      await prefs.setInt(
        "kalori_harian",
        kaloriBaru,
      );

      await prefs.setDouble(
        "protein_harian",
        (prefs.getDouble("protein_harian") ?? 0) +
            (data["protein"] as num).toDouble(),
      );

      await prefs.setDouble(
        "lemak_harian",
        (prefs.getDouble("lemak_harian") ?? 0) +
            (data["lemak"] as num).toDouble(),
      );

      await prefs.setDouble(
        "karbo_harian",
        (prefs.getDouble("karbo_harian") ?? 0) +
            (data["karbohidrat"] as num).toDouble(),
      );

      final int orderItemId = widget.item["id"];

      final int sudahDicatat =
          prefs.getInt("konsumsi_$orderItemId") ?? 0;

      await prefs.setInt(
        "konsumsi_$orderItemId",
        sudahDicatat + jumlahKonsumsi,
      );

      Fluttertoast.showToast(
        msg: data["message"],
      );

      Navigator.pop(context);



    } else {

      Fluttertoast.showToast(
        msg: data["message"],
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    final makanan = widget.item["makanan"];
    final seller = makanan["seller"];

    final int jumlahDibeli = widget.item["jumlah"];

    final int kalori = makanan["kalori"] * jumlahKonsumsi;

    final double protein =
    double.parse(makanan["protein"].toString()) * jumlahKonsumsi;

final double lemak =
    double.parse(makanan["lemak"].toString()) * jumlahKonsumsi;

final double karbo =
    double.parse(makanan["karbohidrat"].toString()) * jumlahKonsumsi;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Catat Konsumsi"),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: sisaPorsi == 0
                  ? null
                  : catatKonsumsi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                sisaPorsi == 0
                    ? "Sudah Dicatat"
                    : "Simpan Konsumsi",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// FOTO
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.network(
                      "${ApiService.baseUrl}/storage/${makanan["gambar_makanan"]}",
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    makanan["nama_makanan"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    seller["nama_toko"],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.orange.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "${makanan["kalori"]} kcal / Porsi",
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// NUTRISI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Informasi Nutrisi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 15),

                  buildRow(
                      "Protein",
                      "${makanan["protein"]} g",
                      Colors.red),

                  buildRow(
                      "Lemak",
                      "${makanan["lemak"]} g",
                      Colors.orange),

                  buildRow(
                      "Karbohidrat",
                      "${makanan["karbohidrat"]} g",
                      Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// JUMLAH
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Jumlah Dibeli : $jumlahDibeli Porsi",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Sudah Dicatat : $sudahDicatat Porsi",
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Sisa Porsi : $sisaPorsi Porsi",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "Berapa porsi yang Anda konsumsi?",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  sisaPorsi == 0
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),

                SizedBox(width: 10),

                Text(
                  "Semua porsi sudah dicatat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),

                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {
                    if (jumlahKonsumsi > 1) {
                      setState(() {
                        jumlahKonsumsi--;
                      });
                    }
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "$jumlahKonsumsi",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 35,
                  ),
                  onPressed: () {
                    if (jumlahKonsumsi < sisaPorsi) {
                      setState(() {
                        jumlahKonsumsi++;
                      });
                    }
                  },
                ),

              ],
            ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Nutrisi yang Akan Dicatat",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 15),

                  buildTotal(
                    Icons.local_fire_department,
                    Colors.orange,
                    "Kalori",
                    "$kalori kcal",
                  ),

                  buildTotal(
                    Icons.fitness_center,
                    Colors.red,
                    "Protein",
                    "${protein.toStringAsFixed(2)} g",
                  ),

                  buildTotal(
                    Icons.water_drop,
                    Colors.orange,
                    "Lemak",
                    "${lemak.toStringAsFixed(2)} g",
                  ),

                  buildTotal(
                    Icons.rice_bowl,
                    Colors.blue,
                    "Karbohidrat",
                    "${karbo.toStringAsFixed(2)} g",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildRow(
      String title,
      String value,
      Color color,
      ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          CircleAvatar(
            radius: 6,
            backgroundColor: color,
          ),

          const SizedBox(width: 10),

          Expanded(child: Text(title)),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotal(
      IconData icon,
      Color color,
      String title,
      String value,
      ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(title),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}