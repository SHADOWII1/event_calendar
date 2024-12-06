import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:async';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Asynchronous function to handle the delay and navigation
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 5)); // Wait for 5 seconds
    _navigateToLogin(); // Navigate to login page after delay
  }

  // Navigate to LoginPage without animation
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Simple navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 116, 217, 1.0),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/academic-calendar-high-resolution-logo.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
