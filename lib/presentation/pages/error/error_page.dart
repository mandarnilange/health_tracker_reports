import 'package:flutter/material.dart';

/// Error page displayed when a route is not found (404).
///
/// This page is shown when users navigate to an invalid route
/// in the application.
class ErrorPage extends StatelessWidget {
  /// Optional error message to display
  final String? errorMessage;

  const ErrorPage({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
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
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigation will be added when router is integrated
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
