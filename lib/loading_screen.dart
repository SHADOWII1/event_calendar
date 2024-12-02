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
    await Future.delayed(const Duration(seconds: 3)); // Wait for 1 second
    _navigateToLogin(); // Navigate to login page after delay
  }

  // Function to navigate to LoginPage with slide-up animation
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define the slide animation
          const begin = Offset(0.0, 1.0); // Start from bottom (y: 1.0)
          const end = Offset.zero; // End at original position (0.0, 0.0)
          const curve = Curves.easeInOut; // Animation curve

          // Create a tween to animate the position of the slide
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Apply the SlideTransition with the offset animation
          return SlideTransition(
            position: offsetAnimation,  // The actual transition movement
            child: child,               // The content to transition
          );
        },
      ),
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
              color: Color.fromRGBO(0, 116, 217, 1.0), // RGB background color
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/academic-calendar-high-resolution-logo.png"), // Background image path
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
