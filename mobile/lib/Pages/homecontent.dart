import 'package:flutter/material.dart';
import 'package:mobile/Pages/homepage.dart';
import 'package:mobile/widgets/kategoriitem.dart';
import 'package:mobile/widgets/foodrekomendasi.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mobile/widgets/foodpopuler.dart';
import 'package:mobile/Pages/detailmenupage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/Pages/detailrekomendasi.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  int kalori = 0;
  double protein = 0;
  double karbo = 0;
  double lemak = 0;
  int kaloriDikonsumsi = 0;
  int sisaKalori = 0;
  int netKalori = 0;

  double proteinDikonsumsi = 0;
  double karboDikonsumsi = 0;
  double lemakDikonsumsi = 0;

  double proteinPercent = 0;
  double karboPercent = 0;
  double lemakPercent = 0;
  List kategoriList = [];
  List makananPopuler = [];
  List makananRekomendasi = [];
  bool isLoadingAI = false;
  int stepsRealtime = 0;
  double kaloriTerbakar = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getHealthProfile();
    await getNutrisiLocal();
    await getKategori();
    await getMakananPopuler();
    await getRekomendasi();
  }

  Future<void> requestPermission() async {
    await Permission.activityRecognition.request();
  }

  Future<void> getHealthProfile() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/health-profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final health = data['data'];

        setState(() {
          kalori = health['kalori'];
          protein = double.parse(
            health['protein']
          );
          karbo = double.parse(
            health['karbo']
          );
          lemak = double.parse(
            health['lemak']
          );
        });
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getNutrisiLocal() async {

    final prefs =
        await SharedPreferences.getInstance();

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

    setState(() {

      kaloriDikonsumsi =
          prefs.getInt("kalori_harian") ?? 0;

      proteinDikonsumsi =
          prefs.getDouble("protein_harian") ?? 0;

      karboDikonsumsi =
          prefs.getDouble("karbo_harian") ?? 0;

      lemakDikonsumsi =
          prefs.getDouble("lemak_harian") ?? 0;

      sisaKalori =
          (kalori - kaloriDikonsumsi)
              .clamp(0, kalori);

      proteinPercent = protein > 0
          ? (proteinDikonsumsi / protein)
              .clamp(0.0, 1.0)
          : 0;

      karboPercent = karbo > 0
          ? (karboDikonsumsi / karbo)
              .clamp(0.0, 1.0)
          : 0;

      lemakPercent = lemak > 0
          ? (lemakDikonsumsi / lemak)
              .clamp(0.0, 1.0)
          : 0;

      netKalori =
          kaloriDikonsumsi - kaloriTerbakar.toInt();

    });
  }

  Future<void> getKategori() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/kategori"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          kategoriList = data['data'];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getMakananPopuler() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/menu-populer"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          makananPopuler = data['data'];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getRekomendasi() async {
    setState(() {
      isLoadingAI = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/rekomendasi"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          makananRekomendasi = data['data'];
          isLoadingAI = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingAI = false;
      });
      debugPrint(e.toString());
    }
  }

  Future<void> tambahKeranjang(
    int makananId, {
    bool forceReplace = false,
  }) async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/api/keranjang/tambah",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer $token",
        },
        body: {
          "makanan_id":
              makananId.toString(),
          "jumlah": "1",
          "force_replace":
              forceReplace
                  ? "1"
                  : "0",
        },
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: data["message"],
        );

      }

      else if (
          response.statusCode == 409 &&
          data["seller_berbeda"] ==
              true) {

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) {

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Seller Berbeda",
              ),

              content: const Text(
                "Keranjang Anda berisi produk dari toko lain.\n\nHapus keranjang lama dan ganti dengan produk baru?",
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Batal",
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.orange,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () async {

                    Navigator.pop(
                      context,
                    );

                    await tambahKeranjang(
                      makananId,
                      forceReplace:
                          true,
                    );
                  },
                  child: const Text(
                    "Hapus & Ganti",
                  ),
                ),
              ],
            );
          },
        );

      }

      else {

        Fluttertoast.showToast(
          msg:
              data["message"] ??
              "Gagal tambah keranjang",
        );

      }

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
         const SizedBox(height: 10),
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🔥 Kalori Hari Ini",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 10.0,
                      percent: kalori > 0 ? (kaloriDikonsumsi / kalori).clamp(0.0, 1.0) : 0, 
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remaining",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            "$sisaKalori",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      progressColor: Color(0xFFFF8A00),
                      backgroundColor: Colors.grey.shade200,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),

                    const SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant, size: 20, color: Colors.blueGrey),

                            SizedBox(width: 8),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dikonsumsi",
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "$kaloriDikonsumsi kcal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),       
                          ],
                        ),

                        SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag,
                              size: 20,
                              color: Colors.blueGrey,
                            ),

                            SizedBox(width: 8),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Target",
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "$kalori kcal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                Divider(color: Colors.grey.shade300),

                const SizedBox(height: 10),

                const Text(
                  "Nutrisi",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                buildNutrisi(
                  "Protein",
                  proteinPercent,
                  "${proteinDikonsumsi.toStringAsFixed(2)} g / ${protein.toStringAsFixed(2)} g",
                ),
                const SizedBox(height: 8),
                buildNutrisi(
                  "Karbo",
                  karboPercent,
                  "${karboDikonsumsi.toStringAsFixed(2)} g / ${karbo.toStringAsFixed(2)} g",
                ),
                const SizedBox(height: 8),
                buildNutrisi(
                  "Lemak",
                  lemakPercent,
                  "${lemakDikonsumsi.toStringAsFixed(2)} g / ${lemak.toStringAsFixed(2)} g",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Kategori",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              return CategoryItem(
                title: kategoriList[index]['nama_kategori'],
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Rekomendasi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PembeliHomePage(initialIndex: 1),
                    ),
                  );
                },
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

       SizedBox(
        height: 240,
  child: isLoadingAI
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.orange,
              ),
              SizedBox(height: 12),
              Text(
                "🤖 AI sedang memilih makanan terbaik...",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: makananRekomendasi.length,
          itemBuilder: (context, index) {
            final item = makananRekomendasi[index];

            return FoodRekomendasi(
              name: item['nama_makanan'],
              seller: item['seller']['nama_toko'],
              price: item['harga'],
              rating: item['ratings_avg_nilai'] == null
                  ? 0
                  : double.parse(item['ratings_avg_nilai'].toString()),
              totalRating: item['ratings_count'] ?? 0,
              image: "${ApiService.baseUrl}/storage/${item['gambar_makanan']}",
              sellerImage: "${ApiService.baseUrl}/storage/${item['seller']['foto_toko']}",
              kategori: item['kategori']['nama_kategori'],
              makananId: item['id'],
              reason: item['ai_reason'] ?? "",
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailRekomendasiPage(
                    food: item,
                  ),
                ),
              );
              },
              onAdd: () {
                tambahKeranjang(item['id']);
              },
            );
          },
        ),
      ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Makanan Populer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PembeliHomePage(initialIndex: 1),
                    ),
                  );
                },
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ), 
        ),

        const SizedBox(height: 5),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: makananPopuler.length,
          itemBuilder: (context, index) {

            final item = makananPopuler[index];

            return FoodPopulerCard(
              name: item['nama_makanan'],
              seller: item['seller']['nama_toko'],
              price: item['harga'],
              rating: item['ratings_avg_nilai'] == null
                  ? 0
                  : double.parse(
                      item['ratings_avg_nilai'].toString(),
                    ),
              image:
                  "${ApiService.baseUrl}/storage/${item['gambar_makanan']}",
              kategori: item['kategori']['nama_kategori'],
              totalRating: item['ratings_count'] ?? 0,
              profileImage: "${ApiService.baseUrl}/storage/${item['seller']['foto_toko']}",
              makananId: item['id'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMenuPage(
                      food: item,
                    ),
                  ),
                );
              },
              onAdd: () {
                tambahKeranjang(item['id']);
              },
            );
          },
        ),
      ],
    );
  }
}

Widget buildNutrisi(String title, double percent, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
      const SizedBox(height: 4),
      LinearProgressIndicator(
        value: percent,
        minHeight: 6,
        backgroundColor: Colors.grey.shade200,
        valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8A00)),
      ),
    ],
  );
}