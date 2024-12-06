import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_services.dart';
import 'providers/user_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'profile_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // Existing provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Academic Calendar',
      theme: themeProvider.currentTheme,
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? const LoadingPage()
          : HomePage(isAdmin: (Provider.of<UserProvider>(context).user.role == "Admin")),
    );
  }
}