import 'package:flutter/material.dart';
import 'package:mobile/Pages/registerpage.dart';
import 'package:mobile/Pages/homepage.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool isPasswordHidden = true;

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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
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
