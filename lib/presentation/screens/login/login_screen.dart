import 'package:equilibra_mobile/presentation/screens/login/widgets/login_footer.dart';
import 'package:equilibra_mobile/presentation/screens/login/widgets/login_form.dart';
import 'package:equilibra_mobile/presentation/screens/login/widgets/login_header.dart';
import 'package:equilibra_mobile/presentation/screens/register/register_screen.dart';
import 'package:flutter/material.dart';

/// Pantalla de inicio de sesión.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const LoginHeader(),
              const SizedBox(height: 40),
              const LoginForm(),
              LoginFooter(
                onRegister: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
