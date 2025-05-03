import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:karar_carki/core/theme/app_theme.dart';
import 'package:karar_carki/features/wheel/data/repositories/wheel_repository_impl.dart';
import 'package:karar_carki/features/wheel/domain/repositories/wheel_repository.dart';
import 'package:karar_carki/features/wheel/domain/usecases/get_all_wheels.dart';
import 'package:karar_carki/features/wheel/domain/usecases/save_wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize dependency injection
  setupDependencies();
  
  runApp(const MyApp());
}

void setupDependencies() {
  final getIt = GetIt.instance;
  
  // Repositories
  getIt.registerLazySingleton<WheelRepository>(
    () => WheelRepositoryImpl(),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetAllWheels(getIt<WheelRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveWheel(getIt<WheelRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => WheelBloc(
      getAllWheels: getIt<GetAllWheels>(),
      saveWheel: getIt<SaveWheel>(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<WheelBloc>()..add(const LoadWheels()),
      child: MaterialApp(
        title: 'Karar Çarkı',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
