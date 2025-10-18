import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;

  ReportRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Report>> saveReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      await localDataSource.saveReport(reportModel);
      return Right(report);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async {
    try {
      final reportModels = await localDataSource.getAllReports();
      final reports = reportModels.map((model) => model.toEntity()).toList();
      return Right(reports);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String id) async {
    try {
      final reportModel = await localDataSource.getReportById(id);
      if (reportModel != null) {
        return Right(reportModel.toEntity());
      } else {
        return Left(CacheFailure());
      }
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String id) async {
    try {
      await localDataSource.deleteReport(id);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      await localDataSource.updateReport(reportModel);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<TrendDataPoint>>> getBiomarkerTrend(
    String biomarkerName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final reports = await localDataSource.getAllReports();
      final targetName = biomarkerName.toLowerCase();
      final trendPoints = <TrendDataPoint>[];

      for (final reportModel in reports) {
        for (final biomarkerModel in reportModel.biomarkers) {
          final biomarkerNameNormalized = biomarkerModel.name.toLowerCase();

          if (biomarkerNameNormalized != targetName) {
            continue;
          }

          final biomarkerEntity = biomarkerModel.toEntity();
          final comparisonDate = biomarkerEntity.measuredAt;

          if (startDate != null && comparisonDate.isBefore(startDate)) {
            continue;
          }

          if (endDate != null && comparisonDate.isAfter(endDate)) {
            continue;
          }

          trendPoints.add(
            TrendDataPoint.fromBiomarker(
              biomarker: biomarkerEntity,
              date: reportModel.date,
              reportId: reportModel.id,
            ),
          );
        }
      }

      trendPoints.sort((a, b) => a.date.compareTo(b.date));

      return Right(trendPoints);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDistinctBiomarkerNames() async {
    try {
      final reports = await localDataSource.getAllReports();
      final biomarkerNames = <String>{};

      for (final reportModel in reports) {
        for (final biomarkerModel in reportModel.biomarkers) {
          biomarkerNames.add(biomarkerModel.name);
        }
      }

      // Convert to sorted list for consistency
      final sortedNames = biomarkerNames.toList()..sort();
      return Right(sortedNames);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
