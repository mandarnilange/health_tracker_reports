import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:injectable/injectable.dart';

/// Updates application configuration
@injectable
class UpdateConfig {
  final ConfigRepository repository;

  UpdateConfig(this.repository);

  Future<Either<Failure, void>> call(AppConfig config) async {
    return await repository.saveConfig(config);
  }
}
