import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_document_wrapper.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
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
  PdfDocumentWrapper get pdfDocumentWrapper => PdfDocumentWrapper();

  @lazySingleton
  TextRecognizer get textRecognizer => TextRecognizer();

  @lazySingleton
  ConfigLocalDataSource get configLocalDataSource =>
      ConfigLocalDataSourceImpl(box: configBox);

  @lazySingleton
  Dio get dio => Dio();

  @preResolve
  Future<AppConfigModel> get appConfigModel =>
      configLocalDataSource.getConfig();
}
