import 'package:equatable/equatable.dart';

import 'biomarker_trend_summary.dart';
import 'vital_trend_summary.dart';

class SummaryStatistics extends Equatable {
  final List<BiomarkerTrendSummary> biomarkerTrends;
  final List<VitalTrendSummary> vitalTrends;
  final List<CriticalFinding> criticalFindings;
  final HealthStatusDashboard dashboard;
  final int totalReports;
  final int totalHealthLogs;

  const SummaryStatistics({
    required this.biomarkerTrends,
    required this.vitalTrends,
    required this.criticalFindings,
    required this.dashboard,
    required this.totalReports,
    required this.totalHealthLogs,
  });

  @override
  List<Object?> get props => [
        biomarkerTrends,
        vitalTrends,
        criticalFindings,
        dashboard,
        totalReports,
        totalHealthLogs,
      ];
}

class CriticalFinding extends Equatable {
  final int priority;
  final String category;
  final String finding;
  final String actionNeeded;

  const CriticalFinding({
    required this.priority,
    required this.category,
    required this.finding,
    required this.actionNeeded,
  });

  @override
  List<Object?> get props => [priority, category, finding, actionNeeded];
}

class HealthStatusDashboard extends Equatable {
  final DashboardCategory glucoseControl;
  final DashboardCategory lipidPanel;
  final DashboardCategory kidneyFunction;
  final DashboardCategory bloodPressure;
  final DashboardCategory cardiovascular;

  const HealthStatusDashboard({
    required this.glucoseControl,
    required this.lipidPanel,
    required this.kidneyFunction,
    required this.bloodPressure,
    required this.cardiovascular,
  });

  @override
  List<Object?> get props => [
        glucoseControl,
        lipidPanel,
        kidneyFunction,
        bloodPressure,
        cardiovascular,
      ];
}

class DashboardCategory extends Equatable {
  final String status;
  final String trend;
  final String latestValue;

  const DashboardCategory({
    required this.status,
    required this.trend,
    required this.latestValue,
  });

  @override
  List<Object?> get props => [status, trend, latestValue];
}