import 'package:flutter/material.dart';
import 'package:mobile/components/appbar.dart';
import 'package:mobile/components/navbar.dart';
import 'package:mobile/Pages/profilepage.dart';
import 'package:mobile/Pages/homecontent.dart';
import 'package:mobile/Pages/chatbotpage.dart';
import 'package:mobile/Pages/menupage.dart';
import 'package:mobile/Pages/riwayatpage.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => HomePageState();
  
}

class HomePageState extends State<HomePage> {
   int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeContent(),
    MenuPage(),
    RiwayatPage(),
    ChatPage(),
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: Appbar(),
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}