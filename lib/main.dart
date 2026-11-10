
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';

import 'package:neogym/Views/messages_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/Views/map_screen.dart';
import 'package:neogym/Views/login_screen.dart';

import 'package:neogym/services/api_client.dart';
import 'package:neogym/services/professional_service.dart';
import 'package:neogym/services/chat_notifications_service.dart';

import 'package:neogym/view_model/agendamento_view_model.dart';
import 'package:neogym/view_model/auth_view_model.dart';
import 'package:neogym/view_model/chat_view_model.dart';
import 'package:neogym/view_model/professional_view_model.dart';

import 'package:neogym/views/professional_home_screens/add_agenda_event.dart';
import 'package:neogym/views/professional_home_screens/professional_agenda_screen.dart';
import 'package:neogym/views/professional_home_screens/professional_clients_screen.dart';
import 'package:neogym/views/professional_home_screens/professional_home_content.dart';

import 'package:neogym/views/student_home_screens/activities_screen.dart';
import 'package:neogym/views/student_home_screens/add_atividade.dart';
import 'package:neogym/views/student_home_screens/home.dart';
import 'package:neogym/views/student_home_screens/lista_de_exerc%C3%ADcios.dart';
import 'package:neogym/views/student_home_screens/select_work_places.dart';

import 'Views/chat_screen.dart';
import 'firebase_options.dart';

// Chave global para navegar ao abrir uma notificação.
final GlobalKey<NavigatorState> appNavigatorKey =
GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente.
  await dotenv.load(fileName: ".env");

  // Inicializa o Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Mantém a autenticação Firebase utilizada atualmente pelo aplicativo.
  await initAuth();

  // Inicializa o cliente HTTP da API.
  ApiClient.setup();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfessionalViewModel(
            ProfessionalService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AgendamentoViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // Inicializa o recebimento de notificações depois que o aplicativo
  // tiver montado sua primeira tela.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await ChatNotificationsService.initialize(
        onNotificationTap: (data) {
          final navigator = appNavigatorKey.currentState;

          if (navigator == null) {
            debugPrint(
              'Não foi possível abrir a tela: navegador indisponível.',
            );
            return;
          }

          // Abre a tela de mensagens ao tocar na notificação.
          // Os dados recebidos são enviados como argumentos da rota.
          navigator.pushNamed(
            '/chat',
            arguments: data,
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Erro ao inicializar notificações: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  });
}

Future<void> initAuth() async {
  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

  debugPrint(
    'AUTH READY: ${auth.currentUser?.uid}',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,

      locale: const Locale('pt', 'BR'),

      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: '/',

      routes: {
        '/': (context) => LoginScreen(),

        '/home': (context) => HomeScreen(),

        '/homePro': (context) => ProfessionalHomeContent(),

        '/agendaPro': (context) => ProfessionalAgendaScreen(),

        '/addEventoAgenda': (context) => AddAgendaEvent(),

        '/proClientScreen': (context) => ProfessionalClientsScreen(),

        '/gymMap': (context) => MapScreen(),

        '/config': (context) => Configuracoes(),

        '/profissionais': (context) => Profissionais(),


        '/workouts': (context) => WorkoutListScreen(),

        '/activities': (context) => ActivitiesScreen(),

        '/addAtiv': (context) => AddAtividade(),

        '/selectWorkPlace': (context) => SelectWorkPlaces(),

        '/chat': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;

          if (arguments is Map) {
            final chatId = arguments['chatId']?.toString();

            if (chatId != null && chatId.trim().isNotEmpty) {
              return ChatScreen(
                name: (
                    arguments['senderName'] ??
                        arguments['name'] ??
                        'Conversa'
                ).toString(),
                Image: (
                    arguments['senderImage'] ??
                        arguments['imageUrl'] ??
                        ''
                ).toString(),
                chatId: chatId,
              );
            }
          }

          // Sem dados de uma notificação, abre a lista de conversas.
          return const MessagesScreen();
        },

      },

      theme: neoGymTheme,

      debugShowCheckedModeBanner: false,
    );
  }
}
