import 'package:equilibra_mobile/data/models/user_model.dart';
import 'package:equilibra_mobile/di/injection.dart';
import 'package:equilibra_mobile/data/services/user_service.dart';
import 'package:equilibra_mobile/presentation/cubits/auth_cubit.dart';
import 'package:equilibra_mobile/presentation/screens/estadisticas/estadisticas_screen.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// End drawer de perfil: avatar con iniciales, nombre, email y Cerrar sesión.
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state is AuthAuthenticated
        ? (context.read<AuthCubit>().state as AuthAuthenticated).uid
        : null;

    if (uid == null) {
      return const Drawer(
        child: Center(child: Text('No hay sesión')),
      );
    }

    return Drawer(
      child: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: getIt<UserService>().getUser(uid),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final name = user?.name ?? '';
            final lastName = user?.lastName ?? '';
            final email = user?.email ?? '';
            final initials = _initials(name, lastName);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'Perfil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _displayName(name, lastName),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    email.isNotEmpty ? email : '—',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                ListTile(
                  leading: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  title: Text(
                    'Estadísticas mensuales',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EstadisticasScreen(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthCubit>().signOut();
                      },
                      icon: const Icon(Icons.logout, size: 20, color: Colors.red),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _initials(String name, String lastName) {
    final n = name.trim().isNotEmpty ? name.trim().toUpperCase().substring(0, 1) : '';
    final l = lastName.trim().isNotEmpty ? lastName.trim().toUpperCase().substring(0, 1) : '';
    if (n.isEmpty && l.isEmpty) return '?';
    return n + l;
  }

  static String _displayName(String name, String lastName) {
    final n = name.trim();
    final l = lastName.trim();
    if (n.isEmpty && l.isEmpty) return 'Usuario';
    return [n, l].where((s) => s.isNotEmpty).join(' ');
  }
}
