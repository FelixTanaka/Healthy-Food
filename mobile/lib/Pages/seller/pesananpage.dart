import 'package:flutter/material.dart';
import 'package:mobile/Pages/seller/detailpesananpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => PesananPageState();
}

class PesananPageState extends State<PesananPage> {

  List<Map<String, dynamic>> orders = [];

  DateTime? startDate;
  DateTime? endDate;

  String selectedStatus =
      "Semua";

   @override
  void initState() {
    super.initState();
    getPesananSeller();
  }

  Future<void> getPesananSeller() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.get(

        Uri.parse(
          '${ApiService.baseUrl}/api/pesanan-seller',
        ),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final List pesanan =
            data['data'];

        setState(() {

          orders =
              pesanan.map<Map<String, dynamic>>((item) {

            return {

              "id":
                  item['id'],

              "kode":
                  item['external_id'],

              "tanggal":
                  item['tanggal_transaksi'],

              "status_order":
                  item['status_order'],

              "status_transaksi":
                  item['status_transaksi'],

              "customer":
                  item['user']['username'],

              "phone":
                  item['user']['no_telp'],

              "alamat":
                  item['alamat_pengiriman'],

              "subtotal":
                  item['subtotal_seller'],

              "total":
                  item['total_harga'],

              "biaya_admin":
                  item['biaya_admin'],

              "total_item":
                  item['total_item'],
                "ongkir": item['ongkir'],  

              "items":

                  item['order_items']
                      .map((orderItem) {

                final makanan =
                    orderItem['makanan'];

                return {

                  "nama":
                      makanan['nama_makanan'],

                  "qty":
                      orderItem['jumlah'],

                  "harga":
                      makanan['harga'],

                  "subtotal":

                      orderItem['jumlah'] *
                      makanan['harga'],

                  "image":

                      "${ApiService.baseUrl}/storage/${makanan['gambar_makanan']}",
                };

              }).toList(),
            };

          }).toList();
        });
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  Future<void> showFilterDialog()
    async {

      showDialog(

        context: context,

        builder: (context) {

          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Filter Laporan",
            ),

            content: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                ElevatedButton(
                     style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.orangeAccent,

                      foregroundColor:
                          Colors.white,
                    ),
                  onPressed: () async {

                    final picked =
                        await showDatePicker(

                      context: context,

                      firstDate:
                          DateTime(2024),

                      lastDate:
                          DateTime(2100),
                    );

                    if (picked != null) {

                      setState(() {
                        startDate = picked;
                      });
                    }
                  },

                  child: Text(

                    startDate == null

                        ? "Tanggal Awal"

                        : startDate
                            .toString()
                            .substring(0, 10),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                   style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.orangeAccent,

                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () async {

                    final picked =
                        await showDatePicker(

                      context: context,

                      firstDate:
                          DateTime(2024),

                      lastDate:
                          DateTime(2100),
                    );

                    if (picked != null) {

                      setState(() {
                        endDate = picked;
                      });
                    }
                  },

                  child: Text(

                    endDate == null

                        ? "Tanggal Akhir"

                        : endDate
                            .toString()
                            .substring(0, 10),
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField(
                  dropdownColor: Colors.white,

                  initialValue: selectedStatus,

                  items: [

                    "Semua",
                    "diproses",
                    "selesai",

                  ].map((status) {

                    return DropdownMenuItem(

                      value: status,

                      child: Text(status),
                    );

                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      selectedStatus =
                          value.toString();
                    });
                  },
                ),
              ],
            ),

            actions: [

              TextButton(
                  style:
                    OutlinedButton.styleFrom(

                  foregroundColor:
                      Colors.orange,

                  side: const BorderSide(
                    color: Colors.orange,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Batal",
                ),
              ),

              ElevatedButton(
                 style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.orange,

                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {

                  Navigator.pop(context);

                  downloadPdf();
                },

                child: const Text(
                  "Download",
                ),
              ),
            ],
          );
        },
      );
    }

   Future<void> downloadPdf() async {

    List<Map<String, dynamic>>
    filteredOrders = orders;

    if (selectedStatus != "Semua") {

      filteredOrders =
          filteredOrders.where((order) {

        final status =
            order["status_order"]
                .toString()
                .trim();

        debugPrint(status);

        return status ==
            selectedStatus;
      }).toList();
    }

    if (startDate != null &&
        endDate != null) {

      filteredOrders =
          filteredOrders.where((order) {

        final tanggal =
            DateTime.parse(
          order["tanggal"],
        );

        final orderDate =
            DateTime(
          tanggal.year,
          tanggal.month,
          tanggal.day,
        );

        final start =
            DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );

        final end =
            DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
        );

        return

          orderDate.isAtSameMomentAs(
            start,
          ) ||

          orderDate.isAtSameMomentAs(
            end,
          ) ||

          (orderDate.isAfter(start) &&
          orderDate.isBefore(end));

      }).toList();
    }

    debugPrint(
      filteredOrders.length.toString(),
    );

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a4,

        build: (context) {

          return [

            pw.Center(

              child: pw.Text(

                "LAPORAN PESANAN SELLER",

                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Center(

              child: pw.Text(
                "Total Pesanan : ${filteredOrders.length}",
              ),
            ),

            pw.SizedBox(height: 20),

            for (var order
                in filteredOrders)

              pw.Container(

                margin:
                    const pw.EdgeInsets.only(
                  bottom: 20,
                ),

                padding:
                    const pw.EdgeInsets.all(
                  14,
                ),

                decoration:
                    pw.BoxDecoration(

                  border: pw.Border.all(
                    color:
                        PdfColors.grey400,
                  ),
                ),

                child: pw.Column(

                  crossAxisAlignment:
                      pw.CrossAxisAlignment
                          .start,

                  children: [

                    pw.Row(

                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,

                      children: [

                        pw.Text(

                          order["kode"],

                          style:
                              pw.TextStyle(
                            fontWeight:
                                pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        pw.Text(
                          "Rp ${order["total"]}",
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 8),

                    pw.Text(
                      "Customer : ${order["customer"]}",
                    ),

                    pw.Text(
                      "Tanggal : ${order["tanggal"]}",
                    ),

                    pw.Text(
                      "Status : ${order["status_order"]}",
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text(

                      "Daftar Makanan",

                      style: pw.TextStyle(
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 8),

                    ...(order["items"] as List)
                      .map<pw.Widget>((item) {

                    return pw.Container(

                      margin:
                          const pw.EdgeInsets.only(
                        bottom: 8,
                      ),

                      padding:
                          const pw.EdgeInsets.all(
                        10,
                      ),

                      decoration:
                          pw.BoxDecoration(

                        color:
                            PdfColors.grey100,

                        borderRadius:
                            pw.BorderRadius.circular(
                          6,
                        ),
                      ),

                      child: pw.Column(

                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,

                        children: [

                          pw.Text(

                            item["nama"].toString(),

                            style: pw.TextStyle(
                              fontWeight:
                                  pw.FontWeight.bold,
                            ),
                          ),

                          pw.SizedBox(height: 4),

                          pw.Text(
                            "Jumlah : ${item["qty"]}",
                          ),

                          pw.Text(
                            "Harga : Rp ${item["harga"]}",
                          ),

                          pw.Text(
                            "Subtotal : Rp ${item["subtotal"]}",
                          ),
                        ],
                      ),
                    );

                  }),

                  pw.SizedBox(height: 10),

                  pw.Divider(),

                  pw.Row(

                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,

                    children: [

                      pw.Text("Subtotal"),

                      pw.Text(
                        "Rp ${order["subtotal"]}",
                      ),
                    ],
                  ),

                  pw.Row(

                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,

                    children: [

                      pw.Text("Biaya Admin"),

                      pw.Text(
                        "Rp ${order["biaya_admin"]}",
                      ),
                    ],
                  ),

                  pw.Row(

                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,

                    children: [

                      pw.Text("Ongkir"),

                      pw.Text(
                        "Rp ${order["ongkir"]}",
                      ),
                    ],
                  ),

                  pw.Divider(),

                  pw.Row(

                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,

                    children: [

                      pw.Text(

                        "Total",

                        style: pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),

                      pw.Text(

                        "Rp ${order["total"]}",

                        style: pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
          ];
        },
      ),
    );

    final dir =
        await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/laporan_pesanan.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    Fluttertoast.showToast(
      msg: "PDF berhasil didownload",
    );

    OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [

          Padding(

            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: () {
                  showFilterDialog();
                },

                icon: const Icon(
                  Icons.picture_as_pdf,
                ),

                label: const Text(
                  "Download Laporan",
                ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.orange,

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

    Expanded(
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                      DetailPesananPage(
                    data: item,
                  ),
                ),
              );

              if (result == true) {

                getPesananSeller();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            item["kode"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item["tanggal"],
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Rp ${item["total"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [

                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        item["customer"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.fastfood,
                        size: 16,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        "${item["total_item"]} item",
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [

                      Row(
                        children: [

                          const Text(
                            "Transaksi",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 6),

                          buildPaymentStatus(
                            item["status_transaksi"],
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      Row(
                        children: [

                          const Text(
                            "Order",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 6),

                          buildOrderStatus(
                            item["status_order"],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
     ),
    ],
  ),
  );
}

  Widget buildPaymentStatus(String status) {

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
        color = Colors.blue;
    }

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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

  Widget buildOrderStatus(String status) {

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

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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