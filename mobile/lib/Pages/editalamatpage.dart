import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAlamatPage extends StatefulWidget {
  final int id;
  final String alamatAwal;

  const EditAlamatPage({
    super.key,
    required this.id,
    required this.alamatAwal,
  });

  @override
  State<EditAlamatPage> createState() =>
      _EditAlamatPageState();
}

class _EditAlamatPageState
    extends State<EditAlamatPage> {

  late TextEditingController alamatController;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    alamatController = TextEditingController(
      text: widget.alamatAwal,
    );
  }

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

  Future<void> updateAlamat() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      final response = await http.put(
        Uri.parse(
          "${ApiService.baseUrl}/api/alamat/${widget.id}",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "alamat": alamatController.text,
          "latitude":
              latitude?.toString() ?? "",
          "longitude":
              longitude?.toString() ?? "",
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: "Alamat berhasil diupdate 🎉",
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
          msg: "Gagal update alamat",
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text(
          "Edit Alamat",
        ),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

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
                  elevation: 4,
                  borderRadius:
                      BorderRadius.circular(12),
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
                    hintText:
                        "Cari alamat di Yogyakarta",
                    prefixIcon: const Icon(
                      Icons.location_on,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
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

            const SizedBox(height: 12),

            if (latitude != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
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
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orangeAccent,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                onPressed: () {

                  if (alamatController
                      .text
                      .isEmpty) {

                    Fluttertoast.showToast(
                      msg:
                          "Alamat tidak boleh kosong",
                    );

                    return;
                  }

                  updateAlamat();
                },
                child: const Text(
                  "Update Alamat",
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