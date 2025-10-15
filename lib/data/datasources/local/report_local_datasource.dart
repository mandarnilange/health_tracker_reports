import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

abstract class ReportLocalDataSource {
  Future<void> saveReport(ReportModel report);
  Future<List<ReportModel>> getAllReports();
  Future<ReportModel?> getReportById(String id);
  Future<void> deleteReport(String id);
  Future<void> updateReport(ReportModel report);
}

@LazySingleton(as: ReportLocalDataSource)
class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final Box<ReportModel> box;

  ReportLocalDataSourceImpl({required this.box});

  @override
  Future<void> saveReport(ReportModel report) async {
    try {
      await box.put(report.id, report);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<ReportModel?> getReportById(String id) async {
    try {
      return box.get(id);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    try {
      await box.put(report.id, report);
    } catch (e) {
      throw CacheException();
    }
  }
}
