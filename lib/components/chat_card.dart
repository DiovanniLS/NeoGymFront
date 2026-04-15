import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(15),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 12),

          child: Row(
            children: [

              // 🧑 Avatar + status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(imageUrl),
                  ),

                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                        ),
                      ),
                    )
                ],
              ),

              const SizedBox(width: 12),

              // 🧾 Nome + mensagem
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ⏰ Hora
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}