import 'package:flutter/material.dart';

/// AppBar reutilizable de la pantalla Home.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, this.title = 'Equilibra', this.onLogout});

  final String title;
  final VoidCallback? onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: onLogout != null
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
                tooltip: 'Cerrar sesión',
              ),
            ]
          : null,
    );
  }
}
