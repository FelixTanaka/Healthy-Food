import 'package:flutter/material.dart';
import 'package:mobile/Pages/registerpage.dart';
import 'package:mobile/Pages/homepage.dart';
import 'package:mobile/Pages/seller/homepage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool isPasswordHidden = true;

    Future<void> login() async {
      try {
        final response = await http.post(
          Uri.parse("${ApiService.baseUrl}/api/login"),
          headers: {
            "Accept": "application/json",
          },
          body: {
            "email": emailController.text,
            "password": passwordController.text,
          },
        );

        if (!mounted) return;

        final data = jsonDecode(response.body);

        debugPrint(response.body);
        debugPrint(response.statusCode.toString());

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);

          final user = data['user'];

          String role = user['role']['nama_role'];

          Fluttertoast.showToast(
            msg: "Login berhasil 🎉",
          );

          if (role == "pembeli") {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PembeliHomePage(),
              ),
            );

          } else if (role == "seller") {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerHomePage(),
              ),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Login gagal",
          );
        }
      } catch (e) {
        debugPrint("ERROR: $e");
      }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/download.jpg"),
                    fit: BoxFit.cover,
                    ),
                ),
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Image.asset(
                              "assets/images/Logo.png",
                              width: 210,
                              color: Colors.orangeAccent,
                              colorBlendMode: BlendMode.srcIn,
                            ),

                            const Text(
                              "Health Bites",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 30),
                            
                            TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "nama@gmail.com",

                                  filled: true, 
                                  fillColor: Colors.white,

                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                ),
                            ),

                            const SizedBox(height: 20),

                            TextField(
                                controller: passwordController,
                                obscureText: isPasswordHidden,
                                decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Masukkan password",
                                filled: true, 
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock),

                                suffixIcon: IconButton(
                                    icon: Icon(
                                    isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    ),
                                    onPressed: () {
                                    setState(() {
                                        isPasswordHidden = !isPasswordHidden;
                                    });
                                    },
                                ),
                                ),
                            ),

                            const SizedBox(height: 30),

                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(45),
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  login();
                                },
                                child: const Text("Login", style: TextStyle(fontSize: 16),),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Belum punya akun?", style: TextStyle(color: Colors.white),),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text("Register", style: TextStyle(color: Colors.orangeAccent)),
                                ),
                              ],
                            )
                        ],
                    )
                ),
            )
        )
      );
    }
}
