import 'package:flutter/material.dart';
import 'services/auth_services.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  void loginUser() {
    authService.signInUser(
        context: context,
        email: emailController.text,
        password: passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(  // Use Stack to position the background image
        children: [
          // Background Image
          Positioned.fill(  // Fill the entire screen
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login_background.png"),
                  fit: BoxFit.cover,  // Ensure image covers the screen
                ),
              ),
            ),
          ),
          // Login Form
          Center(  // Center the form content
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.white.withOpacity(0.7),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo or Illustration
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/owl.png"),
                      ),
                      const SizedBox(height: 20),
                      // Welcome Text
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Amarante',
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(240, 240, 0, 1.0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Input
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Input
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login Button
                      ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 116, 217, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Amarante',
                            color: Color.fromRGBO(255, 255, 0, 1.0),
                            
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Forgot Password and Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Navigate to Forgot Password page
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
