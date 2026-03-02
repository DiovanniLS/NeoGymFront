import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.menu))
        ],
      ),
      backgroundColor: neoGymTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo+nome.png'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: Text('Fazer login'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
