import 'package:equilibra_mobile/data/services/auth_service.dart';
import 'package:equilibra_mobile/data/services/default_exercises_service.dart';
import 'package:equilibra_mobile/data/services/default_ingredients_service.dart';
import 'package:equilibra_mobile/data/services/meal_types_service.dart';
import 'package:equilibra_mobile/data/services/registered_exercises_service.dart';
import 'package:equilibra_mobile/data/services/registered_meals_service.dart';
import 'package:equilibra_mobile/data/services/registered_medical_visits_service.dart';
import 'package:equilibra_mobile/data/services/registered_sleep_times_service.dart';
import 'package:equilibra_mobile/data/services/user_service.dart';
import 'package:equilibra_mobile/presentation/cubits/auth_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/alimentacion_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/ejercicio_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  getIt.registerLazySingleton<UserService>(UserService.new);
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(userService: getIt<UserService>()),
  );
  getIt.registerLazySingleton<DefaultIngredientsService>(
    DefaultIngredientsService.new,
  );
  getIt.registerLazySingleton<MealTypesService>(MealTypesService.new);
  getIt.registerLazySingleton<RegisteredMealsService>(RegisteredMealsService.new);
  getIt.registerLazySingleton<DefaultExercisesService>(
    DefaultExercisesService.new,
  );
  getIt.registerLazySingleton<RegisteredExercisesService>(
    RegisteredExercisesService.new,
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authService: getIt<AuthService>()),
  );
  getIt.registerFactory<AlimentacionCubit>(
    () => AlimentacionCubit(
      defaultIngredientsService: getIt<DefaultIngredientsService>(),
      mealTypesService: getIt<MealTypesService>(),
      registeredMealsService: getIt<RegisteredMealsService>(),
    ),
  );
  getIt.registerFactory<EjercicioCubit>(
    () => EjercicioCubit(
      defaultExercisesService: getIt<DefaultExercisesService>(),
      registeredExercisesService: getIt<RegisteredExercisesService>(),
    ),
  );
  getIt.registerLazySingleton<RegisteredSleepTimesService>(
    RegisteredSleepTimesService.new,
  );
  getIt.registerFactory<SuenoCubit>(
    () => SuenoCubit(
      registeredSleepTimesService: getIt<RegisteredSleepTimesService>(),
    ),
  );
  getIt.registerLazySingleton<RegisteredMedicalVisitsService>(
    RegisteredMedicalVisitsService.new,
  );
  getIt.registerFactory<VisitasMedicasCubit>(
    () => VisitasMedicasCubit(
      service: getIt<RegisteredMedicalVisitsService>(),
    ),
  );
}
