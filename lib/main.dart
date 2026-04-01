import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/chat_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/home.dart';
import 'package:neogym/Views/profissionais.dart';
import 'Views/lista_de_exercícios.dart';
import 'Views/map_screen.dart';
import 'Views/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/home": (context) => HomeScreen(),
        "/gymMap": (context) => MapScreen(),
        "/config": (context) => Configuracoes(),
        "/profissionais": (context) => Profissionais(),
        "/chat": (context) => ChatScreen(),
        '/workouts': (context) => const WorkoutListScreen(),
      },
      theme: neoGymTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

