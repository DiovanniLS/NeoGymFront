import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> icons = const [
    "assets/icons/botao-home.png",
    "assets/icons/localizacao.png",
    "assets/icons/chat.png",
    "assets/icons/profissionais.png",
    "assets/icons/configuracoes.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A18), Color(0xFFFF3D00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / icons.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: itemWidth * currentIndex + (itemWidth / 2) - 18,
                top: 16,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),

              Row(
                children: List.generate(icons.length, (index) {
                  final isSelected = currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isSelected ? 1.2 : 1.0,
                          child: Image.asset(
                            icons[index],
                            width: 24,
                            color: isSelected
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}