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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A18), Color(0xFFFF3D00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: NavigationBar(
        height: 40,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.transparent,

        destinations: [
          NavigationDestination(
            icon: Image.asset("assets/icons/botao-home.png", width: 26),
            selectedIcon: Image.asset("assets/icons/botao-home_filled.png", width: 26),
            label: "Home",
          ),
          NavigationDestination(
            icon: Center(child: Image.asset("assets/icons/localizacao.png", width: 26)),
            selectedIcon: Image.asset("assets/icons/localizacao_filled.png", width: 26, color: Colors.white,),
            label: "Mapa",
          ),
          NavigationDestination(
            icon: Image.asset("assets/icons/chat.png", width: 26),
            selectedIcon: Image.asset("assets/icons/chat_filled.png", width: 26),
            label: "Chat",
          ),
          NavigationDestination(
            icon: Image.asset("assets/icons/profissionais.png", width: 26),
            selectedIcon: Image.asset("assets/icons/profissionais_filled.png", width: 26),
            label: "Pro",
          ),
          NavigationDestination(
            icon: Image.asset("assets/icons/configuracoes.png", width: 26),
            selectedIcon: Image.asset("assets/icons/configuracoes_filled.png", width: 26),
            label: "Config",
          ),
        ],
      ),
    );
  }
}
