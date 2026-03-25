import 'package:flutter/material.dart';
class CardPrincipal extends StatelessWidget {
  final Widget leading;
  final ImageIcon? imageIcon;
  final String title;
  final Widget content;
  final Widget button;

  const CardPrincipal({
    super.key,
    required this.leading,
    required this.title,
    required this.content,
    required this.button,
    this.imageIcon
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading,
              ],
            ),

            const SizedBox(height: 12),

            // CONTEÚDO CUSTOM
            content,

            const SizedBox(height: 16),

            // BOTÃO
            Align(
              alignment: Alignment.centerRight,
              child: button,
            ),
          ],
        ),
      ),
    );
  }
}