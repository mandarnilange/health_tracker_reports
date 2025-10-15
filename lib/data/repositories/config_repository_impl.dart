
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConfigRepository)
class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource localDataSource;

  ConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppConfig>> getConfig() async {
    try {
      final appConfigModel = await localDataSource.getConfig();
      return Right(appConfigModel.toEntity());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    try {
      final appConfigModel = AppConfigModel.fromEntity(config);
      await localDataSource.saveConfig(appConfigModel);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
