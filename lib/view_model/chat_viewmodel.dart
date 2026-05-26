import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _service = ChatService();

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _service.getMessages(chatId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderName,
    required String senderEmail
  }) async {
    await _service.sendMessage(
      chatId: chatId,
      message: message,
      senderName: senderName,
      senderEmail: senderEmail

    );
  }
}
