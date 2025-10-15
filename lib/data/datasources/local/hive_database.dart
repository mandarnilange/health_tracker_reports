import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

class HiveDatabase {
  final HiveInterface hive;

  HiveDatabase({required this.hive});

  static const String reportBoxName = 'reports';
  static const String configBoxName = 'config';

  Future<void> init() async {
    hive.init('health_tracker_reports');
    hive.registerAdapter(ReportModelAdapter());
    hive.registerAdapter(AppConfigModelAdapter());
    hive.registerAdapter(BiomarkerModelAdapter());
    hive.registerAdapter(ReferenceRangeModelAdapter());
  }

  Future<void> openBoxes() async {
    await hive.openBox<ReportModel>(reportBoxName);
    await hive.openBox<AppConfigModel>(configBoxName);
  }
}