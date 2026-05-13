import 'package:flutter/material.dart';
import 'package:mobile/components/seller/navbar.dart';
import 'package:mobile/components/seller/appbar.dart';
import 'package:mobile/Pages/seller/profiletoko.dart';
import 'package:mobile/Pages/seller/homecontent.dart';
import 'package:mobile/Pages/seller/pesananpage.dart';

class SellerHomePage extends StatefulWidget {
  final int initialIndex;

  const SellerHomePage({super.key, this.initialIndex = 0});

  @override
  State<SellerHomePage> createState() => SellerHomePageState();
  
}

class SellerHomePageState extends State<SellerHomePage> {
   int selectedIndex = 0;

  final List<Widget> pages = const [
    MenuPage(),
    PesananPage(),
    ProfileToko(),
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