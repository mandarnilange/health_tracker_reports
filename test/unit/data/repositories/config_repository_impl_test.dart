import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/secure_config_storage.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/repositories/config_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';

class MockConfigLocalDataSource extends Mock implements ConfigLocalDataSource {}
class MockSecureConfigStorage extends Mock implements SecureConfigStorage {}

void main() {
  late ConfigRepositoryImpl repository;
  late MockConfigLocalDataSource mockLocalDataSource;
  late MockSecureConfigStorage mockSecureStorage;

  setUp(() {
    mockLocalDataSource = MockConfigLocalDataSource();
    mockSecureStorage = MockSecureConfigStorage();
    repository = ConfigRepositoryImpl(
      localDataSource: mockLocalDataSource,
      secureStorage: mockSecureStorage,
    );
    registerFallbackValue(AppConfigModel());
    registerFallbackValue(<LlmProvider, String>{});
  });

  group('getConfig', () {
    final tAppConfigModel = AppConfigModel(darkModeEnabled: true);
    final secureKeys = {LlmProvider.claude: 'secure-key'};
    final expectedConfig = AppConfig(
      llmApiKeys: secureKeys,
      llmProvider: tAppConfigModel.llmProvider,
      darkModeEnabled: tAppConfigModel.darkModeEnabled,
    );

    test(
        'should return an AppConfig when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getConfig())
          .thenAnswer((_) async => tAppConfigModel);
      when(() => mockSecureStorage.readAllApiKeys())
          .thenAnswer((_) async => secureKeys);

      // Act
      final result = await repository.getConfig();

      // Assert
      expect(result, Right(expectedConfig));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getConfig()).thenThrow(CacheException());

      // Act
      final result = await repository.getConfig();

      // Assert
      expect(result, Left(CacheFailure()));
    });

    test('should return CacheFailure when secure storage read fails', () async {
      // Arrange
      when(() => mockLocalDataSource.getConfig())
          .thenAnswer((_) async => tAppConfigModel);
      when(() => mockSecureStorage.readAllApiKeys())
          .thenThrow(Exception());

      // Act
      final result = await repository.getConfig();

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('saveConfig', () {
    final tAppConfig = AppConfig(darkModeEnabled: true);

    test('should return void when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockSecureStorage.writeApiKeys(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveConfig(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.saveConfig(tAppConfig);

      // Assert
      expect(result, Right(null));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockSecureStorage.writeApiKeys(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveConfig(any()))
          .thenThrow(CacheException());

      // Act
      final result = await repository.saveConfig(tAppConfig);

      // Assert
      expect(result, Left(CacheFailure()));
    });

    test('should return CacheFailure when secure storage write fails',
        () async {
      // Arrange
      when(() => mockSecureStorage.writeApiKeys(any()))
          .thenThrow(Exception());

      // Act
      final result = await repository.saveConfig(tAppConfig);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });
}
