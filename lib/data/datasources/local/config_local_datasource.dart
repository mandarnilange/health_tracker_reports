
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:hive/hive.dart';

abstract class ConfigLocalDataSource {
  Future<AppConfigModel> getConfig();
  Future<void> saveConfig(AppConfigModel config);
}

class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  final Box<AppConfigModel> box;

  static const String configKey = 'config';

  ConfigLocalDataSourceImpl({required this.box});

  @override
  Future<AppConfigModel> getConfig() async {
    try {
      return box.get(configKey) ?? AppConfigModel();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveConfig(AppConfigModel config) async {
    try {
      await box.put(configKey, config);
    } catch (e) {
      throw CacheException();
    }
  }
}
