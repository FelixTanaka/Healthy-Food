import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Pages/seller/homepage.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LengkapiProfileTokoPage extends StatefulWidget {
  const LengkapiProfileTokoPage({super.key});

  @override
  State<LengkapiProfileTokoPage> createState() =>
      _LengkapiProfileTokoPageState();
}

class _LengkapiProfileTokoPageState
    extends State<LengkapiProfileTokoPage> {

  final namaTokoController =
      TextEditingController();

  final deskripsiController =
      TextEditingController();

  final alamatController =
      TextEditingController();

  double? latitude;
  double? longitude;

  Future<List<dynamic>> searchAlamat(
    String query,
  ) async {

    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query,Yogyakarta&format=jsonv2&limit=10&countrycodes=id",
      ),
      headers: {
        "User-Agent": "HealthBites",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  Future<void> simpanProfile() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/api/seller/profile",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "nama_toko":
              namaTokoController.text,
          "deskripsi":
              deskripsiController.text,
          "alamat":
              alamatController.text,
          "latitude":
              latitude?.toString() ?? "",
          "longitude":
              longitude?.toString() ?? "",
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg:
              "Profile toko berhasil disimpan 🎉",
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SellerHomePage(),
          ),
        );

      } else {

        Fluttertoast.showToast(
          msg: "Gagal menyimpan profile",
        );

        debugPrint(response.body);
      }

    } catch (e) {

      debugPrint(
        e.toString(),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Lengkapi Profile Toko",
        ),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 20),

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store,
                  size: 60,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Lengkapi Profil Toko",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Lengkapi informasi toko Anda sebelum mulai berjualan di Health Bites",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    TextField(
                      controller: namaTokoController,
                      decoration: InputDecoration(
                        labelText: "Nama Toko",
                        prefixIcon: const Icon(Icons.store),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: deskripsiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Deskripsi Toko",
                        prefixIcon:
                            const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TypeAheadField<dynamic>(
                      controller: alamatController,

                      suggestionsCallback:
                          (pattern) async {
                        return await searchAlamat(
                          pattern,
                        );
                      },

                      decorationBuilder:
                          (context, child) {
                        return Material(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          elevation: 4,
                          child: child,
                        );
                      },

                      builder: (
                        context,
                        controller,
                        focusNode,
                      ) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Alamat Toko",
                            prefixIcon: const Icon(
                              Icons.location_on,
                            ),
                            filled: true,
                            fillColor:
                                Colors.grey.shade50,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        );
                      },

                      itemBuilder:
                          (context, suggestion) {
                        return Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.orange,
                            ),
                            title: Text(
                              suggestion[
                                  "display_name"],
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },

                      onSelected: (suggestion) {

                        alamatController.text =
                            suggestion[
                                "display_name"];

                        latitude =
                            double.tryParse(
                          suggestion["lat"],
                        );

                        longitude =
                            double.tryParse(
                          suggestion["lon"],
                        );

                        setState(() {});
                      },
                    ),

                    if (latitude != null)
                      Container(
                        margin:
                            const EdgeInsets.only(
                          top: 16,
                        ),
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Lokasi toko berhasil dipilih",
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orangeAccent,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  onPressed: () {

                    if (namaTokoController
                            .text
                            .isEmpty ||
                        deskripsiController
                            .text
                            .isEmpty ||
                        alamatController
                            .text
                            .isEmpty) {

                      Fluttertoast.showToast(
                        msg:
                            "Lengkapi semua data terlebih dahulu",
                      );

                      return;
                    }

                    simpanProfile();
                  },
                  child: const Text(
                    "Simpan Profil Toko",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}