import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../view_model/AuthViewModel.dart';
import '../view_model/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String Image;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.Image,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    final user = context.read<AuthViewModel>().user;

    await context.read<ChatViewModel>().sendMessage(
      chatId: widget.chatId,

      message: controller.text.trim(),

      senderName: user?.nome ?? "Usuário",

      senderEmail: user?.email ?? "",
    );

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    return Scaffold(
      appBar: UniversalAppBar(
        title: widget.name,
        imageUrl: widget.Image,
        showAvatar: true,
        leadingIcon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "perfil") {
              } else if (value == "bloquear") {}
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "perfil", child: Text("Ver perfil")),
              const PopupMenuItem(value: "bloquear", child: Text("Bloquear")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: context.read<ChatViewModel>().getMessages(widget.chatId),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,

                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    final isMe = msg.senderEmail == user?.email;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),

                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),

                            child: Text(
                              msg.senderName,

                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,

                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),

                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],

                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: Text(
                                msg.text,

                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
