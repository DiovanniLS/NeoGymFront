import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/chat_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/components/app_bottom_nav.dart';
import 'package:neogym/components/card_principal.dart';
import 'map_screen.dart';

enum AppTab { home, map, professionals, chat, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeContent(),
    MapScreen(),
    Profissionais(),
    ChatScreen(),
    Configuracoes(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Diovanni',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'vamos treinar hoje?',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(),
                    child: CircleAvatar(child: Icon(Icons.person)),
                  ),
                ],
              ),
              SizedBox(height: 30),
              CardPrincipal(
                leading: Icon(Icons.water_drop, color: Colors.lightBlue),
                title: "Hidratação",
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey[200]),
                    Text("1.2L / 2.5L"),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(30),
                      value: 1.2 / 2.5,
                      backgroundColor: Colors.lightBlueAccent[100],
                      color: Colors.blue,
                      minHeight: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você está abaixo da meta',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                button: ElevatedButton(
                  onPressed: () {},
                  child: const Text('+200ml'),
                ),
              ),
              const SizedBox(height: 30),
              CardPrincipal(
                leading: Container(
                  height: 32,
                  width: 32,
                  child: Image.asset('assets/icons/treino.png'),
                ),
                title: "Ficha de Treino",
                content: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.2, 0.8, 1.0],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/icons/gym_illustration.png',
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Peito + Tríceps',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text('5 Exercícios', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                button: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Ver Ficha'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
