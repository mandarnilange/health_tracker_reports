import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';
import 'package:health_tracker_reports/presentation/router/app_router.dart';
import 'package:health_tracker_reports/presentation/theme/app_theme.dart';

/// Root application widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key, GoRouter? router}) : _router = router;

  final GoRouter? _router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch config state
    final configState = ref.watch(configProvider);
    final router = _router ?? AppRouter.router;

    return configState.when(
      data: (config) {
        return MaterialApp.router(
          title: 'Health Tracker Reports',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              config.darkModeEnabled ? ThemeMode.dark : ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () {
        // Show loading screen while config is being loaded
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stack) {
        // Show error screen if config loading fails
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load configuration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
