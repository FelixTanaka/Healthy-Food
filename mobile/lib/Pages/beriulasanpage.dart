import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BeriUlasanPage extends StatefulWidget {

  final List<dynamic> orderItems;


  final dynamic rating;

  const BeriUlasanPage({
    super.key,
    required this.orderItems,
    this.rating,
  });

  @override
  State<BeriUlasanPage> createState() => _BeriUlasanPageState();
}

class _BeriUlasanPageState extends State<BeriUlasanPage> {

  final Map<int, int> ratings = {};

  final Map<int, TextEditingController> komentarControllers = {};

  @override
  void initState() {
    super.initState();

    for (var item in widget.orderItems) {

      final itemId = item["id"];

      ratings[itemId] =
          widget.rating?["nilai"] ?? 0;

      komentarControllers[itemId] =
          TextEditingController(
            text:
              widget.rating?["komentar"] ?? "",
          );
    }
  }

  Future<void> kirimUlasan() async {

    try {

      final prefs =
          await SharedPreferences
              .getInstance();

      final token =
          prefs.getString("token");

      for (var item
          in widget.orderItems) {

        http.Response response;

        if (widget.rating == null) {

          response = await http.post(

            Uri.parse(
              "${ApiService.baseUrl}/api/rating",
            ),

            headers: {

              "Accept":
                  "application/json",

              "Authorization":
                  "Bearer $token",
            },

            body: {

              "order_item_id":
                  item["id"].toString(),

              "nilai":
                  (ratings[item["id"]] ?? 0)
                      .toString(),

              "komentar":
                  komentarControllers[
                          item["id"]]
                      ?.text ??
                  "",
            },
          );

        } else {

          response = await http.put(

            Uri.parse(
              "${ApiService.baseUrl}/api/rating/${widget.rating["id"]}",
            ),

            headers: {

              "Accept":
                  "application/json",

              "Authorization":
                  "Bearer $token",
            },

            body: {

              "nilai":
                  (ratings[item["id"]] ?? 0)
                      .toString(),

              "komentar":
                  komentarControllers[
                          item["id"]]
                      ?.text ??
                  "",
            },
          );
        }

        final data =
            jsonDecode(response.body);

        if (response.statusCode !=
            200) {

          Fluttertoast.showToast(
            msg: data["message"],
          );

          return;
        }
      }

      Fluttertoast.showToast(
        msg:
            "Ulasan berhasil dikirim",
      );

      if (!mounted) return;

      final firstItem =
    widget.orderItems.first;

      Navigator.pop(context,{
        "nilai":
            ratings[firstItem["id"]],

        "komentar":
            komentarControllers[
                firstItem["id"]]
                ?.text,
      }
      
      );

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title:
            Text(
              widget.rating == null
                  ? "Beri Ulasan"
                  : "Edit Ulasan",
            ),

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        elevation: 0,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children:

              widget.orderItems
                  .map<Widget>((item) {

            final makanan =
                item["makanan"];

            final itemId =
                item["id"];

            return Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Container(
                  padding:
                      const EdgeInsets.all(
                          16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),

                  child: Row(
                    children: [

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                                12),

                        child: Image.network(
                          "${ApiService.baseUrl}/storage/${makanan["gambar_makanan"]}",

                          width: 80,
                          height: 80,

                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              makanan["nama_makanan"],

                              style:
                                  const TextStyle(
                                fontSize: 16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Row(
                              children: [

                                CircleAvatar(
                                  radius: 12,

                                  backgroundImage:NetworkImage(
                                    "${ApiService.baseUrl}/storage/${makanan["seller"]["foto_toko"]}",
                                  ),
                                ),

                                const SizedBox(
                                    width: 8),

                                Expanded(
                                  child: Text(
                                    makanan["seller"]["nama_toko"],

                                    overflow:
                                        TextOverflow
                                            .ellipsis,

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          13,

                                      color:
                                          Colors
                                              .grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(
                          20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      const Center(
                        child: Text(
                          "Bagaimana makanan ini ?",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      const Center(
                        child: Text(
                          "Berikan rating dan ulasan terbaikmu",

                          style: TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children:
                            List.generate(
                                5,
                                (index) {

                          return IconButton(

                            onPressed:
                                () {

                              setState(() {
                                ratings[itemId] = index + 1;
                              });
                            },

                            icon: Icon(

                              index < (ratings[itemId] ?? 0)
                                  ? Icons.star
                                  : Icons
                                      .star_border,

                              color:
                                  Colors
                                      .amber,

                              size: 38,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(
                          height: 24),

                      const Text(
                        "Ulasan",

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      TextField(
                        controller:
                            komentarControllers[itemId],

                        maxLines: 5,

                        decoration:
                            InputDecoration(

                          hintText:
                              "Tulis pengalamanmu tentang makanan ini...",

                          filled: true,

                          fillColor:
                              const Color(
                                  0xFFF5F5F5),

                          border:
                              OutlineInputBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),

                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 24),
              ],
            );
          }).toList(),
        ),
      ),

      bottomNavigationBar: Container(

        padding:
            const EdgeInsets.all(16),

        color: Colors.white,

        child: SizedBox(
          width: double.infinity,

          child: ElevatedButton(

            onPressed: () {
              kirimUlasan();
            },

            style:
                ElevatedButton
                    .styleFrom(

              backgroundColor:
                  Colors.orange,

              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 16,
              ),

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius
                        .circular(14),
              ),
            ),

            child: Text(
              widget.rating == null
              ? "Kirim Ulasan"
              : "Update Ulasan",

              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}