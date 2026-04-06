import 'package:flutter/material.dart';

import '../models/professional.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  final Professional prof;

  const ProfessionalDetailScreen({super.key, required this.prof});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼️ IMAGEM TOPO
            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(prof.image ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_sharp, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prof.name ?? "",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (prof.isOnline ?? false)
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (prof.isOnline ?? false)
                                ? "Online"
                                : "Offline",
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      prof.specialty,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    // ⭐ INFO
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange),
                        Text("${prof.rating ?? 0}"),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on),
                        Text("${prof.distance} km"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat),
                            label: const Text("Chat"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                            label: const Text("Agendar"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Sobre",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Profissional com experiência em treino personalizado, foco em hipertrofia e emagrecimento.",
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Especialidades",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: const [
                        Chip(label: Text("Hipertrofia")),
                        Chip(label: Text("Emagrecimento")),
                        Chip(label: Text("Funcional")),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Horários disponíveis",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(onPressed: () {}, child: Text("08:00")),
                        OutlinedButton(onPressed: () {}, child: Text("10:00")),
                        OutlinedButton(onPressed: () {}, child: Text("18:00")),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}