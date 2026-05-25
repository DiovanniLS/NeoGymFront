import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Views/cadastro_aluno.dart';
import 'package:neogym/Views/cadastro_Profissional.dart';

class EscolherPerfil extends StatelessWidget {
  const EscolherPerfil({super.key});
  static const primaryColor = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/logo+nome.svg',
                height: 100,
                colorFilter: const ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(height: 100),

              Column(
                children: [
                  const Text(
                    'Escolha seu perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60,),
                  ProfileLineCard(
                    label: 'Aluno',
                    icon: Icons.sports_gymnastics,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroAluno()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ProfileLineCard(
                    label: 'Nutricionista',
                    icon: Icons.energy_savings_leaf,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroProfissional(proType: 'Nutri',)),
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  ProfileLineCard(
                    label: 'Personal Trainer',
                    icon: Icons.fitness_center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroProfissional(proType: 'Personal',)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileLineCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileLineCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
