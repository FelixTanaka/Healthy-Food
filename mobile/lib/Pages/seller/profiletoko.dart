import 'package:flutter/material.dart';
import 'package:mobile/widgets/editprofile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileToko extends StatefulWidget {
  const ProfileToko({super.key});

  @override
  State<ProfileToko> createState() => ProfileTokoState();
}

class ProfileTokoState extends State<ProfileToko> {
  String namaToko = "";
  String deskripsi = "";
  String alamat = "";
  String jamBuka = "";
  String jamTutup = "";
  String fotoToko = "";

  @override
  void initState() {
    super.initState();

    getSellerProfile();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  Future<void> getSellerProfile() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/api/seller/profile"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        namaToko = data['data']['nama_toko'] ?? "";
        deskripsi = data['data']['deskripsi'] ?? "";
        alamat = data['data']['alamat'] ?? "";
        jamBuka = data['data']['jam_buka'] ?? "";
        jamTutup = data['data']['jam_tutup'] ?? "";
        fotoToko = data['data']['foto_toko'] ?? "";
      });
    }
  }

  Future<void> updateSellerProfile(
    Map<String, dynamic> body,
  ) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/api/seller/profile"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: data['message'],
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Gagal update profile toko",
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    String? token = await getToken();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiService.baseUrl}/api/seller/upload-photo"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_toko',
        imageFile.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Foto toko berhasil diupload",
      );

      getSellerProfile();
    } else {
      Fluttertoast.showToast(
        msg: "Gagal upload foto",
      );
    }
  }

  void showImagePickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Kamera"),
                onTap: () {
                  Navigator.pop(context);

                  pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Galeri"),
                onTap: () {
                  Navigator.pop(context);

                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildItem({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orangeAccent),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                showImagePickerOption();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orangeAccent,
                backgroundImage: fotoToko.isNotEmpty
                    ? NetworkImage(
                        "${ApiService.baseUrl}/storage/$fotoToko",
                      )
                    : null,
                child: fotoToko.isEmpty
                    ? Text(
                        namaToko.isNotEmpty
                            ? namaToko[0].toUpperCase()
                            : "T",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              namaToko,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            buildItem(
              label: "Nama Toko",
              value: namaToko,
              icon: Icons.store,
              onTap: () {
                showEditField(context, "Nama Toko", namaToko, (value) {
                  setState(() {
                    namaToko = value;
                  });

                  updateSellerProfile({
                    "nama_toko": value,
                  });
                });
              },
            ),

            buildItem(
              label: "Deskripsi Toko",
              value: deskripsi,
              icon: Icons.description,
              onTap: () {
                showEditField(context, "Deskripsi", deskripsi, (value) {
                  setState(() {
                    deskripsi = value;
                  });
                  updateSellerProfile({
                    "deskripsi": value,
                  });
                });
              },
            ),

            buildItem(
              label: "Alamat",
              value: alamat,
              icon: Icons.location_on,
              onTap: () {
                showEditField(context, "Alamat", alamat, (value) {
                  setState(() {
                    alamat = value;
                  });
                  updateSellerProfile({
                    "alamat": value,
                  });
                });
              },
            ),

            buildItem(
              label: "Jam Buka",
              value: jamBuka,
              icon: Icons.access_time,
              onTap: () {
                showEditField(context, "Jam Buka", jamBuka, (value) {
                  setState(() {
                    jamBuka = value;
                  });
                  updateSellerProfile({
                    "jam_buka": value,
                  });
                });
              },
            ),

            buildItem(
              label: "Jam Tutup",
              value: jamTutup,
              icon: Icons.access_time_filled,
              onTap: () {
                showEditField(context, "Jam Tutup", jamTutup, (value) {
                  setState(() {
                    jamTutup = value;
                  });
                  updateSellerProfile({
                    "jam_tutup": value,
                  });
                });
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}