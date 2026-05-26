import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/home_screens/select_work_places.dart';
import 'package:neogym/Views/messages_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/home_screens/activities_screen.dart';
import 'package:neogym/Views/home_screens/add_atividade.dart';
import 'package:neogym/Views/home_screens/home.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/view_model/AuthViewModel.dart';
import 'package:neogym/view_model/chat_viewmodel.dart';
import 'package:neogym/view_model/professional_viewmodel.dart';
import 'Views/home_screens/lista_de_exercícios.dart';
import 'Views/map_screen.dart';
import 'Views/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfessionalViewModel()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: "/",
      routes: {
        "/": (context) => LoginScreen(),
        "/home": (context) => HomeScreen(),
        "/gymMap": (context) => MapScreen(),
        "/config": (context) => Configuracoes(),
        "/profissionais": (context) => Profissionais(),
        "/chat": (context) => MessagesScreen(),
        "/workouts": (context) => WorkoutListScreen(),
        "/activities": (context) => ActivitiesScreen(),
        "/addAtiv": (context) => AddAtividade(),
        "/selectWorkPlace": (context) => SelectWorkPlaces(),
      },
      theme: neoGymTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
