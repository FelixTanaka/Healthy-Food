import 'package:flutter/material.dart';
import 'package:mobile/Pages/loginpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    bool isPasswordHidden = true;

    final FToast fToast = FToast();
    
    @override
    void initState() {
      super.initState();
      fToast.init(context);
    }

    Future<void> register() async {
      try {
        final url = Uri.parse(
          "${ApiService.baseUrl}/api/register-pembeli"
        );

        final response = await http.post(
          url,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "username": usernameController.text,
            "email": emailController.text,
            "no_telp": phoneController.text,
            "password": passwordController.text,
          }),
        );

        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");

        if (!mounted) return;

        if (response.statusCode == 200 ||
          response.statusCode == 201) {

          Fluttertoast.showToast(
            msg: "Register berhasil 🎉",
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          });
        } else {
          Fluttertoast.showToast(
            msg: "Register gagal ❌",
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
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              hintText: "Masukkan username",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                            
                            const SizedBox(height: 20),

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
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "No Telepon",
                                hintText: "08xxxxxxxxxx",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone),
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
                                  register();
                                },
                                child: const Text("Register", style: TextStyle(fontSize: 16),),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Sudah punya akun?", style: TextStyle(color: Colors.white),),
                                const SizedBox(width: 6),
                                TextButton(
                                   style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text("Login", style: TextStyle(color: Colors.orangeAccent)),
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
