
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

typedef NotificationTapHandler = void Function(
    Map<String, dynamic> data,
    );

class ChatNotificationsService {
  ChatNotificationsService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _registrationRequested = false;

  static String? _currentToken;
  static NotificationTapHandler? _onNotificationTap;

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    'neogym_chat_messages',
    'Mensagens do chat',
    description: 'Notificações de novas mensagens do NeoGym.',
    importance: Importance.high,
  );

  static String? get currentToken => _currentToken;

  /// Inicializa o Firebase Messaging e as notificações locais.
  static Future<void> initialize({
    required NotificationTapHandler onNotificationTap,
  }) async {
    if (_initialized) return;

    _onNotificationTap = onNotificationTap;

    // Solicita permissão para exibir notificações.
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configura as notificações locais.
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // API atual: utiliza o parâmetro nomeado "settings".
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload == null || payload.isEmpty) return;

        try {
          final decoded = jsonDecode(payload);

          if (decoded is Map) {
            _onNotificationTap?.call(
              Map<String, dynamic>.from(decoded),
            );
          }
        } catch (e) {
          debugPrint(
            'Erro ao abrir notificação local: $e',
          );
        }
      },
    );

    // Cria o canal de notificações no Android.
    final androidPlugin =
    _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);

    // Obtém o token FCM deste dispositivo.
    _currentToken = await _messaging.getToken();

    // Escuta alterações no token.
    _messaging.onTokenRefresh.listen((token) async {
      _currentToken = token;

      if (_registrationRequested) {
        try {
          await _enviarTokenAoBackend(token);
        } catch (e) {
          debugPrint(
            'Erro ao atualizar token de notificações: $e',
          );
        }
      }
    });

    // Recebe mensagens quando o aplicativo está aberto.
    FirebaseMessaging.onMessage.listen(_mostrarNotificacao);

    // Abre a tela configurada ao tocar em uma notificação
    // recebida enquanto o aplicativo estava em segundo plano.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onNotificationTap?.call(message.data);
    });

    // Evita que o Firebase exiba uma notificação duplicada
    // no iOS enquanto o aplicativo está em primeiro plano.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _initialized = true;

    // Trata a abertura do aplicativo por uma notificação.
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _onNotificationTap?.call(initialMessage.data);
    }

    debugPrint(
      'Inicialização das notificações concluída. '
          'Token FCM disponível: ${_currentToken != null}',
    );
  }

  /// Exibe uma notificação local quando chega uma mensagem
  /// com o aplicativo em primeiro plano.
  static Future<void> _mostrarNotificacao(
      RemoteMessage message,
      ) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Nova mensagem no NeoGym';

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Você recebeu uma nova mensagem.';

    // API atual: utiliza os parâmetros nomeados de show().
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Registra o token do dispositivo no backend.
  ///
  /// Chame este método somente depois de implementar
  /// o endpoint correspondente na API.
  static Future<void> registrarDispositivo() async {
    final token = _currentToken ?? await _messaging.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'O Firebase não retornou um token para notificações.',
      );
    }

    _currentToken = token;

    await _enviarTokenAoBackend(token);

    _registrationRequested = true;
  }

  /// Envia o token FCM para a API.

  static Future<void> _enviarTokenAoBackend(String token) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'Não há usuário autenticado no Firebase.',
      );
    }

    final firebaseIdToken = await firebaseUser.getIdToken();

    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw Exception(
        'Não foi possível obter o token de identidade Firebase.',
      );
    }

    await ApiClient.dio.post(
      '/notificacoes/dispositivo',
      data: {
        'token': token,
        'plataforma': defaultTargetPlatform.name,
        'firebaseIdToken': firebaseIdToken,
      },
    );
  }

}
