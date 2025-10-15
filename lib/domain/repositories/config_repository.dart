import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

abstract class ConfigRepository {
  Future<Either<Failure, AppConfig>> getConfig();
  Future<Either<Failure, void>> saveConfig(AppConfig config);
}
