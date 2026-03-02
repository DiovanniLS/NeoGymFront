import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neoGymTheme.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Digite seu email',
              icon: Icon(Icons.person),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Digite sua senha',
              icon: Icon(Icons.lock),
            ),
          ),
        ],
      ),
    );
  }
}
