import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/app.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';

class _FakeConfigRepository implements ConfigRepository {
  _FakeConfigRepository(this._config);

  final AppConfig _config;

  @override
  Future<Either<Failure, AppConfig>> getConfig() async => Right(_config);

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async =>
      const Right(null);
}

class _TestConfigNotifier extends ConfigNotifier {
  _TestConfigNotifier(AppConfig config)
      : super(_FakeConfigRepository(config));
}

void main() {
  GoRouter createTestRouter() => GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );

  group('MyApp themeMode', () {
    testWidgets('uses system theme when dark mode disabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWith(
              (ref) => _TestConfigNotifier(
                const AppConfig(darkModeEnabled: false),
              ),
            ),
          ],
          child: MyApp(router: createTestRouter()),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);

      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('uses dark theme when dark mode enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWith(
              (ref) => _TestConfigNotifier(
                const AppConfig(darkModeEnabled: true),
              ),
            ),
          ],
          child: MyApp(router: createTestRouter()),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);

      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}
