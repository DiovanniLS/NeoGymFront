import 'package:flutter/material.dart';

import 'package:neogym/Views/chat_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/components/app_bottom_nav.dart';
import 'package:neogym/components/card_principal.dart';
import '../../models/gym.dart';
import '../map_screen.dart';

enum AppTab { home, map, professionals, chat, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  Gym? selectedGym;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Gym) {
      selectedGym = args;
    }
  }

  List<Widget> get pages => [
    const HomeContent(),
    MapScreen(gym: selectedGym),
    const ChatScreen(),
    const Profissionais(),
    const Configuracoes(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: AppBottomNav(
          currentIndex: currentIndex,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {

  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double currentWater = 0;

  double goalWater = 2.5;

  void addWater(double amount){
    setState(() {
      currentWater += amount;

      if(currentWater > goalWater){
        currentWater = goalWater;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: SingleChildScrollView(
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
                _buildHydrationCard(),
                const SizedBox(height: 30),
                _buildWorkoutCard(),
                const SizedBox(height: 30),
                _buildClassesCard(),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildHydrationCard() {
    return CardPrincipal(
      leading: Icon(Icons.water_drop, color: Colors.lightBlue),
      title: "Hidratação",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200]),

          Text("${currentWater.toStringAsFixed(1)}L / ${goalWater}L"),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(30),
            value: currentWater / goalWater,
            backgroundColor: Colors.lightBlueAccent[100],
            color: Colors.blue,
            minHeight: 20,
          ),

          const SizedBox(height: 8),

          Text(
            currentWater >= goalWater
                ? "Meta atingida 🎉"
                : "Você está abaixo da meta",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),

      button: ElevatedButton(
        onPressed: () => addWater(0.2),
        child: const Text('+200ml'),
      ),
    );
  }


  Widget _buildWorkoutCard() {
    return CardPrincipal(
      leading: Image.asset('assets/icons/treino.png'),
      title: "Ficha de Treino",
      content: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          onPressed: () {
            Navigator.pushNamed(context, '/workouts');
          },
        child: const Text('Ver Ficha'),
      ),
    );
  }

  Widget _buildClassesCard() {
    return CardPrincipal(
      leading: Icon(Icons.calendar_today, color: Colors.orange),
      title: "Próximas Aulas",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200]),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Funcional"),
              Text("18:00"),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Musculação"),
              Text("20:00"),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Hoje você tem 2 atividades",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/activities');
        },
        child: const Text("Ver Agenda"),
      ),
    );
  }
}
