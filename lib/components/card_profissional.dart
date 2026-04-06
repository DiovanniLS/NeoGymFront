import 'package:flutter/material.dart';

class ProfessionalCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final double distance;
  final String imageUrl;
  final bool isOnline;

  final VoidCallback onTap;
  final VoidCallback onChat;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.isOnline,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [

                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(imageUrl),
                    ),

                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // 🧠 INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        specialty,
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(rating.toString()),

                          const SizedBox(width: 10),

                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${distance.toStringAsFixed(1)} km"),
                        ],
                      ),
                    ],
                  ),
                ),

                // 💬 BOTÃO CHAT
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}