import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String text;

  final String senderId;

  final String senderName;

  final String senderEmail;

  final DateTime createdAt;

  MessageModel({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      text: map['text'] ?? '',

      senderId: map['senderId'] ?? '',

      senderName: map['senderName'] ?? '',

      senderEmail: map['senderEmail'] ?? '',

      createdAt: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
