import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_services.dart';
import 'providers/user_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? const LoadingPage()
          : HomePage(isAdmin: (Provider.of<UserProvider>(context).user.role == "Admin")),
    );
  }
}