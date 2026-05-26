import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthViewModel
    extends ChangeNotifier {

  UserModel? user;

  bool get isLogged =>
      user != null;

  void setUser(
      UserModel newUser,
      ) {

    user = newUser;

    notifyListeners();
  }

  void logout() {

    user = null;

    notifyListeners();
  }
}