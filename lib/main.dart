import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'firebase_options.dart';
import 'presentation/cubits/auth_cubit.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/login/login_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjection();

  // Inicializar push notifications (FCM): imprime token y configura listeners
  await NotificationService().init();

  runApp(const EquilibraApp());
}

class EquilibraApp extends StatelessWidget {
  const EquilibraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkAuth(),
      child: MaterialApp(
        title: 'Equilibra',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) return const HomeScreen();
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
