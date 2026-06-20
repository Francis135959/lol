import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart'; 
import 'package:hive_flutter/hive_flutter.dart';


import 'core/config/app_config.dart';
import 'core/config/env_config.dart';
import 'core/di/injection.dart';
import 'core/firestore/cache_manager.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';

import 'firebase_options.dart';
import 'features/configuracion/presentation/viewmodels/settings_viewmodel.dart';
import './app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar cache Firestore
  FirestoreCacheManager.configurarCache();

  Timer.periodic(
    const Duration(hours: 24),
    (_) async {
      final stats = await FirestoreCacheManager.obtenerEstadisticasCache();
      debugPrint('Estadísticas cache: $stats');
    },
  );

  AppConfig.init(environment: Environment.dev);

  setupDI();

  sl<ConnectivityService>().initialize();
  await sl<SettingsViewModel>().loadSettings();

  runApp(const MainApp());
}

class AppColors extends ThemeExtension<AppColors> {
  final Color? warning;
  final Color? info;
  final Color? success;

  const AppColors({this.warning, this.info, this.success});

  @override
  ThemeExtension<AppColors> copyWith({Color? warning, Color? info, Color? success}) {
    return AppColors(
      warning: warning ?? this.warning,
      info: info ?? this.info,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      warning: Color.lerp(warning, other.warning, t),
      info: Color.lerp(info, other.info, t),
      success: Color.lerp(success, other.success, t),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVm = sl<SettingsViewModel>();
    return ListenableBuilder(
      listenable: settingsVm,
      builder: (context, _) {
        final isDark = settingsVm.state.data?.isDarkMode ?? false;

        return MaterialApp.router(
          title: 'Cotizador App',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          
          theme: AppTheme.lightTheme, 
          darkTheme: AppTheme.darkTheme,
          
          routerConfig: appRouter,
        );
      },
    );
  }
}