import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

@module
abstract class AppModule {
  @preResolve
  Future<HiveDatabase> get hiveDatabase async {
    final db = HiveDatabase(hive: Hive);
    await db.init();
    await db.openBoxes();
    return db;
  }

  @lazySingleton
  HiveInterface get hive => Hive;

  @lazySingleton
  Box<ReportModel> get reportBox =>
      Hive.box<ReportModel>(HiveDatabase.reportBoxName);

  @lazySingleton
  Box<AppConfigModel> get configBox =>
      Hive.box<AppConfigModel>(HiveDatabase.configBoxName);

  @lazySingleton
  Box<HealthLogModel> get healthLogBox =>
      Hive.box<HealthLogModel>(HiveDatabase.healthLogBoxName);

  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Uuid get uuid => const Uuid();

}
