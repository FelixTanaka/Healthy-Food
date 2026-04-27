import 'package:flutter/material.dart';
import '../widgets/editprofile.dart';
import './alamatpage.dart';
import './loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String username = "felix123";
  String email = "felix@email.com";
  String noTelp = "08123456789";
  String password = "felix";
  String beratBadan = "70 kg";
  String tinggiBadan = "170 cm";
  String umur = "22 tahun";
  String jenisKelamin = "Laki Laki";
  String kalori = "2000 kcal";

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/profile.jpg"),
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
            value: password,
            icon: Icons.lock,
            onTap: () {
              showEditField(context, "Password", password, (value) {
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
              showEditField(context, "Jenis Kelamin", jenisKelamin, (value) {
                setState(() {
                  jenisKelamin = value;
                });
              });
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
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
