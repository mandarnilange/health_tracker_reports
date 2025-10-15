import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/app.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive with Flutter-specific path
    await Hive.initFlutter();

    // Configure dependency injection
    await configureDependencies();

    // Run the app with ProviderScope for Riverpod
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    // Handle initialization errors
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Run error app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
