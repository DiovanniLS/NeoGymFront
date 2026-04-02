import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const UniversalAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
      style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: NeoGymColors.primary,
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
