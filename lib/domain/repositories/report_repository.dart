import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> saveReport(Report report);
  Future<Either<Failure, List<Report>>> getAllReports();
  Future<Either<Failure, Report>> getReportById(String id);
  Future<Either<Failure, void>> deleteReport(String id);
  Future<Either<Failure, void>> updateReport(Report report);
  Future<Either<Failure, List<Biomarker>>> getBiomarkerTrend(
      String biomarkerName,
      {DateTime? startDate,
      DateTime? endDate});
}
