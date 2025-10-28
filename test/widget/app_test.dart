import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/app.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';

class _ImmediateConfigRepository implements ConfigRepository {
  _ImmediateConfigRepository(this.config);

  final AppConfig config;

  @override
  Future<Either<Failure, AppConfig>> getConfig() async => Right(config);

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async =>
      const Right(null);
}

class _FailingConfigRepository implements ConfigRepository {
  _FailingConfigRepository(this.failure);

  final Failure failure;

  @override
  Future<Either<Failure, AppConfig>> getConfig() async => Left(failure);

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async =>
      const Right(null);
}

class _PendingConfigRepository implements ConfigRepository {
  final Completer<Either<Failure, AppConfig>> _completer =
      Completer<Either<Failure, AppConfig>>();

  void complete(Either<Failure, AppConfig> value) {
    if (!_completer.isCompleted) {
      _completer.complete(value);
    }
  }

  @override
  Future<Either<Failure, AppConfig>> getConfig() => _completer.future;

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async =>
      const Right(null);
}

void main() {
  testWidgets('MyApp renders router with dark theme when config loads',
      (tester) async {
    const config = AppConfig(darkModeEnabled: true);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith(
            (ref) => ConfigNotifier(_ImmediateConfigRepository(config)),
          ),
        ],
        child: MyApp(router: router),
      ),
    );

    // Allow ConfigNotifier.loadConfig to complete
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('MyApp shows loading indicator while config pending',
      (tester) async {
    final pendingRepository = _PendingConfigRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith(
            (ref) => ConfigNotifier(pendingRepository),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    // Clean up by completing the pending future to avoid leaks.
    pendingRepository.complete(const Right(AppConfig()));
  });

  testWidgets('MyApp shows error screen when config load fails',
      (tester) async {
    final failure = CacheFailure('boom');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith(
            (ref) => ConfigNotifier(_FailingConfigRepository(failure)),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Failed to load configuration'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });
}
