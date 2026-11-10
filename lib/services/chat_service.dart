
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _messages(
      String chatId,
      ) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _messages(chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderName,
    required String senderEmail,
    String? imageUrl,
  }) async {
    final firebaseUser = auth.currentUser;

    if (firebaseUser == null) {
      throw StateError(
        'É necessário estar autenticado no Firebase para enviar mensagens.',
      );
    }

    if (message.trim().isEmpty &&
        (imageUrl == null || imageUrl.trim().isEmpty)) {
      throw ArgumentError(
        'A mensagem não pode estar vazia.',
      );
    }

    // Obtém o ID do usuário autenticado no NeoGym.
    // Não utilizar firebaseUser.uid para essa finalidade,
    // pois o Firebase está utilizando autenticação anônima.
    final int? senderUsuarioId = await TokenStorage.getUserId();

    if (senderUsuarioId == null) {
      throw StateError(
        'Não foi possível identificar o usuário autenticado no NeoGym.',
      );
    }

    // O chat é formado pelos IDs ordenados dos participantes:
    // chat_<id menor>_<id maior>
    final int recipientUsuarioId = _obterDestinatarioId(
      chatId: chatId,
      senderUsuarioId: senderUsuarioId,
    );

    // Salva a mensagem no Firestore.
    // O senderId original continua sendo o UID Firebase,
    // utilizado atualmente na exclusão das próprias mensagens.

    final messageRef = await _messages(chatId).add({
      'text': message.trim(),

      // UID do Firebase: usado para identificar o autor
      // nas operações que dependem da autenticação Firebase.
      'senderId': firebaseUser.uid,

      // ID numérico do usuário autenticado no NeoGym.
      'senderUsuarioId': senderUsuarioId,

      // ID numérico do outro participante da conversa.
      'recipientUsuarioId': recipientUsuarioId,

      'senderName': senderName,
      'senderEmail': senderEmail,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

// A mensagem já está salva no Firestore.
// Solicitamos ao backend que envie a notificação.
    try {
      await ApiClient.dio.post(
        '/notificacoes/chat',
        data: {
          'chatId': chatId,
          'messageId': messageRef.id,
        },
      );
    } catch (e) {
      debugPrint(
        'Mensagem salva, mas não foi possível solicitar a notificação: $e',
      );
    }
  }

  int _obterDestinatarioId({
    required String chatId,
    required int senderUsuarioId,
  }) {
    final match = RegExp(
      r'^chat_(\d+)_(\d+)$',
    ).firstMatch(chatId);

    if (match == null) {
      throw ArgumentError(
        'Formato de chat inválido: $chatId',
      );
    }

    final usuarioA = int.parse(match.group(1)!);
    final usuarioB = int.parse(match.group(2)!);

    if (senderUsuarioId == usuarioA) {
      return usuarioB;
    }

    if (senderUsuarioId == usuarioB) {
      return usuarioA;
    }

    throw StateError(
      'O usuário autenticado não corresponde aos participantes do chat.',
    );
  }

  Future<String> uploadImage({
    required String chatId,
    required XFile image,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      throw StateError(
        'É necessário estar autenticado no Firebase para enviar imagens.',
      );
    }

    final reference = storage.ref().child(
      'chat_images/$chatId/${user.uid}/'
          '${DateTime.now().microsecondsSinceEpoch}.jpg',
    );

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    await reference.putFile(
      File(image.path),
      metadata,
    );

    return reference.getDownloadURL();
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      throw StateError(
        'Usuário não autenticado no Firebase.',
      );
    }

    final document = _messages(chatId).doc(messageId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw StateError(
        'A mensagem não existe mais.',
      );
    }

    if (snapshot.data()?['senderId'] != user.uid) {
      throw StateError(
        'Você só pode excluir as próprias mensagens.',
      );
    }

    // As regras do Firestore também devem validar o proprietário.
    await document.delete();
  }
}
