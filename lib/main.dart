import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/login_page.dart';

import 'Views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: neoGymTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

