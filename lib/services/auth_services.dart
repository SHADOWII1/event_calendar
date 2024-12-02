import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_calendar/providers/user_provider.dart';
import '../home_screen.dart';
import '../utils/utils.dart';
import '../login_screen.dart';


class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/api/auth';

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
      Uri.parse('$baseUrl/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: {'Content-Type': 'application/json'},
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          // get instence of SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var userJson = jsonDecode(res.body);
          var user = userJson['user'];

          userProvider.setUser(jsonEncode(user));
          print('User Encoded: ${jsonEncode(user)}');
          await prefs.setString("x-auth-token", userJson["token"]);
          navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(isAdmin: (userProvider.user.role == "Admin")),
              ),
                  (route) => false);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user Data
  void getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("x-auth-token");

      if (token == null) {
        prefs.setString("x-auth-token", "");
      }

      var tokenRes = await http.post(
        Uri.parse('$baseUrl/tokenIsValid'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token!,
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse("$baseUrl/"),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            "x-auth-token": token,
          },
        );
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // SIGN OUT
  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("x-auth-token", "");
    navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
            (route) => false);
  }
}