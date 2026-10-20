
class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String? imageUrl;

  const MessageModel({
    this.id = '',
    required this.text,
    this.senderId = '',
    required this.senderName,
    required this.senderEmail,
    this.imageUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Usuário',
      senderEmail: map['senderEmail'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
