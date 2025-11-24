import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'service/health_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize health service (with error handling for unsupported platforms)
  try {
    await HealthService().init();
  } catch (e) {
    developer.log('Health service initialization failed: $e', name: 'Main');
    // Continue without health service
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, watch, child) {
      final router = ref.watch(goRouterProvider);
      final themeNotifier = ref.watch(themeProvider);
      return MaterialApp.router(
        title: 'C My Hub - Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeNotifier.toThemeMode,
        routerConfig: router,
      );
    });
  }
}
