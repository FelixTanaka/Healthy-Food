import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/services/api_service.dart';

class TambahAlamatPage extends StatefulWidget {
  const TambahAlamatPage({super.key});

  @override
  State<TambahAlamatPage> createState() =>
      _TambahAlamatPageState();
}

class _TambahAlamatPageState
    extends State<TambahAlamatPage> {

  final TextEditingController alamatController =
      TextEditingController();

  double? latitude;
  double? longitude;

  Future<void> tambahAlamatApi() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/api/alamat",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "alamat": alamatController.text,
          "latitude": latitude?.toString() ?? "",
          "longitude": longitude?.toString() ?? "",
        },
      );

      if (response.statusCode == 201) {

        Fluttertoast.showToast(
          msg: "Alamat berhasil ditambahkan 🎉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        if (!mounted) return;
        Navigator.pop(
          context,
          true,
        );

      } else {

        Fluttertoast.showToast(
          msg: "Gagal menambahkan alamat",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        debugPrint(response.body);
      }

    } catch (e) {

      debugPrint(
        e.toString(),
      );

    }
  }

  Future<List<dynamic>> searchAlamat(String query) async {

    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query,Yogyakarta"
        "&format=jsonv2"
        "&limit=10"
        "&countrycodes=id"
      ),
      headers: {
        "User-Agent": "HealthBites",
      },
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }

    return [];
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Tambah Alamat"),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TypeAheadField<dynamic>(
              controller: alamatController,

              suggestionsCallback: (pattern) async {
                return await searchAlamat(pattern);
              },

              decorationBuilder: (context, child) {
                return Material(
                  color: Colors.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
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
                    hintText: "Cari alamat di Yogyakarta",
                    prefixIcon: const Icon(
                      Icons.location_on,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                );
              },

              itemBuilder: (
                context,
                suggestion,
              ) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                  ),
                  title: Text(
                    suggestion["display_name"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },

              onSelected: (suggestion) {

                alamatController.text =
                    suggestion["display_name"];

                latitude = double.tryParse(
                  suggestion["lat"],
                );

                longitude = double.tryParse(
                  suggestion["lon"],
                );

              },
            ),

            const SizedBox(height: 12),

            if (latitude != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Alamat berhasil dipilih",
                    ),
                  ],
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orangeAccent,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {

                  if (alamatController.text.isEmpty) {

                    Fluttertoast.showToast(
                      msg: "Pilih alamat terlebih dahulu",
                    );

                    return;
                  }

                  tambahAlamatApi();
                },
                child: const Text(
                  "Simpan Alamat",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}