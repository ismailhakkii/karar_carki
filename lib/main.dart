import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:karar_carki/core/providers/onboarding_provider.dart';
import 'package:karar_carki/core/providers/theme_provider.dart';
import 'package:karar_carki/core/theme/app_theme.dart';
import 'package:karar_carki/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:karar_carki/features/wheel/data/repositories/wheel_repository_impl.dart';
import 'package:karar_carki/features/wheel/domain/repositories/wheel_repository.dart';
import 'package:karar_carki/features/wheel/domain/usecases/get_all_wheels.dart';
import 'package:karar_carki/features/wheel/domain/usecases/save_wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize dependency injection
  setupDependencies();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<WheelBloc>(
          create: (_) => GetIt.instance<WheelBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: Consumer2<ThemeProvider, OnboardingProvider>(
        builder: (context, themeProvider, onboardingProvider, _) {
          return MaterialApp(
            title: 'Karar Çarkı',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: onboardingProvider.isFirstLaunch
                ? const OnboardingPage()
                : const HomePage(),
          );
        },
      ),
    );
  }
}
