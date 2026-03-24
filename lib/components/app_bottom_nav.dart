import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      indicatorColor: Colors.transparent,
      destinations: [
        NavigationDestination(
          icon: Image.asset("assets/icons/botao-home.png", width: 24),
          selectedIcon: Image.asset(
            "assets/icons/botao-home_filled.png",
            width: 24,
          ),
          label: "Início",
        ),
        NavigationDestination(
          icon: Image.asset("assets/icons/localizacao.png", width: 24),
          selectedIcon: Image.asset("assets/icons/localizacao_filled.png", width: 24),
          label: "Mapa",
        ),
        NavigationDestination(
          icon: Image.asset("assets/icons/chat.png", width: 24),
          selectedIcon: Image.asset(
            "assets/icons/chat_filled.png",
            width: 24,
          ),
          label: "Chat",
        ),
        NavigationDestination(
          icon: Image.asset("assets/icons/profissionais.png", width: 24),
          selectedIcon: Image.asset(
            "assets/icons/profissionais_filled.png",
            width: 24,
          ),
          label: "Profissionais",
        ),
        NavigationDestination(
          icon: Image.asset("assets/icons/configuracoes.png", width: 24),
          selectedIcon: Image.asset(
            "assets/icons/configuracoes_filled.png",
            width: 24,
          ),
          label: "Config",
        ),
      ],
    );
  }
}
