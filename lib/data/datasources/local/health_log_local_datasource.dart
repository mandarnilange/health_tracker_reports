import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

abstract class HealthLogLocalDataSource {
  Future<void> saveHealthLog(HealthLogModel log);
  Future<List<HealthLogModel>> getAllHealthLogs();
  Future<HealthLogModel> getHealthLogById(String id);
  Future<void> deleteHealthLog(String id);
  Future<void> updateHealthLog(HealthLogModel log);
}

@LazySingleton(as: HealthLogLocalDataSource)
class HealthLogLocalDataSourceImpl implements HealthLogLocalDataSource {
  final Box<HealthLogModel> box;

  HealthLogLocalDataSourceImpl({required this.box});

  @override
  Future<void> saveHealthLog(HealthLogModel log) async {
    try {
      await box.put(log.id, log);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<HealthLogModel>> getAllHealthLogs() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<HealthLogModel> getHealthLogById(String id) async {
    try {
      final log = box.get(id);
      if (log != null) {
        return log;
      }
      throw CacheException('Health log not found: $id');
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteHealthLog(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateHealthLog(HealthLogModel log) async {
    try {
      await box.put(log.id, log);
    } catch (e) {
      throw CacheException();
    }
  }
}
