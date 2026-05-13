import 'package:flutter/material.dart';
import '../widgets/editprofile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => AlamatPageState();
}

class AlamatPageState extends State<AlamatPage> {
  List<dynamic> alamatList = [];

  Future<void> getAlamat() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/alamat"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          alamatList = data['data'];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getAlamat();
  }

  Future<void> updateAlamat(int id, String alamatBaru) async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse("${ApiService.baseUrl}/api/alamat/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "alamat": alamatBaru,
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
        getAlamat();
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAlamat(int id) async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse("${ApiService.baseUrl}/api/alamat/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: "Alamat berhasil dihapus 🗑️",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        getAlamat();

      } else {

        Fluttertoast.showToast(
          msg: "Gagal menghapus alamat",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> tambahAlamatApi(String alamat) async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/alamat"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "alamat": alamat,
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

        getAlamat();

      } else {

        Fluttertoast.showToast(
          msg: "Gagal menambahkan alamat",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void tambahAlamat() {
    TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 400),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tambah Alamat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Masukkan alamat",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orangeAccent),
                            foregroundColor: Colors.black, 
                          ),
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (controller.text.isEmpty) return;

                            setState(() {
                              alamatList.add({
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'alamat': controller.text,
                              });
                            }); 

                            tambahAlamatApi(
                              controller.text,
                            );

                            Navigator.pop(context); 
                          },
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Alamat Saya",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: alamatList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                      alamatList[index]['alamat'],
                      style: const TextStyle(fontSize: 14),
                    ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showEditField(
                          context,
                          "Alamat",
                          alamatList[index]['alamat'],
                          (value) {
                            setState(() {
                              alamatList[index]['alamat'] = value;
                            });
                            updateAlamat(
                              alamatList[index]['id'],
                              value,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {
                        
                        deleteAlamat(
                          alamatList[index]['id'],
                        );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white, 
        elevation: 4,
        onPressed: tambahAlamat,
        child: const Icon(Icons.add),
      ),
    );
  }
}