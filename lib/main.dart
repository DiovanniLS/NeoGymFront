import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/messages_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/home_screens/activities_screen.dart';
import 'package:neogym/Views/home_screens/add_atividade.dart';
import 'package:neogym/Views/home_screens/home.dart';
import 'package:neogym/Views/profissionais.dart';
import 'Views/home_screens/lista_de_exercícios.dart';
import 'Views/map_screen.dart';
import 'Views/splash_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/home": (context) => HomeScreen(),
        "/gymMap": (context) => MapScreen(),
        "/config": (context) => Configuracoes(),
        "/profissionais": (context) => Profissionais(),
        "/chat": (context) => MessagesScreen(),
        "/workouts": (context) => WorkoutListScreen(),
        "/activities": (context) => ActivitiesScreen(),
        "/addAtiv": (context) => AddAtividade(),
      },
      theme: neoGymTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

