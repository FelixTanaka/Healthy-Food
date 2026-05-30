import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';

class AllReviewsPage extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const AllReviewsPage({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Semua Ulasan"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
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

                      review["user"]["profile"] != null

                          ? NetworkImage(
                              "${ApiService.baseUrl}/storage/${review["user"]["profile"]}",
                            )

                          : null,

                  child:

                      review["user"]["profile"] == null

                          ? Text(

                              review["user"]["username"][0],

                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
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
                                review["user"]["username"],

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 6),

                              ...List.generate(5, (i) {

                                return Icon(
                                  i < review["nilai"]

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
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}