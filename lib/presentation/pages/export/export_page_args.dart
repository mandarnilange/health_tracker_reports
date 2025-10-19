import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';

/// Arguments container used when navigating to the [ExportPage].
class ExportPageArgs extends Equatable {
  const ExportPageArgs({
    required this.reports,
    required this.healthLogs,
    required this.trendSeries,
  });

  final List<Report> reports;
  final List<HealthLog> healthLogs;
  final List<TrendMetricSeries> trendSeries;

  @override
  List<Object?> get props => [reports, healthLogs, trendSeries];
}
