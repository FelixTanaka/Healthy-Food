import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:intl/intl.dart';

class DetailPesananPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPesananPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailPesananPage> createState() => DetailPesananPageState();
}

class DetailPesananPageState extends State<DetailPesananPage> {
  Future<void> pesananSelesai() async {
    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.put(

        Uri.parse(
          '${ApiService.baseUrl}/api/pesanan-selesai/${widget.data["id"]}',
        ),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(

          msg: "Pesanan selesai",
        );
        if (!mounted) return;
        Navigator.pop(context, true);
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  Future<void> updatePesananDikirim() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(
          "${ApiService.baseUrl}/api/seller/pesanan/${widget.data["id"]}/dikirim",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: "Pesanan berhasil dikirim 🚚",
        );

        if (!mounted) return;

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          buildCard(

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(
                          "No Pesanan",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          data["kode"],

                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Tanggal",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          data["tanggal"],
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [

                        Row(
                          children: [

                            const Text(
                              "Transaksi",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            const SizedBox(width: 6),

                            buildPaymentStatus(
                              data[
                                  "status_transaksi"],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            const Text(
                              "Order",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            const SizedBox(width: 6),

                            buildOrderStatus(
                              data["status_order"],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          buildCard(

            child: Column(

              children:
                  data["items"].map<Widget>((item) {

                return Container(

                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),

                  child: Row(
                    children: [

                      ClipRRect(

                        borderRadius:
                            BorderRadius.circular(10),

                        child: Image.network(
                          item["image"],

                          width: 65,
                          height: 65,

                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              item["nama"],

                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "${item["qty"]} x ${NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(item["harga"])}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(item["subtotal"]),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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

                const Icon(
                  Icons.person,
                  color: Colors.orange,
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Penerima",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${data["customer"]} • ${data["phone"]}",
                      ),
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

                const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Alamat",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        data["alamat"],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          buildCard(

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text("Subtotal"),

                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(data["subtotal"]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text("Biaya Admin"),

                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(data["biaya_admin"]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text("Ongkir"),

                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(data["ongkir"]),
                    ),
                  ],
                ),

                const Divider(height: 24),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      "Total",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(data["total"]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (data["status_order"] != "selesai")

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(

              onPressed: () {

                if (data["status_order"] == "diproses") {

                  updatePesananDikirim();

                } else if (
                    data["status_order"] == "dikirim") {

                  pesananSelesai();
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              child: Text(

                data["status_order"] == "diproses"

                    ? "Pesanan Dikirim"

                    : data["status_order"] == "dikirim"

                        ? "Pesanan Selesai"

                        : "Pesanan Selesai",
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildCard({
    required Widget child,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [

          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.04),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  Widget buildPaymentStatus(
    String status,
  ) {

    Color color;

    switch (status) {

      case "dibayar":
        color = Colors.green;
        break;

      case "belumBayar":
        color = Colors.orange;
        break;

      case "gagal":
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.1),

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildOrderStatus(
    String status,
  ) {

    Color color;

    switch (status) {

      case "menunggu_pembayaran":
        color = Colors.orange;
        break;

      case "dikirim":
        color = Colors.deepOrange;
        break;  

      case "selesai":
        color = Colors.green;
        break;

      case "dibatalkan":
        color = Colors.red;
        break;

      case "diproses":
        color = Colors.blue;
        break;  

      default:
        color = Colors.grey;
    }

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.1),

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}