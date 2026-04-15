import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String Image;

  const ChatScreen({super.key, required this.name, required this.Image});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": controller.text,
        "isMe": true,
      });
    });

    controller.clear();

    // simulação de resposta automática 🤖
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        messages.add({
          "text": "Resposta automática 👀",
          "isMe": false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "perfil") {
              } else if (value == "bloquear") {
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "perfil",
                child: Text("Ver perfil"),
              ),
              const PopupMenuItem(
                value: "bloquear",
                child: Text("Bloquear"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];

                return Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["isMe"]
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isMe"]
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}