import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

class Configuracoes extends StatelessWidget {
  const Configuracoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Configurações",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    child: Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Diovanni",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Rumo à sua melhor versão 💪",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF7A18),
                      Color(0xFFFF3D00),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white),
                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Continue seu progresso",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "3 treinos essa semana 🔥",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView(
                  children: [
                    _buildItem(Icons.person, "Editar perfil"),
                    _buildItem(Icons.bar_chart, "Meu progresso"),
                    _buildItem(Icons.fitness_center, "Minhas fichas"),
                    _buildItem(Icons.location_on, "Minha academia"),
                    _buildItem(Icons.water_drop, "Hidratação"),
                    _buildItem(Icons.notifications, "Notificações"),
                    _buildItem(Icons.settings, "Preferências"),
                    _buildItem(Icons.help_outline, "Ajuda"),
                    _buildItem(Icons.bug_report, "Reportar problema"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: NeoGymColors.primary),
          const SizedBox(width: 15),
          Expanded(child: Text(title)),
          const Icon(Icons.arrow_forward_ios, size: 16, color: NeoGymColors.primary,),
        ],
      ),
    );
  }
}