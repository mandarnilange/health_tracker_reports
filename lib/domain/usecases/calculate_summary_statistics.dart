import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_trend_summary.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CalculateSummaryStatistics {
  final ReportRepository reportRepository;
  final HealthLogRepository healthLogRepository;
  final GetBiomarkerTrend getBiomarkerTrend;
  final GetVitalTrend getVitalTrend;
  final CalculateTrend calculateTrend;

  CalculateSummaryStatistics({
    required this.reportRepository,
    required this.healthLogRepository,
    required this.getBiomarkerTrend,
    required this.getVitalTrend,
    required this.calculateTrend,
  });

  Future<Either<Failure, SummaryStatistics>> call(
      DoctorSummaryConfig config) async {
    final reportsEither = await reportRepository.getReportsByDateRange(
        config.startDate, config.endDate);
    final healthLogsEither = await healthLogRepository.getHealthLogsByDateRange(
        config.startDate, config.endDate);

    return reportsEither.fold(
      (failure) => Left(failure),
      (reports) {
        return healthLogsEither.fold(
          (failure) => Left(failure),
          (healthLogs) async {
            final allBiomarkers = reports.expand((r) => r.biomarkers).toList();
            final outOfRangeBiomarkers = allBiomarkers.where((b) => b.isOutOfRange).toList();

            // Calculate severity and sort
            outOfRangeBiomarkers.sort((a, b) {
              final severityA = a.status == BiomarkerStatus.high 
                  ? (a.value - a.referenceRange.max) / a.referenceRange.max
                  : (a.referenceRange.min - a.value) / a.referenceRange.min;
              final severityB = b.status == BiomarkerStatus.high
                  ? (b.value - b.referenceRange.max) / b.referenceRange.max
                  : (b.referenceRange.min - b.value) / b.referenceRange.min;
              return severityB.compareTo(severityA); // Descending
            });

            final criticalFindings = outOfRangeBiomarkers
              .take(3)
              .map((b) => 
                CriticalFinding(
                  priority: outOfRangeBiomarkers.indexOf(b) + 1,
                  category: b.name, 
                  finding: '${b.value} ${b.unit}', 
                  actionNeeded: 'Consult physician' // Placeholder
                )
              ).toList();

            // Determine biomarker trends
            final uniqueBiomarkerNames = allBiomarkers.map((b) => b.name).toSet();
            final biomarkerTrends = <BiomarkerTrendSummary>[];

            await Future.forEach(uniqueBiomarkerNames, (name) async {
              final trendDataPointsEither = await getBiomarkerTrend(name, startDate: config.startDate, endDate: config.endDate);
              await trendDataPointsEither.fold(
                (failure) async => null, // Or handle error appropriately
                (dataPoints) async {
                  final trendAnalysisEither = calculateTrend(dataPoints);
                  trendAnalysisEither.fold(
                    (failure) => biomarkerTrends.add(BiomarkerTrendSummary(biomarkerName: name, trend: null)),
                    (trend) => biomarkerTrends.add(BiomarkerTrendSummary(biomarkerName: name, trend: trend)),
                  );
                },
              );
            });

            // Build dashboard
            final glucoseControl = _buildDashboardCategory('Glucose Control', ['Glucose', 'HbA1c'], allBiomarkers, biomarkerTrends);
            final lipidPanel = _buildDashboardCategory('Lipid Panel', ['LDL', 'HDL', 'Triglycerides'], allBiomarkers, biomarkerTrends);
            final kidneyFunction = _buildDashboardCategory('Kidney Function', ['Creatinine'], allBiomarkers, biomarkerTrends);
            // TODO: Implement vitals-based categories
            const bloodPressure = DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A');
            const cardiovascular = DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A');

            return Right(SummaryStatistics(
              biomarkerTrends: biomarkerTrends,
              vitalTrends: [],
              criticalFindings: criticalFindings,
              dashboard: HealthStatusDashboard(
                glucoseControl: glucoseControl,
                lipidPanel: lipidPanel,
                kidneyFunction: kidneyFunction,
                bloodPressure: bloodPressure,
                cardiovascular: cardiovascular,
              ),
              totalReports: reports.length,
              totalHealthLogs: healthLogs.length,
            ));
          },
        );
      },
    );
  }

  DashboardCategory _buildDashboardCategory(String categoryName, List<String> biomarkerNames, List<Biomarker> allBiomarkers, List<BiomarkerTrendSummary> biomarkerTrends) {
    final categoryBiomarkers = allBiomarkers.where((b) => biomarkerNames.contains(b.name)).toList();
    if (categoryBiomarkers.isEmpty) {
      return const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A');
    }

    categoryBiomarkers.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    final latestBiomarker = categoryBiomarkers.first;

    final trendSummary = biomarkerTrends.firstWhere((t) => t.biomarkerName == latestBiomarker.name, orElse: () => BiomarkerTrendSummary(biomarkerName: latestBiomarker.name, trend: null));

    String status = 'Normal';
    if (latestBiomarker.status == BiomarkerStatus.high || latestBiomarker.status == BiomarkerStatus.low) {
      status = 'High'; // Simplified for now
    }

    String trend = 'Stable';
    if (trendSummary.trend != null) {
      if (trendSummary.trend!.direction == TrendDirection.increasing) {
        trend = 'Worsening';
      } else if (trendSummary.trend!.direction == TrendDirection.decreasing) {
        trend = 'Improving';
      }
    }

    final formattedValue = latestBiomarker.value % 1 == 0 ? latestBiomarker.value.toInt() : latestBiomarker.value;

    return DashboardCategory(
      status: status,
      trend: trend,
      latestValue: '$formattedValue ${latestBiomarker.unit}',
    );
  }
}
