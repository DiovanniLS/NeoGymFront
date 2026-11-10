import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

import 'foto_usuario.dart';

class UniversalAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? imageUrl;
  final int? usuarioId;
  final Widget? leadingIcon;
  final bool showAvatar;
  final List<Widget>? actions;

  const UniversalAppBar({
    super.key,
    required this.title,
    this.imageUrl,
    this.usuarioId,
    this.leadingIcon,
    this.showAvatar = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NeoGymColors.primary,
      elevation: 4,
      centerTitle: false,
      leading: leadingIcon,
      actions: actions,
      title: Row(
        children: [
          if (showAvatar) ...[
            if (usuarioId != null)
              FotoUsuario(
                key: ValueKey(usuarioId),
                usuarioId: usuarioId,
                width: 36,
                height: 36,
                borderRadius: 1000,
                iconSize: 20,
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundImage:
                imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}