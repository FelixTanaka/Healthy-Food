import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => AddMenuPageState();
}

class AddMenuPageState extends State<AddMenuPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();

  List kategoriList = [];
  String? selectedKategori;

  @override
  void initState() {
    super.initState();
    getKategori();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  Future<void> getKategori() async {

    String? token = await getToken();

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/api/kategori"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      setState(() {
        kategoriList = data['data'];
      });

    }
  }

  File? selectedImage;

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

  Future<void> tambahMakanan() async {

    try {

      String? token = await getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiService.baseUrl}/api/makanan"),
      );

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields.addAll({
        "kategori_id": selectedKategori ?? "",
        "nama_makanan": nameController.text,
        "deskripsi": descController.text,
        "harga": priceController.text,
        "bahan": bahanController.text,
      });

      if (selectedImage != null) {

        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_makanan',
            selectedImage!.path,
          ),
        );

      }

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      final data = jsonDecode(responseBody);

      print(data);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: data['message'],
        );

        if (!mounted) return;

        Navigator.pop(context);

      } else {

        Fluttertoast.showToast(
          msg: data['message'] ?? "Gagal tambah makanan",
        );

      }

    } catch (e) {

       print(e.toString());

      Fluttertoast.showToast(
        msg: "Terjadi kesalahan",
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Tambah Menu"),
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
                height: 160,
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
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Upload Gambar",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nama Makanan",
                hintText: "Contoh: Nasi Goreng",
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
                hintText: "Contoh: 15000",
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
                hintText: "Jelaskan makanan...",
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
                  value: kategori['id'].toString(),
                  child: Text(kategori['nama_kategori']),
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
                hintText:
                    "Bahan Makanan",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  tambahMakanan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan Menu",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}