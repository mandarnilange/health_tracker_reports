import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/domain/usecases/delete_report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';

/// Provider exposing [GetAllReports] use case.
final getAllReportsProvider = Provider<GetAllReports>(
  (ref) => getIt<GetAllReports>(),
);

/// Provider exposing [GetBiomarkerTrend] use case.
final getBiomarkerTrendProvider = Provider<GetBiomarkerTrend>(
  (ref) => getIt<GetBiomarkerTrend>(),
);

/// Provider exposing [SaveReport] use case.
final saveReportUseCaseProvider = Provider<SaveReport>(
  (ref) => getIt<SaveReport>(),
);

/// Provider exposing [DeleteReport] use case.
final deleteReportProvider = Provider<DeleteReport>(
  (ref) => getIt<DeleteReport>(),
);

/// Provider exposing [CalculateTrend] use case.
final calculateTrendProvider = Provider<CalculateTrend>(
  (ref) => getIt<CalculateTrend>(),
);

/// Provider exposing [CompareBiomarkerAcrossReports] use case.
final compareBiomarkerAcrossReportsProvider =
    Provider<CompareBiomarkerAcrossReports>(
  (ref) => getIt<CompareBiomarkerAcrossReports>(),
);
