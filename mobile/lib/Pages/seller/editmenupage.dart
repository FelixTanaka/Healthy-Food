import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class EditMenuPage extends StatefulWidget {

  final Map<String, dynamic> item;

  const EditMenuPage({
    super.key,
    required this.item,
  });

  @override
  State<EditMenuPage> createState() => EditMenuPageState();
}

class EditMenuPageState extends State<EditMenuPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();

  String? selectedKategori;

  File? selectedImage;

  List kategoriList = [];

  @override
  void initState() {
    super.initState();
    getKategori();
    nameController.text =
        widget.item["nama_makanan"];

    priceController.text =
        widget.item["harga"].toString();

    descController.text =
        widget.item["deskripsi"];

    selectedKategori =
        widget.item["kategori_id"].toString();

    bahanController.text =
      widget.item["bahan"] ?? "";
  }

  Future<void> updateMenu() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString("token");

      var request = http.MultipartRequest(

        "POST",

        Uri.parse(
          "${ApiService.baseUrl}/api/makanan/${widget.item["id"]}",
        ),
      );

      request.headers.addAll({

        "Authorization": "Bearer $token",

        "Accept": "application/json",

      });

      request.fields["nama_makanan"] =
          nameController.text;

      request.fields["harga"] =
          priceController.text;

      request.fields["deskripsi"] =
          descController.text;

      request.fields["kategori_id"] =
          selectedKategori ?? "";

      if (bahanController.text.isNotEmpty) {

        request.fields["bahan"] =
            bahanController.text;

      }

      if (selectedImage != null) {

        request.files.add(

          await http.MultipartFile.fromPath(

            "gambar_makanan",

            selectedImage!.path,

          ),

        );
      }

      var response =
          await request.send();

      var responseBody =
          await response.stream.bytesToString();

      debugPrint(responseBody);

      final data =
          jsonDecode(responseBody);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(

          msg: data["message"],

        );

        if (!mounted) return;

        Navigator.pop(context, true);

      } else {

        Fluttertoast.showToast(

          msg: "Gagal update menu",

        );

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> getKategori() async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString("token");

      final response = await http.get(

        Uri.parse(
          "${ApiService.baseUrl}/api/kategori",
        ),

        headers: {

          "Accept": "application/json",

          "Authorization": "Bearer $token",

        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {

          kategoriList =
              data["data"];

        });

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> pickImage() async {

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {

      setState(() {
        selectedImage = File(pickedFile.path);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Edit Menu"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            GestureDetector(
              onTap: () {
                pickImage();
              },

              child: Container(
                height: 180,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),

                child: selectedImage != null

                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),

                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )

                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),

                        child: Image.network(
                          "${ApiService.baseUrl}/storage/${widget.item["gambar_makanan"]}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,

              decoration: InputDecoration(
                labelText: "Nama Makanan",
                hintText: "Masukkan nama makanan",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: "Harga",
                hintText: "Masukkan harga",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descController,
              maxLines: 3,

              decoration: InputDecoration(
                labelText: "Deskripsi",
                hintText: "Jelaskan makanan",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              initialValue: selectedKategori,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: "Kategori",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: kategoriList.map((kategori) {

                return DropdownMenuItem(
                  value: kategori["id"].toString(),

                  child: Text(
                    kategori["nama_kategori"],
                  ),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedKategori = value.toString();
                });

              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: bahanController,
              maxLines: 4,

              decoration: InputDecoration(
                labelText: "Bahan Makanan",
                hintText: "Masukkan bahan makanan",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],

                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      updateMenu();
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,

                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Update",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}