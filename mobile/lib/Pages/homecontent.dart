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

  double proteinDikonsumsi = 0;
  double karboDikonsumsi = 0;
  double lemakDikonsumsi = 0;

  double proteinPercent = 0;
  double karboPercent = 0;
  double lemakPercent = 0;
  List kategoriList = [];
  List makananPopuler = [];
  List makananRekomendasi = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getHealthProfile();
    await getNutrisiHarian();
    await getKategori();
    await getMakananPopuler();
    await getRekomendasi();
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

  Future<void> getNutrisiHarian() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/nutrisi-harian',
        ),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {

          kaloriDikonsumsi =
              data['kalori'];

          proteinDikonsumsi =
              data['protein'].toDouble();

          karboDikonsumsi =
              data['karbo'].toDouble();

          lemakDikonsumsi =
              data['lemak'].toDouble();

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
        });
      }

    } catch (e) {

      debugPrint(e.toString());
    }
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
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> tambahKeranjang(int makananId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/keranjang/tambah"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "makanan_id": makananId.toString(),
          "jumlah": "1",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: data["message"]);
      } else {
        Fluttertoast.showToast(msg: "Gagal tambah keranjang");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
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
                                  "$kaloriDikonsumsi",
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

                buildNutrisi("Protein", proteinPercent, "$proteinDikonsumsi g / $protein g"),
                const SizedBox(height: 8),
                buildNutrisi("Karbo", karboPercent, "$karboDikonsumsi g / $karbo g"),
                const SizedBox(height: 8),
                buildNutrisi("Lemak", lemakPercent, "$lemakDikonsumsi g / $lemak g"),
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
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: makananRekomendasi.length,
          itemBuilder: (context, index) {
            final item = makananRekomendasi[index];

            return FoodRekomendasi(
              name: item['nama_makanan'],
              seller: item['seller']['nama_toko'],
              price: "Rp ${item['harga']}",
              rating: item['ratings_avg_nilai'] == null
                  ? 0
                  : double.parse(item['ratings_avg_nilai'].toString()),
              totalRating: item['ratings_count'] ?? 0,
              image: "${ApiService.baseUrl}/storage/${item['gambar_makanan']}",
              sellerImage: "${ApiService.baseUrl}/storage/${item['seller']['foto_toko']}",
              kategori: item['kategori']['nama_kategori'],
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
              price: "Rp ${item['harga']}",
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