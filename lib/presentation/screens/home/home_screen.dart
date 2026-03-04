import 'package:equilibra_mobile/data/services/default_exercises_service.dart';
import 'package:equilibra_mobile/data/services/default_ingredients_service.dart';
import 'package:equilibra_mobile/data/services/meal_types_service.dart';
import 'package:equilibra_mobile/di/injection.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/auth_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_cubit.dart';
import 'package:equilibra_mobile/presentation/screens/alimentacion/alimentacion_screen.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/citas_medicas_screen.dart';
import 'package:equilibra_mobile/presentation/screens/ejercicio/ejercicio_screen.dart';
import 'package:equilibra_mobile/presentation/screens/home/widgets/home_bottom_nav.dart';
import 'package:equilibra_mobile/presentation/screens/home/widgets/profile_drawer.dart';
import 'package:equilibra_mobile/presentation/screens/inicio/inicio_screen.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/sueno_screen.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shell post-login: controla 5 pantallas con bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens = [
    InicioScreen(
      onOpenProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
    ),
    AlimentacionScreen(),
    EjercicioScreen(),
    SuenoScreen(),
    CitasMedicasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<AuthCubit>()),
        BlocProvider(create: (_) => getIt<AlimentacionCubit>()),
        BlocProvider(create: (_) => getIt<EjercicioCubit>()),
        BlocProvider(create: (_) => getIt<SuenoCubit>()),
        BlocProvider(create: (_) => getIt<VisitasMedicasCubit>()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        body: IndexedStack(index: _currentIndex, children: _screens),
        endDrawer: const ProfileDrawer(),
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // FloatingActionButton.small(
            //   heroTag: 'seed_ejercicio',
            //   onPressed: () => _seedEjercicios(context),
            //   backgroundColor: const Color(0xFF8B5CF6),
            //   tooltip: 'Cargar ejercicios de prueba',
            //   child: const Icon(
            //     Icons.fitness_center,
            //     color: Colors.white,
            //     size: 20,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // FloatingActionButton(
            //   heroTag: 'seed_alimentacion',
            //   onPressed: () => _seedAlimentacion(context),
            //   backgroundColor: AppColors.healthPrimary,
            //   tooltip: 'Cargar ingredientes y tipos de comida',
            //   child: const Icon(Icons.restaurant, color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedAlimentacion(BuildContext context) async {
    try {
      await getIt<DefaultIngredientsService>().seed();
      await getIt<MealTypesService>().seed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listo: ingredientes y tipos de comida'),
            backgroundColor: AppColors.healthPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _seedEjercicios(BuildContext context) async {
    try {
      await getIt<DefaultExercisesService>().seed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listo: ejercicios de prueba cargados'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
