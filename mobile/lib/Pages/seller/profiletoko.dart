import 'package:flutter/material.dart';
import 'package:mobile/widgets/editprofile.dart';

class ProfileToko extends StatefulWidget {
  const ProfileToko({super.key});

  @override
  State<ProfileToko> createState() => ProfileTokoState();
}

class ProfileTokoState extends State<ProfileToko> {
  String namaToko = "Warung Felix";
  String deskripsi = "Menyediakan makanan enak dan murah";
  String alamat = "Jl. Kaliurang No. 10";
  String jamBuka = "08:00";
  String jamTutup = "22:00";

  String fotoToko = "assets/images/profile.jpg";

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
                // nanti bisa tambah image picker
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(fotoToko),
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