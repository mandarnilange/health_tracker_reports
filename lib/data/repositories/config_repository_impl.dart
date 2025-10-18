import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/secure_config_storage.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConfigRepository)
class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource localDataSource;
  final SecureConfigStorage secureStorage;

  ConfigRepositoryImpl({
    required this.localDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AppConfig>> getConfig() async {
    try {
      final appConfigModel = await localDataSource.getConfig();
      final secureKeys = await secureStorage.readAllApiKeys();

      final mergedKeys = <LlmProvider, String>{};
      mergedKeys.addAll(appConfigModel.llmApiKeys);
      mergedKeys.addAll(secureKeys);
      mergedKeys.removeWhere((_, value) => value.isEmpty);

      final appConfig = AppConfig(
        llmApiKeys: mergedKeys,
        llmProvider: appConfigModel.llmProvider,
        darkModeEnabled: appConfigModel.darkModeEnabled,
      );

      return Right(appConfig);
    } on CacheException {
      return Left(CacheFailure());
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    try {
      await secureStorage.writeApiKeys(config.llmApiKeys);

      final sanitizedKeys = <LlmProvider, String>{};
      for (final provider in config.llmApiKeys.keys) {
        sanitizedKeys[provider] = '';
      }

      final appConfigModel = AppConfigModel(
        llmApiKeys: sanitizedKeys,
        llmProvider: config.llmProvider,
        darkModeEnabled: config.darkModeEnabled,
      );
      await localDataSource.saveConfig(appConfigModel);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
