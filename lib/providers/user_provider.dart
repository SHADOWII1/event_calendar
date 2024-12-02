import 'package:flutter/cupertino.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: "",
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    role: "",
    createdAt: "",
    matriculationNumber: "",
    token: "",
  );

  User get user => _user;

  // (String user) this user is in form of JSON string
  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}