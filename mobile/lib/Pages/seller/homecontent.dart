import 'package:flutter/material.dart';
import 'package:mobile/Pages/seller/detailmenupage.dart';
import 'package:mobile/Pages/seller/addmenupage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/Pages/seller/editmenupage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> menuList = [];

  List<Map<String, dynamic>> filteredMenu = [];

  TextEditingController searchController = TextEditingController();

  List<dynamic> kategoriList=[];

  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;

  @override
  void initState() {
    super.initState();
    getMenu();
    getKategori();
  }

  Future<void> pilihTanggal(bool mulai) async {

    final tanggal = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2025),

      lastDate: DateTime.now(),

    );


    if(tanggal != null){

      setState((){

        if(mulai){

          tanggalMulai = tanggal;

        }else{

          tanggalSelesai = tanggal;

        }

      });

    }

  }

  Future<void> getMenu() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/makanan"),

        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
         debugPrint(response.body);

        final data = jsonDecode(response.body);

        setState(() {

          menuList = List<Map<String, dynamic>>.from(data["data"]);


          filteredMenu =
              List<Map<String, dynamic>>.from(
                  data["data"]);

        });

      } else {

        debugPrint(response.body);

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> deleteMenu(int id) async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString("token");

      final response = await http.delete(

        Uri.parse(
          "${ApiService.baseUrl}/api/makanan/$id",
        ),

        headers: {

          "Accept": "application/json",

          "Authorization": "Bearer $token",

        },
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {

        Fluttertoast.showToast(

          msg: data["message"],

        );

        getMenu();

      } else {

        Fluttertoast.showToast(

          msg: "Gagal hapus menu",

        );

      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  void tampilkanFilterLaporan() async {
    DateTime? tempMulai = tanggalMulai;
    DateTime? tempSelesai = tanggalSelesai;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Filter Laporan"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final tgl = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (tgl != null) {
                        setStateDialog(() => tempMulai = tgl);
                      }
                    },
                    child: Text(
                      tempMulai == null
                          ? "Tanggal Mulai"
                          : "${tempMulai!.day}-${tempMulai!.month}-${tempMulai!.year}",
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      final tgl = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (tgl != null) {
                        setStateDialog(() => tempSelesai = tgl);
                      }
                    },
                    child: Text(
                      tempSelesai == null
                          ? "Tanggal Selesai"
                          : "${tempSelesai!.day}-${tempSelesai!.month}-${tempSelesai!.year}",
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () {
                    tanggalMulai = tempMulai;
                    tanggalSelesai = tempSelesai;

                    Navigator.pop(context);
                    cetakLaporanSemuaKategori();
                  },
                  child: const Text("Cetak PDF"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void searchMenu(String value) {

    setState(() {

      filteredMenu =
          menuList.where((item) {

        final nama =
            item["nama_makanan"]
                .toString()
                .toLowerCase();

        final harga =
            item["harga"]
                .toString()
                .toLowerCase();

        final rating =

            item["ratings_avg_nilai"] == null

                ? "0"

                : double.parse(
                    item[
                      "ratings_avg_nilai"]
                      .toString(),
                  ).toStringAsFixed(1);

        final query =
            value.toLowerCase();

        return

            nama.contains(query) ||

            harga.contains(query) ||

            rating.contains(query);
      }).toList();
    });
  }

  Future<List<dynamic>> getLaporanKategori({
    DateTime? mulai,
    DateTime? selesai,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    String url = "${ApiService.baseUrl}/api/seller/laporan-kategori";

    List<String> params = [];

    if (mulai != null) {
      params.add("tanggal_mulai=${mulai.toIso8601String().substring(0, 10)}");
    }

    if (selesai != null) {
      params.add("tanggal_selesai=${selesai.toIso8601String().substring(0, 10)}");
    }

    if (params.isNotEmpty) {
      url += "?${params.join("&")}";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["data"] ?? [];
    }

    return [];
  }

  Future<void> cetakLaporanSemuaKategori() async {
    try {
      final laporan = await getLaporanKategori(
        mulai: tanggalMulai,
        selesai: tanggalSelesai,
      );

      if (laporan.isEmpty) {
        Fluttertoast.showToast(msg: "Tidak ada data laporan");
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  "Laporan Semua Kategori",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  "Periode: "
                  "${tanggalMulai == null ? '-' : '${tanggalMulai!.day}-${tanggalMulai!.month}-${tanggalMulai!.year}'}"
                  " s/d "
                  "${tanggalSelesai == null ? '-' : '${tanggalSelesai!.day}-${tanggalSelesai!.month}-${tanggalSelesai!.year}'}",
                ),

                pw.SizedBox(height: 20),

                pw.TableHelper.fromTextArray(
                  headers: [
                    "No",
                    "Kategori",
                    "Total Menu",
                    "Terjual",
                    "Pendapatan",
                  ],
                  data: List.generate(laporan.length, (index) {
                    final item = laporan[index];

                    return [
                      "${index + 1}",
                      item["kategori"] ?? "-",
                      item["jumlah_menu"].toString(),
                      item["jumlah_terjual"].toString(),
                      item["total_pendapatan"].toString(),
                    ];
                  }),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/laporan_kategori.pdf");

      await file.writeAsBytes(await pdf.save());

      OpenFilex.open(file.path);

    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: "Gagal membuat PDF");
    }
  }

  Future<void> getKategori() async{


    final prefs =
    await SharedPreferences.getInstance();

    String? token =
    prefs.getString("token");


    final response =
    await http.get(

    Uri.parse(
    "${ApiService.baseUrl}/api/kategori"
    ),

    headers:{
    "Authorization":"Bearer $token"
    }

    );


    if(response.statusCode==200){

    setState((){

    kategoriList =
    jsonDecode(response.body)["data"];

    });

    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton.icon(

                    onPressed: (){

                        tampilkanFilterLaporan();

                    },
                    


                    icon:
                    const Icon(
                      Icons.picture_as_pdf
                    ),


                    label:
                    const Text(
                      "Cetak Laporan Kategori"
                    ),


                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.orangeAccent,


                      foregroundColor:
                      Colors.white,


                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(12)

                      ),

                    ),

                  ),

                ),

                const SizedBox(
                  height: 10
                ),
                
                 Row(

                  children: [


                    Expanded(

                      child: TextField(

                        controller:
                        searchController,


                        onChanged:
                        searchMenu,


                        decoration:
                        InputDecoration(

                          hintText:
                          "Cari menu...",


                          prefixIcon:
                          const Icon(
                            Icons.search
                          ),


                          filled:
                          true,


                          fillColor:
                          Colors.white,


                          border:
                          OutlineInputBorder(

                            borderRadius:
                            BorderRadius.circular(12),


                            borderSide:
                            BorderSide.none,

                          ),

                        ),

                      ),

                    ),



                    const SizedBox(
                      width: 10
                    ),



                    GestureDetector(

                      onTap: () async {


                        final result =
                        await Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                            AddMenuPage(),

                          ),

                        );


                        if(result == true){

                          getMenu();

                        }


                      },


                      child: Container(

                        padding:
                        const EdgeInsets.all(12),


                        decoration:
                        BoxDecoration(

                          color:
                          Colors.orangeAccent,


                          borderRadius:
                          BorderRadius.circular(12),

                        ),


                        child:
                        const Icon(

                          Icons.add,

                          color:
                          Colors.white,

                        ),

                      ),

                    )

                  ],

                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final item = filteredMenu[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailMenuPage(item: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12),

                            child: Image.network(

                              "${ApiService.baseUrl}/storage/${item["gambar_makanan"]}",

                              width: 90,
                              height: 90,

                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  item["nama_makanan"],

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Rp ${item["harga"]}",

                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,

                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(

                                      item["ratings_avg_nilai"]
                                              == null

                                          ? "0.0"

                                          : double.parse(
                                              item[
                                                  "ratings_avg_nilai"]
                                                  .toString(),
                                            ).toStringAsFixed(1),

                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      "(${item["ratings_count"]})",

                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [

                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                ),

                                onPressed: () async {

                                  final result =
                                      await Navigator.push(

                                    context,

                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditMenuPage(
                                        item: item,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    getMenu();
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () {
                                  deleteMenu(item["id"]);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget buildStatusMenu(
    String status,
  ) {

    Color color;

    switch (status) {

      case "dikonfirmasi":
        color = Colors.green;
        break;

      case "pending":
        color = Colors.orange;
        break;

      case "ditolak":
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget filterLaporan(){

    return Column(

      children: [
        Row(

          children:[


            Expanded(

              child:ElevatedButton(

                onPressed:(){

                  pilihTanggal(true);

                },

                child:Text(

                  tanggalMulai==null

                  ?"Tanggal Mulai"

                  :"${tanggalMulai!.day}-${tanggalMulai!.month}-${tanggalMulai!.year}"

                ),

              ),

            ),



            const SizedBox(width:10),



            Expanded(

              child:ElevatedButton(

                onPressed:(){

                  pilihTanggal(false);

                },


                child:Text(

                  tanggalSelesai==null

                  ?"Tanggal Selesai"

                  :"${tanggalSelesai!.day}-${tanggalSelesai!.month}-${tanggalSelesai!.year}"

                ),

              ),

            )


          ],

        )


      ],

    );

  }
}