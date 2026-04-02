import 'package:flutter/material.dart';

class SwipeableCard extends StatelessWidget {
  final Widget leading;
  final Widget content;
  final Widget trailing;

  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const SwipeableCard({
    super.key,
    required this.leading,
    required this.content,
    required this.trailing,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,

        onDismissed: (direction) {
          onDelete();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removido')),
          );
        },

        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Remover"),
              content: const Text("Deseja remover este item?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Remover"),
                ),
              ],
            ),
          );
        },

        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A18), Color(0xFFFF3D00)],
            ),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),

        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: Colors.orange[100],
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),

                  Expanded(child: content),

                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}