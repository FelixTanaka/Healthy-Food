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

  double proteinPercent = 0.2;
  double karboPercent = 0.2;
  double lemakPercent = 0.2;

  @override
  void initState() {
    super.initState();
    getHealthProfile();
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
                      percent: 0.4, 
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
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              CategoryItem(
                title: "Diet",
                image: "assets/images/ayam.jpg",
              ),
              CategoryItem(
                title: "Low Sugar",
                image: "assets/images/sugar.jpg",
              ),
              CategoryItem(
                title: "Protein",
                image: "assets/images/protein.jpg",
              ),
              CategoryItem(
                title: "Vegan",
                image: "assets/images/vegan.jpg",
              ),
            ],
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FoodRekomendasi(
                name: "Salad Sehat",
                seller: "Healthy Kitchen",
                price: "Rp 25.000",
                rating: 4.8,
                image: "assets/images/ayam.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMenuPage(
                        food: {
                          "name": "Nasi Ayam Bakar",
                          "seller": "Warung Sehat",
                          "price": "Rp 20.000",
                          "rating": 4.9,
                          "image": "assets/images/ayam.jpg",
                          "category": "Healthy",
                          "description": "Ayam bakar sehat rendah minyak, enak lezat, cocok untuk diet",
                        },
                      ),
                    ),
                  );
                },
              ),
              FoodRekomendasi(
                name: "Chicken Diet",
                seller: "Fit Food",
                price: "Rp 30.000",
                rating: 4.7,
                image: "assets/images/chicken.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMenuPage(
                        food: {
                          "name": "Nasi Ayam Bakar",
                          "seller": "Warung Sehat",
                          "price": "Rp 20.000",
                          "rating": 4.9,
                          "image": "assets/images/ayam.jpg",
                          "category": "Healthy",
                          "description": "Ayam bakar sehat rendah minyak, enak lezat, cocok untuk diet",
                        },
                      ),
                    ),
                  );
                },
              ),
              FoodRekomendasi(
                name: "Vegan Bowl",
                seller: "Green Eat",
                price: "Rp 28.000",
                rating: 4.9,
                image: "assets/images/vegan.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMenuPage(
                        food: {
                          "name": "Nasi Ayam Bakar",
                          "seller": "Warung Sehat",
                          "price": "Rp 20.000",
                          "rating": 4.9,
                          "image": "assets/images/ayam.jpg",
                          "category": "Healthy",
                          "description": "Ayam bakar sehat rendah minyak, enak lezat, cocok untuk diet",
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
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

        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            FoodPopulerCard(
              name: "Nasi Ayam Bakar",
              seller: "Warung Sehat",
              price: "Rp 20.000",
              rating: 4.9,
              image: "assets/images/ayam.jpg",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMenuPage(
                      food: {
                        "name": "Nasi Ayam Bakar",
                        "seller": "Warung Sehat",
                        "price": "Rp 20.000",
                        "rating": 4.9,
                        "image": "assets/images/ayam.jpg",
                        "category": "Healthy",
                        "description": "Ayam bakar sehat rendah minyak, enak lezat, cocok untuk diet",
                      },
                    ),
                  ),
                );
              },
            ),
            FoodPopulerCard(
              name: "Nasi Ayam Bakar",
              seller: "Warung Sehat",
              price: "Rp 20.000",
              rating: 4.9,
              image: "assets/images/ayam.jpg",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMenuPage(
                      food: {
                        "name": "Nasi Ayam Bakar",
                        "seller": "Warung Sehat",
                        "price": "Rp 20.000",
                        "rating": 4.9,
                        "image": "assets/images/ayam.jpg",
                        "category": "Healthy",
                        "description": "Ayam bakar sehat rendah minyak, enak lezat, cocok untuk diet",
                      },
                    ),
                  ),
                );
              },
            ),
          ],
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