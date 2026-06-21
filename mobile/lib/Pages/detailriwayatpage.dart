import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:mobile/Pages/beriulasanpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailRiwayatPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  Future<void> downloadPdf() async {

    final pdf = pw.Document();

    final data = widget.data;

    pdf.addPage(

      pw.Page(

        margin: const pw.EdgeInsets.all(24),

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              pw.Center(

                child: pw.Column(
                  children: [

                    pw.Text(
                      "HEALTHY FOOD",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 4),

                    pw.Text(
                      "Nota Transaksi",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Container(
                padding:
                    const pw.EdgeInsets.all(12),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius:
                      pw.BorderRadius.circular(8),
                ),

                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,

                  children: [

                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,

                      children: [

                        pw.Text(
                          "No Pesanan",
                          style: pw.TextStyle(
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          data["external_id"],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 8),

                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,

                      children: [

                        pw.Text(
                          "Tanggal",
                          style: pw.TextStyle(
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          data["tanggal_transaksi"],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 8),

                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment
                              .spaceBetween,

                      children: [

                        pw.Text(
                          "Status",
                          style: pw.TextStyle(
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          data["status_transaksi"],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Informasi Penerima",
                style: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Text(
                "${data["penerima"]} - ${data["phone"]}",
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                data["alamat"],
              ),

              pw.SizedBox(height: 25),

              pw.Text(
                "Daftar Pesanan",
                style: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              pw.SizedBox(height: 10),

              ...data["order_items"]
                  .map<pw.Widget>((item) {

                final makanan =
                    item["makanan"];

                final seller =
                    makanan["seller"];

                return pw.Container(

                  margin:
                      const pw.EdgeInsets.only(
                    bottom: 12,
                  ),

                  padding:
                      const pw.EdgeInsets.all(12),

                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey300,
                    ),

                    borderRadius:
                        pw.BorderRadius.circular(
                            8),
                  ),

                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .start,

                    children: [

                      pw.Text(
                        makanan["nama_makanan"],

                        style: pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,

                          fontSize: 14,
                        ),
                      ),

                      pw.SizedBox(height: 3),

                      pw.Text(
                        seller?["nama_toko"] ??
                            "Toko Tidak Ditemukan",

                        style: pw.TextStyle(
                          color:
                              PdfColors.blueGrey,

                          fontSize: 11,
                        ),
                      ),

                      pw.SizedBox(height: 8),

                      pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment
                                .spaceBetween,

                        children: [

                          pw.Text(
                            "${item["jumlah"]} x Rp ${makanan["harga"]}",
                          ),

                          pw.Text(
                            "Rp ${item["jumlah"] * makanan["harga"]}",

                            style: pw.TextStyle(
                              fontWeight:
                                  pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.Divider(height: 30),

              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,

                children: [

                  pw.Text("Subtotal"),

                  pw.Text(
                    data["subtotal"],
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,

                children: [

                  pw.Text("Biaya Admin"),

                  pw.Text(
                    data["biaya_admin"],
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
                    "TOTAL",

                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  pw.Text(
                    data["total_harga"],

                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              pw.Center(

                child: pw.Text(
                  "Terima kasih telah berbelanja",

                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    final directory =
        Directory('/storage/emulated/0/Download');

    final file = File(
      '${directory.path}/nota_transaksi.pdf',
    );

    await file.writeAsBytes(bytes);

    Fluttertoast.showToast(
      msg: "PDF berhasil disimpan di Download",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    await OpenFilex.open(file.path);
  }

  Future<void> deleteRating(int ratingId, dynamic item) async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");


      final response = await http.delete(

        Uri.parse(
          "${ApiService.baseUrl}/api/rating/$ratingId",
        ),

        headers: {

          "Accept": "application/json",

          "Authorization":
              "Bearer $token",
        },
      );


      final data =
          jsonDecode(response.body);


      if(response.statusCode == 200){

        setState(() {

          item["rating"] = null;

        });


        Fluttertoast.showToast(
          msg: "Ulasan berhasil dihapus",
        );


      }else{

        Fluttertoast.showToast(
          msg: data["message"],
        );

      }


    }catch(e){

      Fluttertoast.showToast(
        msg: e.toString(),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Detail Transaksi"),
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

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "No Pemesanan",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      data["external_id"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Tanggal",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      data["tanggal_transaksi"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
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
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 6),

                        buildPaymentStatus(
                          data["status_transaksi"],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        const Text(
                          "Order",
                          style: TextStyle(
                            fontSize: 12,
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
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(

              children: [

                ...data["order_items"]
                    .map<Widget>((item) {

                  final makanan =
                      item["makanan"];
                  final seller =
                      makanan["seller"];

                   final rating = item["rating"];
                  final sudahReview = rating != null;    

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),

                              child: Image.network(
                                "${ApiService.baseUrl}/storage/${makanan["gambar_makanan"]}",

                                width: 70,
                                height: 70,
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
                                    makanan[
                                        "nama_makanan"],
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    seller["nama_toko"],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    "${item["jumlah"]} x Rp ${makanan["harga"]}",

                                    style: TextStyle(
                                      color:
                                          Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,

                              children: [

                                Text(
                                  "Rp ${item["jumlah"] * makanan["harga"]}",

                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                GestureDetector(

                                  onTap: () async {
                                    final result =
                                        await Navigator.push(

                                      context,

                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BeriUlasanPage(

                                          orderItems: [item],

                                          rating:
                                              item["rating"],
                                        ),
                                      ),
                                    );

                                    if (result != null) {

                                      setState(() {

                                        item["rating"] = {

                                          "id": result["id"],

                                          "nilai":
                                              result["nilai"],

                                          "komentar":
                                              result["komentar"],
                                        };
                                      });
                                    }
                                  },

                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [

                                      Icon(

                                        sudahReview 
                                            ? Icons.edit 
                                            : Icons.rate_review,
                                        size: 16,
                                        color: Colors.orange,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(

                                        sudahReview 
                                            ? "Edit Ulasan" 
                                            : "Beri Ulasan",

                                        style: const TextStyle(

                                          color:
                                              Colors.orange,

                                          fontWeight:
                                              FontWeight.w600,

                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if(sudahReview) ...[
                                  const SizedBox(height: 8),

                                  GestureDetector(
                                    onTap: () {
                                      deleteRating(
                                        item["rating"]["id"],
                                        item,
                                      );

                                    },

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: const [

                                        Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),

                                        SizedBox(width: 4),

                                        Text(
                                          "Hapus Ulasan",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

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

                      Text(
                        "Penerima",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${data["penerima"]} • ${data["phone"]}",

                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

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

                      Text(
                        "Alamat",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        data["alamat"],

                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text("Subtotal"),

                    Text(
                      data["subtotal"],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                        "Biaya Admin"),

                    Text(
                      data["biaya_admin"],
                    ),
                  ],
                ),

                const Divider(),

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
                      data["total_harga"],

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(

              onPressed: () {
                downloadPdf();
              },

              icon:
                  const Icon(Icons.download),

              label: const Text(
                "Download Nota PDF",
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildPaymentStatus(
    String status,
  ) {

    Color color;

    switch (status.toLowerCase()) {

      case "dibayar":
        color = Colors.green;
        break;

      case "pending":
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
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildOrderStatus(
    String status,
  ) {

    Color color;

    switch (status.toLowerCase()) {

      case "diproses":
        color = Colors.blue;
        break;

      case "selesai":
        color = Colors.green;
        break;

      case "dibatalkan":
        color = Colors.red;
        break;

      case "menunggu_pembayaran":
        color = Colors.orange;
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
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}