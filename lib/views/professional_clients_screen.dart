import 'package:flutter/material.dart';
import 'package:neogym/views/professional_chatScreen.dart';

class ProfessionalClientsScreen extends StatelessWidget {
  const ProfessionalClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
      ),
      body: ListView.builder(
        itemCount: 10, // depois vem do backend
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text("Cliente $index"),
            subtitle: const Text("Última mensagem..."),
            trailing: const Icon(Icons.chat),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfessionalChatScreen(
                    chatId: "chat_$index",
                    clientName: "Cliente $index",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}