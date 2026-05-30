import 'package:flutter/material.dart';
import 'package:mobile/Pages/allreviewpage.dart';
import 'package:mobile/services/api_service.dart';

class DetailMenuPage extends StatelessWidget {
  final Map<String, dynamic> item;

  DetailMenuPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    double rating = item["ratings_avg_nilai"] == null

      ? 0.0

      : double.parse(
          item["ratings_avg_nilai"]
              .toString(),
        );

    final List<Map<String, dynamic>>
    reviews =

    List<Map<String, dynamic>>.from(
      item["ratings"] ?? [],
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    "${ApiService.baseUrl}/storage/${item["gambar_makanan"]}",
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item["nama_makanan"],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Rp ${item["harga"]}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              
                              Row(
                                children: [

                                   ...List.generate(5, (index) {

                                    if (index < rating.floor()) {

                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      );

                                    } else if (

                                      index < rating &&
                                      rating % 1 >= 0.5

                                    ) {

                                      return const Icon(
                                        Icons.star_half,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }

                                    return const Icon(
                                      Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),

                                  const SizedBox(width: 6),

                                  Text(

                                    item["ratings_avg_nilai"] == null

                                        ? "0.0"

                                        : double.parse(
                                            item["ratings_avg_nilai"]
                                                .toString(),
                                          ).toStringAsFixed(1),

                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    "(${item["ratings_count"]})",

                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item["kategori"]["nama_kategori"],
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600, 
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  CircleAvatar(
                                    radius: 12,

                                    backgroundImage: NetworkImage(
                                      "${ApiService.baseUrl}/storage/${item["seller"]["foto_toko"]}",
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    item["seller"]["nama_toko"],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Informasi Nutrisi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildInfo(Icons.local_fire_department, "Kalori", "${item["kalori"]} kcal", Colors.orange),
                                  buildInfo(Icons.set_meal, "Protein", "${item["protein"]} g", Colors.blue),
                                  buildInfo(Icons.water_drop, "Lemak", "${item["lemak"]} g", Colors.red),
                                  buildInfo(Icons.grain, "Karbo", "${item["karbohidrat"]} g", Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Deskripsi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                item["deskripsi"],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Ulasan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AllReviewsPage(reviews: reviews),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Lihat semua",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Column(
                                children: reviews.take(3).map((review) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,

                                          backgroundColor:
                                              Colors.orange.withValues(
                                            alpha: 0.2,
                                          ),

                                          backgroundImage:

                                              review['user']['profile']
                                                          != null

                                                  ? NetworkImage(
                                                      "${ApiService.baseUrl}/storage/${review['user']['profile']}",
                                                    )

                                                  : null,

                                          child:
                                              review['user']['profile']
                                                          == null

                                                  ? Text(

                                                      review['user']
                                                          ["username"][0]
                                                              .toUpperCase(),

                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )

                                                  : null,
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [

                                                  Row(
                                                    children: [

                                                      Text(
                                                        review['user']["username"],

                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      ...List.generate(5, (index) {

                                                        return Icon(
                                                          index < review["nilai"]

                                                              ? Icons.star

                                                              : Icons.star_border,

                                                          size: 14,
                                                          color: Colors.amber,
                                                        );
                                                      }),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 2),

                                                  Text(

                                                    review["tanggal_rating"] == null

                                                        ? "-"

                                                        : review["tanggal_rating"]
                                                            .toString(),

                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              const SizedBox(height: 4),
                                  
                                              Text(
                                                review["komentar"],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.4, 
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfo(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}