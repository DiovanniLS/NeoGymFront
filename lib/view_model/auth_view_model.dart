import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../storage/token_storage.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? user;

  bool get isLogged => user != null;

  void setUser(UserModel newUser) {
    user = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    // Remove o token usado nas requisições da API.
    await TokenStorage.deleteAccessToken();

    // Limpa o usuário da sessão local do aplicativo.
    user = null;
    notifyListeners();

    // Encerra também a sessão do Firebase, utilizada pelo chat.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Erro ao encerrar sessão do Firebase: $e');
    }
  }
}