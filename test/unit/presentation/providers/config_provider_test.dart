import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';

class _FakeConfigRepository implements ConfigRepository {
  _FakeConfigRepository(this._config);

  AppConfig _config;
  Failure? loadFailure;
  Failure? saveFailure;
  int saveCalls = 0;

  @override
  Future<Either<Failure, AppConfig>> getConfig() async {
    if (loadFailure != null) {
      return Left(loadFailure!);
    }
    return Right(_config);
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    saveCalls += 1;
    if (saveFailure != null) {
      return Left(saveFailure!);
    }
    _config = config;
    return const Right(null);
  }
}

void main() {
  late _FakeConfigRepository repository;
  late ProviderContainer container;
  const initialConfig = AppConfig(
    llmProvider: LlmProvider.claude,
    darkModeEnabled: false,
    llmApiKeys: {LlmProvider.claude: 'key'},
  );

  setUp(() {
    repository = _FakeConfigRepository(initialConfig);
    container = ProviderContainer(
      overrides: [
        configProvider.overrideWith(
          (ref) => ConfigNotifier(repository),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loadConfig populates state with repository result', () async {
    await container.read(configProvider.notifier).loadConfig();
    final state = container.read(configProvider);

    expect(state, isA<AsyncData<AppConfig>>());
    expect(state.value, equals(initialConfig));
  });

  test('toggleDarkMode flips configuration and persists via repository', () async {
    await container.read(configProvider.notifier).loadConfig();

    await container.read(configProvider.notifier).toggleDarkMode();
    await container.read(configProvider.notifier).loadConfig();

    final state = container.read(configProvider);
    expect(state.value?.darkModeEnabled, isTrue);
    expect(repository.saveCalls, 1);
    expect(repository._config.darkModeEnabled, isTrue);
  });

  test('saveConfig propagates failures to state', () async {
    repository.saveFailure = const CacheFailure();
    await container.read(configProvider.notifier).loadConfig();

    await container.read(configProvider.notifier).saveConfig(initialConfig);

    final state = container.read(configProvider);
    expect(state, isA<AsyncError<AppConfig>>());
  });
}
