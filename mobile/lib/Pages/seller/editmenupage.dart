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
  List<Map<String, dynamic>> bahanList = [];

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

    if (widget.item["bahan"] != null) {

      List data = jsonDecode(
        widget.item["bahan"],
      );

      bahanList =
        List<Map<String, dynamic>>.from(
      data.map((item) {

        return {
          "ingredient": {
            "nama_indonesia":
                item["nama_indonesia"],
            "nama_inggris":
                item["nama_inggris"],
            "spoonacular_id":
                item["spoonacular_id"],
          },

          "unit":
              item["unit"],

          "amount":
              item["amount"].toString(),

          "units": [],
        };
      }),
    );

      loadExistingUnits(); 
    }
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

      List finalBahan =
        bahanList.map((item) {

      return {

        "nama_indonesia":
            item['ingredient']['nama_indonesia'],

        "nama_inggris":
            item['ingredient']['nama_inggris'],

        "spoonacular_id":
            item['ingredient']['spoonacular_id'],

        "unit":
            item['unit'],

        "amount":
            item['amount'],
      };

    }).toList();

    request.fields["bahan"] =
        jsonEncode(finalBahan);

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

  Future<void> loadExistingUnits() async {

    for (var item in bahanList) {

      if(item['ingredient'] != null){

        item['units'] = await getUnits(
          item['ingredient']['spoonacular_id'],
        );

      }
    }

    setState(() {});
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

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  void tambahFieldBahan() {
    setState(() {
      bahanList.add({
        "ingredient": null,
        "units": [],
        "unit": null,
        "amount": "",
      });
    });
  }

  Future<List> searchIngredients(String keyword) async {

    String? token = await getToken();

    final response = await http.get(
      Uri.parse(
        "${ApiService.baseUrl}/api/ingredients/search?q=$keyword",
      ),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['data'];
    }

    return [];
  }

  Future<Map<String,dynamic>?> showIngredientDialog() async {

    TextEditingController controller =
        TextEditingController();

    List results = [];

    return showDialog<Map<String,dynamic>>(
      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setModalState) {

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Cari Bahan",
              ),

              content: SizedBox(
                width: double.maxFinite,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: controller,

                      decoration:
                          const InputDecoration(
                        hintText: "Ketik bahan...",
                      ),

                      onChanged: (value) async {

                        if(value.length < 2){
                          return;
                        }

                        final data =
                            await searchIngredients(
                              value,
                            );

                        setModalState(() {
                          results = data;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,

                        itemBuilder:
                            (context,index){

                          return ListTile(

                            title: Text(
                              results[index]
                              ['nama_indonesia'],
                            ),

                            onTap: () {

                              Navigator.pop(
                                context,
                                results[index],
                              );

                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List> getUnits(int ingredientId) async {

    String? token = await getToken();

    final response = await http.get(
      Uri.parse(
        "${ApiService.baseUrl}/api/ingredients/$ingredientId/units",
      ),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      return data['data'];
    }

    return [];
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

            Column(
              children: [

                ...bahanList.asMap().entries.map((entry) {

                  int index = entry.key;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [

                                      Text(
                                        "Bahan ${index + 1}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      if (bahanList.length > 1)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {

                                            setState(() {

                                              bahanList.removeAt(index);

                                            });

                                          },
                                        ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),

                                      title: Text(
                                        bahanList[index]['ingredient'] == null
                                            ? "Pilih Bahan"
                                            : bahanList[index]['ingredient']
                                                is Map<String, dynamic>
                                                ? bahanList[index]['ingredient']
                                                    ['nama_indonesia']
                                                : bahanList[index]['ingredient']
                                                    .toString(),

                                        style: TextStyle(
                                          color:
                                              bahanList[index]['ingredient'] == null
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),

                                      trailing: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),

                                      onTap: () async {

                                        final result =
                                            await showIngredientDialog();

                                        if (result != null) {

                                          List units = await getUnits(
                                            result['spoonacular_id'],
                                          );

                                          setState(() {

                                            bahanList[index]['ingredient'] = {
                                              "nama_indonesia":
                                                  result['nama_indonesia'],
                                              "nama_inggris":
                                                  result['nama_inggris'],
                                              "spoonacular_id":
                                                  result['spoonacular_id'],
                                            };

                                            bahanList[index]['units'] = units;

                                            bahanList[index]['unit'] =
                                                units.isNotEmpty
                                                    ? units.first
                                                    : null;

                                          });

                                        }

                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  DropdownButtonFormField<String>(
                                    initialValue: bahanList[index]['unit'],

                                    decoration: InputDecoration(
                                      labelText: "Satuan",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,

                                    items: (bahanList[index]['units'] ?? [])
                                        .map<DropdownMenuItem<String>>(
                                      (unit) {

                                        return DropdownMenuItem<String>(
                                          value: unit.toString(),
                                          child: Text(
                                            unit.toString(),
                                          ),
                                        );

                                      },
                                    ).toList(),

                                    onChanged: (value) {

                                      setState(() {

                                        bahanList[index]['unit'] = value;

                                      });

                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  TextFormField(
                                    initialValue: bahanList[index]['amount'],

                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),

                                    decoration: InputDecoration(
                                      labelText: "Jumlah",
                                      hintText: "Contoh: 100",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    onChanged: (value) {

                                      bahanList[index]['amount'] = value;

                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: tambahFieldBahan,
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Bahan"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

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