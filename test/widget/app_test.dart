import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';
import 'package:health_tracker_reports/app.dart';

void main() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('Home')),
      ),
    ],
  );

  testWidgets('MyApp renders MaterialApp.router when config loaded',
      (tester) async {
    const config = AppConfig(darkModeEnabled: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith((ref) => ConfigNotifierFake(config)),
        ],
        child: MyApp(router: router),
      ),
    );

    await tester.pump();

    final materialApp = tester.widget<MaterialAppRouter>(find.byType(MaterialAppRouter));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('MyApp shows loading screen during config fetch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith((ref) => const _StaticConfigNotifier.loading()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('MyApp shows error screen when config fails', (tester) async {
    final failure = CacheFailure('boom');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWith((ref) => _StaticConfigNotifier.error(failure)),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Failed to load configuration'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });
}

class ConfigNotifierFake extends ConfigNotifier {
  ConfigNotifierFake(AppConfig config)
      : super(_FakeConfigRepository(config));

  @override
  Future<void> loadConfig() async {
    state = AsyncValue.data((_repository as _FakeConfigRepository).config);
  }
}

class _FakeConfigRepository implements ConfigRepository {
  _FakeConfigRepository(this.config);

  final AppConfig config;

  @override
  Future<Either<Failure, AppConfig>> getConfig() async => Right(config);

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async => const Right(null);
}

class _StaticConfigNotifier extends ConfigNotifier {
  _StaticConfigNotifier.loading() : super(_FakeConfigRepository(const AppConfig())) {
    state = const AsyncValue.loading();
  }

  _StaticConfigNotifier.error(Failure failure)
      : super(_FakeConfigRepository(const AppConfig())) {
    state = AsyncValue.error(failure, StackTrace.empty);
  }
}
