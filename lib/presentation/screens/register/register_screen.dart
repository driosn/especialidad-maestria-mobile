import 'package:equilibra_mobile/presentation/screens/register/widgets/register_footer.dart';
import 'package:equilibra_mobile/presentation/screens/register/widgets/register_form.dart';
import 'package:equilibra_mobile/presentation/screens/register/widgets/register_header.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pantalla de creación de cuenta.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const RegisterHeader(),
              const SizedBox(height: 32),
              const RegisterForm(),
              RegisterFooter(onLogin: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}
