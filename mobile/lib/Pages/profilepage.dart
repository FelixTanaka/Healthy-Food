import 'package:flutter/material.dart';
import '../widgets/editprofile.dart';
import './alamatpage.dart';
import './loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "";
  String noTelp = "";
  String password = "";
  String beratBadan = "";
  String tinggiBadan = "";
  String umur = "";
  String jenisKelamin = "";

  File? profileImage;

  String profile = "";

  Future<void> getProfile() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final user = data['data'];

        setState(() {
          username = user['username'];
          email = user['email'];
          noTelp = user['no_telp'];
          password = user['password'];
          profile = user['profile'];
        });

      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    getHealthProfile();
  }

  Future<void> updateProfile({
    String? usernameBaru,
    String? emailBaru,
    String? noTelpBaru,
    String? passwordBaru,
  }) async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse("${ApiService.baseUrl}/api/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          if (usernameBaru != null) "username": usernameBaru,
          if (emailBaru != null) "email": emailBaru,
          if (noTelpBaru != null) "no_telp": noTelpBaru,
          if (passwordBaru != null) "password": passwordBaru,
        },
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: "Profile berhasil diupdate 🎉",
        );

      } else {

        Fluttertoast.showToast(
          msg: "Gagal update profile",
        );

      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getHealthProfile() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/health-profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final health = data['data'];

        setState(() {
          beratBadan = health['berat'].toString();
          tinggiBadan = health['tinggi'].toString();
          umur = health['umur'].toString();

          jenisKelamin = health['jenis_kelamin'];
        });
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateHealthProfile({
    String? berat,
    String? tinggi,
    String? umurBaru,
    String? jenisKelaminBaru,
  }) async {

    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse("${ApiService.baseUrl}/api/health-profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          if (berat != null) "berat": berat,
          if (tinggi != null) "tinggi": tinggi,
          if (umurBaru != null) "umur": umurBaru,
          if (jenisKelaminBaru != null)
            "jenis_kelamin": jenisKelaminBaru,
        },
      );

      if (response.statusCode == 200) {

        getHealthProfile();

        Fluttertoast.showToast(
          msg: "Health profile berhasil diupdate 🎉",
        );

      } else {

        Fluttertoast.showToast(
          msg: "Gagal update health profile",
        );

      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget buildProfileItem({
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

  Future<void> pickImage() async {

    var status =
        await Permission.photos.request();

    if (!status.isGranted) {

      Fluttertoast.showToast(
        msg: "Permission galeri ditolak",
      );

      return;
    }

    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {

      setState(() {
        profileImage =
            File(pickedFile.path);
      });

      uploadProfileImage();
    }
  }

  Future<void> uploadProfileImage() async {
    if (profileImage == null) {
      return;
    }

    try {

      final prefs =
          await SharedPreferences.getInstance();

      String? token =
          prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "${ApiService.baseUrl}/api/upload-profile-image",
        ),
      );

      request.headers['Authorization'] =
          "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile',
          profileImage!.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {

        var responseData =
            await response.stream.bytesToString();

        var data = jsonDecode(responseData);

        setState(() {

          profile =
              data['data']['profile'];
        });

        Fluttertoast.showToast(
          msg: "Foto profile berhasil diupload 🎉",
        );
      }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> pickImageFromCamera() async {

    var status = await Permission.camera.request();

    if (!status.isGranted) {

      Fluttertoast.showToast(
        msg: "Permission kamera ditolak",
      );

      return;
    }

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {

      setState(() {
        profileImage = File(pickedFile.path);
      });

      uploadProfileImage();
    }
  }

  Future<void> logout() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {

        await prefs.remove('token');

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );

        Fluttertoast.showToast(
          msg: "Logout berhasil 👋",
        );

      } else {

        Fluttertoast.showToast(
          msg: "Logout gagal",
        );

      }

    } catch (e) {
      debugPrint(e.toString());
    }
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

                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,

                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text("Galeri"),

                            onTap: () async {

                              Navigator.pop(context);

                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );

                              pickImage();
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text("Kamera"),

                            onTap: () async {

                              Navigator.pop(context);

                               await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );

                                pickImageFromCamera();

                            },
                          ),

                        ],
                      ),
                    );
                  },
                );
              },

              child: CircleAvatar(
                radius: 50,

                backgroundColor: Colors.orange,

                backgroundImage:

                profile.isNotEmpty

                ? NetworkImage(
                    "${ApiService.baseUrl}/storage/$profile",
                  )

                : null,

                child: profile.isEmpty

                ? Text(

                    username.isNotEmpty
                    ? username[0].toUpperCase()
                    : "",

                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )

                : null,
              ),
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Profile Diri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildProfileItem(
              label: "Username",
              value: username,
              icon: Icons.person,
              onTap: () {
                showEditField(context, "Username", username, (value) {
                  updateProfile(
                    usernameBaru: value,
                  );

                  setState(() {
                    username = value;
                  });
                });
              },
            ),

            buildProfileItem(
              label: "Email",
              value: email,
              icon: Icons.email,
              onTap: () {
                showEditField(context, "Email", email, (value) {
                  updateProfile(
                    emailBaru: value,
                  );
                  setState(() {
                    email = value;
                  });
                });
              },
            ),

           buildProfileItem(
            label: "No Telp",
            value: noTelp,
            icon: Icons.phone,
            onTap: () {
              showEditField(context, "No Telp", noTelp, (value) {
                updateProfile(
                  noTelpBaru: value,
                );

                setState(() {
                  noTelp = value;
                });
              });
            },
          ),

          buildProfileItem(
            label: "Alamat Saya",
            value: "",
            icon: Icons.location_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlamatPage(),
                ),
              );
            },
          ),

          buildProfileItem(
            label: "Password",
            value: "********",
            icon: Icons.lock,
            onTap: () {
              showEditField(context, "Password", "", (value) {
                updateProfile(
                  passwordBaru: value,
                );

                setState(() {
                  password = value;
                });
              });
            },
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Profile Kesehatan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          buildProfileItem(
            label: "Tinggi Badan",
            value: tinggiBadan,
            icon: Icons.height,
            onTap: () {
              showEditField(context, "Tinggi Badan", tinggiBadan, (value) {
                updateHealthProfile(
                  tinggi: value,
                );

                setState(() {
                  tinggiBadan = value;
                });
              });
            },
          ),

          buildProfileItem(
            label: "Berat Badan",
            value: beratBadan,
            icon: Icons.monitor_weight,
            onTap: () {
              showEditField(context, "Berat Badan", beratBadan, (value) {
                updateHealthProfile(
                  berat: value,
                );
                setState(() {
                  beratBadan = value;
                });
              });
            },
          ),

          buildProfileItem(
            label: "Umur",
            value: umur,
            icon: Icons.cake,
            onTap: () {
              showEditField(context, "Umur", umur, (value) {
                updateHealthProfile(
                  umurBaru: value,
                );

                setState(() {
                  umur = value;
                });
              });
            },
          ),

          buildProfileItem(
            label: "Jenis Kelamin",
            value: jenisKelamin,
            icon: Icons.person_outline,
            onTap: () {

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        ListTile(
                          leading: const Icon(Icons.male),
                          title: const Text("Male"),
                          onTap: () {
                            updateHealthProfile(
                              jenisKelaminBaru: "male",
                            );

                            setState(() {
                              jenisKelamin = "male";
                            });

                            Navigator.pop(context);
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.female),
                          title: const Text("Female"),
                          onTap: () {
                            updateHealthProfile(
                              jenisKelaminBaru: "female",
                            );

                            setState(() {
                              jenisKelamin = "female";
                            });

                            Navigator.pop(context);
                          },
                        ),

                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  logout();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          ],
        )
      ),
    );
  }
}
