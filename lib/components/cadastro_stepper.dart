import 'package:flutter/material.dart';
import '../Resources/neo_gym_colors.dart';

class CadastroStepper extends StatelessWidget {

  final int step;

  const CadastroStepper({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: _buildStep(
            number: 1,
            title: "Dados pessoais",
            isActive: step >= 1,
            isCompleted: step > 1,
          ),
        ),

        Expanded(
          child: Container(
            height: 3,
            color: step >= 2
                ? NeoGymColors.primary
                : Colors.grey[300],
          ),
        ),

        Expanded(
          child: _buildStep(
            number: 2,
            title: "Documento",
            isActive: step == 2,
            isCompleted: false,
          ),
        ),

      ],
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? NeoGymColors.primary
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),

      ],
    );
  }
}