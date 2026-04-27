import 'package:flutter/material.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  const Appbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<Appbar> createState() => AppbarState();
}

class AppbarState extends State<Appbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              "assets/images/Logo.png",
              width: 32,
               color: Color(0xFFFF8A00),
              colorBlendMode: BlendMode.srcIn,
            ),

             const Text(
              "Health Bites",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
  }
}