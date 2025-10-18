import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:hive/hive.dart';

class HiveDatabase {
  final HiveInterface hive;

  HiveDatabase({required this.hive});

  static const String reportBoxName = 'reports';
  static const String configBoxName = 'config';

  Future<void> init() async {
    // Hive is already initialized with initFlutter() in main.dart
    // Just register adapters here
    hive.registerAdapter(ReportModelAdapter());
    hive.registerAdapter(AppConfigModelAdapter());
    hive.registerAdapter(BiomarkerModelAdapter());
    hive.registerAdapter(ReferenceRangeModelAdapter());
    hive.registerAdapter(LlmProviderAdapter());
  }

  Future<void> openBoxes() async {
    await hive.openBox<ReportModel>(reportBoxName);
    await hive.openBox<AppConfigModel>(configBoxName);
  }
}
