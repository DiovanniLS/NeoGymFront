
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';

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
    final user = auth.currentUser;

    if (user == null) {
      throw StateError(
        'É necessário estar autenticado no Firebase para enviar mensagens.',
      );
    }

    if (message.trim().isEmpty && imageUrl == null) {
      throw ArgumentError('A mensagem não pode estar vazia.');
    }

    await _messages(chatId).add({
      'text': message.trim(),
      'senderId': user.uid,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
      throw StateError('Usuário não autenticado no Firebase.');
    }

    final document = _messages(chatId).doc(messageId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw StateError('A mensagem não existe mais.');
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
