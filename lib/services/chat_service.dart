import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderName,
    required String senderEmail,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'message': message,

      'senderId': user.uid,

      'senderName': senderName,
      'senderEmail': senderEmail,

      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
