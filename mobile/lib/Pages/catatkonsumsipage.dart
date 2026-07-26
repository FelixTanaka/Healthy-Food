import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/Pages/catatkonsumsidetailpage.dart';

class CatatKonsumsiPage extends StatelessWidget {
  final List orderItems;
  final int orderId;

  const CatatKonsumsiPage({
    super.key,
    required this.orderItems,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Catat Konsumsi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Pilih makanan yang benar-benar Anda konsumsi.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${orderItems.length} menu pada transaksi ini",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...orderItems.map<Widget>((item) {

            final makanan = item["makanan"];
            final seller = makanan["seller"];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "${ApiService.baseUrl}/storage/${makanan["gambar_makanan"]}",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          makanan["nama_makanan"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          seller["nama_toko"],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 18,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              "${makanan["kalori"]} kcal",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [

                            buildNutritionChip(
                              "Protein",
                              "${makanan["protein"]} g",
                              Colors.red,
                            ),

                            buildNutritionChip(
                              "Lemak",
                              "${makanan["lemak"]} g",
                              Colors.orange,
                            ),

                            buildNutritionChip(
                              "Karbo",
                              "${makanan["karbohidrat"]} g",
                              Colors.blue,
                            ),

                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [

                            Icon(
                              Icons.shopping_bag,
                              color: Colors.grey[600],
                              size: 18,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              "Dibeli ${item["jumlah"]} Porsi",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(

                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CatatKonsumsiDetailPage(
                                    item: item,
                                    orderId: orderId,
                                  ),
                                ),
                              );
                            },

                            icon: const Icon(Icons.restaurant),

                            label: const Text(
                              "Catat Konsumsi",
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildNutritionChip(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$title : $value",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}